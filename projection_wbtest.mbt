///|
test "knowledge projection preserves old views and drops later claims" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [Change::put("k", Span::open(0L), "old")])
  let second = try! first.commit(2L, [Change::put("k", Span::open(0L), "new")])
  let past = second.as_known_at(1L)
  assert_eq(past.revision_count(), 1)
  assert_eq(past.latest_time(), Some(1L))
  assert_eq(past.get("k", 0L, 99L), Some("old"))
  assert_eq(second.as_known_at(0L).revision_count(), 0)
  assert_eq(second.revision_count(), 2)
}

///|
test "key projection keeps relative order and renumbers sequences" {
  let base = try! Ledger::new()
  let first = try! base.commit(
    1L,
    [
      Change::put("a", Span::open(0L), "A"),
      Change::put("b", Span::open(0L), "B"),
    ],
  )
  let second = try! first.commit(2L, [Change::put("b", Span::open(0L), "B2")])
  let only_b = second.select_keys(["b", "b"])
  assert_eq(only_b.revision_count(), 2)
  assert_eq(only_b.history_count("a"), 0)
  assert_eq(only_b.history_count("b"), 2)
  assert_eq(only_b.revision(0).unwrap().sequence(), 0)
  assert_eq(only_b.revision(1).unwrap().sequence(), 1)
  assert_eq(only_b.get("b", 1L, 2L), Some("B2"))
  assert_eq(second.select_keys([]).revision_count(), 0)
}
