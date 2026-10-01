///|
test "large disjoint batch is accepted and keeps caller order" {
  let base = try! Ledger::new(maximum=2000)
  let changes : Array[Change] = []
  for i = 999; i >= 0; i = i - 1 {
    let start = (i * 3).to_int64()
    changes.push(
      Change::put("k", try! Span::new(start, start + 2L), i.to_string()),
    )
  }
  let ledger = try! base.commit(1L, changes)
  assert_eq(ledger.revision_count(), 1000)
  assert_eq(ledger.revision(0).unwrap().value(), Some("999"))
  assert_eq(ledger.revision(999).unwrap().value(), Some("0"))
  assert_eq(ledger.get("k", 4L, 1L), Some("1"))
}

///|
test "sorted validation catches nonadjacent input overlap" {
  let base = try! Ledger::new()
  let changes = [
    Change::put("a", try! Span::new(50L, 60L), "later"),
    Change::put("b", Span::open(0L), "other key"),
    Change::put("a", try! Span::new(0L, 100L), "wide"),
  ]
  let rejected = try base.commit(1L, changes) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  assert_eq(rejected, "TEMPORAL_BATCH_OVERLAP")
  assert_eq(base.revision_count(), 0)
}

///|
test "adjacent same-key intervals are legal in one batch" {
  let base = try! Ledger::new()
  let ledger = try! base.commit(1L, [
    Change::put("k", try! Span::new(0L, 5L), "a"),
    Change::put("k", try! Span::new(5L, 10L), "b"),
  ])
  assert_eq(ledger.get("k", 4L, 1L), Some("a"))
  assert_eq(ledger.get("k", 5L, 1L), Some("b"))
}
