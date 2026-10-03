///|
test "incremental pages preserve atomic batches and advance exact cursors" {
  let span = Span::open(0L)
  let ledger = try! Ledger::new()
    .commit(10L, [Change::put("a", span, "1"), Change::put("b", span, "2")])
    .commit(20L, [Change::put("a", span, "3")])
    .commit(30L, [Change::put("b", span, "4")])
  let first = try! ledger.batches_since(None, max_revisions=2)
  assert_eq(first.batches().length(), 1)
  assert_eq(first.batches()[0].size(), 2)
  assert_eq(first.next_known_at(), Some(10L))
  assert_true(first.has_more())
  let second = try! ledger.batches_since(first.next_known_at(), max_batches=1)
  assert_eq(second.batches()[0].known_at(), 20L)
  let last = try! ledger.batches_since(Some(20L))
  assert_eq(last.batches()[0].known_at(), 30L)
  assert_false(last.has_more())
  let detached = first.batches()
  detached.clear()
  assert_eq(first.batches().length(), 1)
}

///|
test "oversized atomic page errors and maximum cursor cannot overflow" {
  let ledger = try! Ledger::new().commit(10L, [
    Change::put("a", Span::open(0L), "1"),
    Change::put("b", Span::open(0L), "2"),
  ])
  ignore(ledger.batches_since(None, max_revisions=1)) catch {
    TooManyRevisions(..) => ()
    _ => fail("expected whole-batch budget error")
  }
  ignore(ledger.batches_since(None, max_batches=0)) catch {
    InvalidPage(_) => ()
    _ => fail("expected invalid batch count")
  }
  let page = try! ledger.batches_since(Some(9223372036854775807L))
  assert_eq(page.next_known_at(), None)
  assert_false(page.has_more())
  assert_eq(page.batches().length(), 0)
  let earliest = try! Ledger::new().commit(-9223372036854775808L, [
    Change::put("a", Span::open(0L), "x"),
  ])
  assert_eq(
    (try! earliest.batches_since(None)).batches()[0].known_at(),
    -9223372036854775808L,
  )
}

///|
test "joint coverage matches a discrete oracle across corrections and tombstones" {
  let bounds = try! Span::new(0L, 12L)
  let ledger = try! Ledger::new()
    .commit(1L, [
      Change::put("a", bounds, "a"),
      Change::put("b", try! Span::new(2L, 10L), "b"),
    ])
    .commit(2L, [Change::delete("a", try! Span::new(4L, 6L))])
  for known in [0L, 1L, 2L] {
    let spans = try! ledger.joint_assigned_spans(["b", "a", "a"], bounds, known)
    for t = 0L; t < 12L; t = t + 1L {
      let actual = spans.any(fn(span) { span.contains(t) })
      assert_eq(
        actual,
        ledger.get("a", t, known) is Some(_) &&
        ledger.get("b", t, known) is Some(_),
      )
    }
  }
  let spans = try! ledger.joint_assigned_spans(["a", "b"], bounds, 2L)
  assert_eq(spans.length(), 2)
  assert_eq(spans[0].start(), 2L)
  assert_eq(spans[0].end(), Some(4L))
  assert_eq(spans[1].start(), 6L)
  assert_eq(spans[1].end(), Some(10L))
}

///|
test "joint coverage handles open bounds empty keys and duplicate input budgets" {
  let ledger = try! Ledger::new().commit(1L, [
    Change::put("a", Span::open(5L), "v"),
  ])
  let open = try! ledger.joint_assigned_spans(["a"], Span::open(0L), 1L)
  assert_eq(open[0].end(), None)
  assert_eq(open[0].start(), 5L)
  assert_eq(
    (try! ledger.joint_assigned_spans([], Span::open(0L), 1L, max_keys=0)).length(),
    1,
  )
  let repeated = Array::make(10000, "a")
  assert_eq(
    (try! ledger.joint_assigned_spans(repeated, Span::open(0L), 1L, max_keys=1)).length(),
    1,
  )
  ignore(
    ledger.joint_assigned_spans(["a", "b"], Span::open(0L), 1L, max_keys=1),
  ) catch {
    TooManyKeys(..) => ()
    _ => fail("expected distinct key budget")
  }
}
