///|
test "trace orders applicable revisions and retains tombstone precedence" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [Change::put("k", Span::open(0L), "old")])
  let second = try! first.commit(2L, [Change::put("k", Span::open(5L), "new")])
  let third = try! second.commit(3L, [Change::delete("k", Span::open(7L))])
  let trace = third.trace("k", 8L, 3L)
  assert_eq(trace.candidates().length(), 3)
  assert_eq(trace.winner().unwrap().sequence(), 2)
  assert_eq(trace.value(), None)
  assert_eq(trace.superseded_count(), 2)
  assert_false(trace.truncated())
  let old = third.trace("k", 8L, 1L)
  assert_eq(old.value(), Some("old"))
  assert_eq(old.superseded_count(), 0)
}

///|
test "trace limit reports truncation without changing winner" {
  let base = try! Ledger::new()
  let mut ledger = base
  for i = 0; i < 10; i = i + 1 {
    ledger = ledger.commit(i.to_int64(), [
      Change::put("k", Span::open(0L), i.to_string()),
    ])
  }
  let limited = ledger.trace("k", 1L, 9L, max_candidates=2)
  assert_eq(limited.value(), Some("9"))
  assert_eq(limited.candidates().length(), 2)
  assert_true(limited.truncated())
  let missing = ledger.trace("unknown", 1L, 9L)
  assert_true(missing.winner() is None)
}
