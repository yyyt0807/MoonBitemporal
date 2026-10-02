///|
test "batch lookup finds exact atomic group and preserves global sequence" {
  let base = try! Ledger::new()
  let first = try! base.commit(10L, [
    Change::put("a", Span::open(0L), "A"),
    Change::put("b", Span::open(0L), "B"),
  ])
  let second = try! first.commit(20L, [Change::delete("a", Span::open(0L))])
  let batch = second.batch_at(10L).unwrap()
  assert_eq(batch.size(), 2)
  assert_eq(batch.known_at(), 10L)
  assert_eq(batch.revisions()[0].sequence(), 0)
  assert_eq(batch.revisions()[1].key(), "b")
  assert_eq(second.batch_at(20L).unwrap().size(), 1)
  assert_true(second.batch_at(15L) is None)
  assert_true(second.batch_at(9L) is None)
}

///|
test "batch lookup on empty ledger and detached result" {
  let empty = try! Ledger::new()
  assert_true(empty.batch_at(1L) is None)
  let ledger = try! empty.commit(1L, [Change::put("k", Span::open(0L), "v")])
  let copy = ledger.batch_at(1L).unwrap().revisions()
  copy.clear()
  assert_eq(ledger.batch_at(1L).unwrap().size(), 1)
}
