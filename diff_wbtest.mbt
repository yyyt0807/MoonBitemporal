///|
test "knowledge diff reports retroactive correction only at affected valid time" {
  let base = try! Ledger::new()
  let first = try! base.commit(
    1L,
    [Change::put("price", try! Span::new(0L, 100L), "10")],
  )
  let second = try! first.commit(
    2L,
    [Change::put("price", try! Span::new(40L, 60L), "11")],
  )
  let changed = second.diff_knowledge(50L, 1L, 2L)
  assert_eq(changed.length(), 1)
  assert_eq(changed[0].before(), Some("10"))
  assert_eq(changed[0].after(), Some("11"))
  assert_true(second.diff_knowledge(30L, 1L, 2L).is_empty())
  assert_eq(second.diff_valid(30L, 50L, 2L).length(), 1)
}
