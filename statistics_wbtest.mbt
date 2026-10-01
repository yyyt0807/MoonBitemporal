///|
test "ledger statistics count batches keys and tombstones" {
  let base = try! Ledger::new()
  let empty = base.stats()
  assert_eq(empty.revisions(), 0)
  assert_eq(empty.keys(), 0)
  assert_eq(empty.first_knowledge_time(), None)
  let first = try! base.commit(3L, [
    Change::put("b", Span::open(0L), "x"),
    Change::put("a", try! Span::new(0L, 10L), "y"),
  ])
  let second = try! first.commit(8L, [Change::delete("a", Span::open(10L))])
  let stats = second.stats()
  assert_eq(stats.revisions(), 3)
  assert_eq(stats.keys(), 2)
  assert_eq(stats.batches(), 2)
  assert_eq(stats.tombstones(), 1)
  assert_eq(stats.open_valid_spans(), 2)
  assert_eq(stats.most_revised_key(), Some("a"))
  assert_eq(stats.most_revisions_for_key(), 2)
  assert_eq(stats.first_knowledge_time(), Some(3L))
  assert_eq(stats.latest_knowledge_time(), Some(8L))
}
