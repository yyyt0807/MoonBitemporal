///|
test "decision audit preserves input order and finds only changed business points" {
  let a = (try! Ledger::new()).commit(10L, [
    Change::put("price", Span::open(0L), "1000"),
  ])
  let decisions = [
    a.capture_decision("invoice-B", "price", 50L, 10L),
    a.capture_decision("invoice-A", "price", 35L, 10L),
  ]
  let b = a.commit(20L, [Change::put("price", try! Span::new(30L, 45L), "950")])
  let audit = b.audit_decisions(decisions, 20L)
  assert_eq(audit.length(), 2)
  assert_eq(audit[0].decision().id(), "invoice-B")
  assert_false(audit[0].needs_recompute())
  assert_false(audit[0].provenance_changed())
  assert_true(audit[1].needs_recompute())
  assert_eq(audit[1].current().map(fn(r) { r.value() }), Some(Some("950")))
  assert_eq(audit[1].decision().value(), Some("1000"))
  assert_eq(audit[1].decision().key(), "price")
  assert_eq(audit[1].decision().valid_at(), 35L)
  assert_eq(audit[1].decision().known_at(), 10L)
  assert_eq(audit[1].review_known(), 20L)
}

///|
test "same value reassertion changes provenance without recompute" {
  let a = (try! Ledger::new()).commit(1L, [
    Change::put("k", Span::open(0L), "A"),
  ])
  let decision = a.capture_decision("id", "k", 0L, 1L)
  let b = a.commit(2L, [Change::put("k", Span::open(0L), "A")])
  let result = b.audit_decisions([decision], 2L)[0]
  assert_false(result.needs_recompute())
  assert_true(result.provenance_changed())
}

///|
test "gap withdrawal assignment transitions remain distinguishable" {
  let a = try! Ledger::new()
  let gap = a.capture_decision("gap", "k", 0L, 0L)
  let b = a.commit(1L, [Change::delete("k", Span::open(0L))])
  assert_true(b.audit_decisions([gap], 1L)[0].needs_recompute())
  let withdrawn = b.capture_decision("withdrawn", "k", 0L, 1L)
  let c = b.commit(2L, [Change::delete("k", Span::open(0L))])
  assert_false(c.audit_decisions([withdrawn], 2L)[0].needs_recompute())
  let d = c.commit(3L, [Change::put("k", Span::open(0L), "A")])
  assert_true(d.audit_decisions([withdrawn], 3L)[0].needs_recompute())
  let assigned = d.capture_decision("assigned", "k", 0L, 3L)
  let e = d.commit(4L, [Change::delete("k", Span::open(0L))])
  assert_true(e.audit_decisions([assigned], 4L)[0].needs_recompute())
}

///|
test "audit historical review excludes even later corrections" {
  let a = (try! Ledger::new()).commit(1L, [
    Change::put("k", Span::open(0L), "A"),
  ])
  let decision = a.capture_decision("id", "k", 0L, 1L)
  let b = a.commit(3L, [Change::put("k", Span::open(0L), "B")])
  assert_false(b.audit_decisions([decision], 2L)[0].needs_recompute())
  assert_false(b.audit_decisions([decision], 1L)[0].needs_recompute())
}

///|
test "capture validates empty IDs and keys" {
  let a = try! Ledger::new()
  let code = try {
    a.capture_decision("", "k", 0L, 0L) |> ignore
    "unexpected"
  } catch {
    error => error.code()
  }
  assert_eq(code, "TEMPORAL_INVALID_DECISION")
  let code = try {
    a.capture_decision("id", "", 0L, 0L) |> ignore
    "unexpected"
  } catch {
    error => error.code()
  }
  assert_eq(code, "TEMPORAL_EMPTY_KEY")
}

///|
test "audit duplicate IDs knowledge order and ceilings reject atomically" {
  let a = try! Ledger::new()
  let decision = a.capture_decision("id", "k", 0L, 10L)
  let duplicate = try {
    a.audit_decisions([decision, decision], 10L) |> ignore
    "unexpected"
  } catch {
    error => error.code()
  }
  assert_eq(duplicate, "TEMPORAL_INVALID_DECISION")
  let earlier = try {
    a.audit_decisions([decision], 9L) |> ignore
    "unexpected"
  } catch {
    error => error.code()
  }
  assert_eq(earlier, "TEMPORAL_INVALID_DECISION")
  for maximum in [-1, 0] {
    let code = try {
      a.audit_decisions([], 10L, max_decisions=maximum) |> ignore
      "unexpected"
    } catch {
      error => error.code()
    }
    assert_eq(code, "TEMPORAL_DECISION_LIMIT")
  }
  let other = a.capture_decision("other", "k", 0L, 10L)
  let code = try {
    a.audit_decisions([decision, other], 10L, max_decisions=1) |> ignore
    "unexpected"
  } catch {
    error => error.code()
  }
  assert_eq(code, "TEMPORAL_DECISION_LIMIT")
  assert_eq(a.audit_decisions([], 10L).length(), 0)
  assert_eq(
    a.audit_decisions([decision, other], 10L, max_decisions=2).length(),
    2,
  )
}

///|
test "audit rejects foreign same sequence with different content or valid endpoint" {
  let a = (try! Ledger::new()).commit(1L, [
    Change::put("k", Span::open(0L), "A"),
  ])
  let decision = a.capture_decision("id", "k", 0L, 1L)
  for
    change in [
      Change::put("k", Span::open(0L), "B"),
      Change::put("k", try! Span::new(0L, 5L), "A"),
    ] {
    let foreign = (try! Ledger::new()).commit(1L, [change])
    let code = try {
      foreign.audit_decisions([decision], 1L) |> ignore
      "unexpected"
    } catch {
      error => error.code()
    }
    assert_eq(code, "TEMPORAL_INVALID_DECISION")
  }
}

///|
test "archive reload accepts matching decision claim evidence" {
  let ledger = generated_ledger()
  let decisions : Array[DecisionEvidence] = []
  for i = 0; i < 90; i = i + 1 {
    decisions.push(
      ledger.capture_decision(
        i.to_string(),
        "key-" + (i % 5).to_string(),
        (i % 83).to_int64(),
        i.to_int64(),
      ),
    )
  }
  let restored = try! Ledger::from_json_string(ledger.to_json_string())
  let audit = restored.audit_decisions(decisions, 89L)
  for item in audit {
    let decision = item.decision()
    assert_eq(
      decision.value(),
      model_value(
        ledger,
        decision.key(),
        decision.valid_at(),
        decision.known_at(),
      ),
    )
    assert_eq(
      observed_value(item.current()),
      model_value(ledger, decision.key(), decision.valid_at(), 89L),
    )
  }
}

///|
test "audit decisions scale to thousands with bounded output" {
  let builder = try! LedgerBuilder::new()
  for i = 0; i < 2000; i = i + 1 {
    builder.append(i.to_int64(), [
      Change::put(i.to_string(), Span::open(0L), "A"),
    ])
  }
  let ledger = builder.freeze()
  let decisions : Array[DecisionEvidence] = []
  for i = 0; i < 2000; i = i + 1 {
    decisions.push(
      ledger.capture_decision(i.to_string(), i.to_string(), 0L, 1999L),
    )
  }
  let updated = ledger.commit(2000L, [Change::put("123", Span::open(0L), "B")])
  let audits = updated.audit_decisions(decisions, 2000L, max_decisions=2000)
  assert_eq(audits.filter(fn(item) { item.needs_recompute() }).length(), 1)
  assert_eq(audits[123].decision().id(), "123")
}

///|
test "audit JSON contains precise large instants and detached evidence" {
  let a = (try! Ledger::new()).commit(-9223372036854775808L, [
    Change::put("k", Span::open(9223372036854775807L), "A"),
  ])
  let decision = a.capture_decision(
    "d\"", "k", 9223372036854775807L, -9223372036854775808L,
  )
  let audit = a.audit_decisions([decision], 9007199254740993L)[0]
  let text = audit.to_json().stringify()
  assert_true(text.contains("9007199254740993"))
  assert_true(text.contains("9223372036854775807"))
  assert_true(text.contains("-9223372036854775808"))
  assert_eq(audit.to_json(), try! @json.parse(text))
  assert_eq(audit.decision().source().map(fn(r) { r.sequence() }), Some(0))
}
