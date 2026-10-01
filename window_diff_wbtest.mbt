///|
test "window diff reports only changed valid-time fragments" {
  let base = try! Ledger::new()
  let first = try! base.commit(
    10L,
    [Change::put("price", try! Span::new(0L, 100L), "10")],
  )
  let second = try! first.commit(
    20L,
    [Change::put("price", try! Span::new(20L, 40L), "12")],
  )
  let third = try! second.commit(
    30L,
    [Change::delete("price", try! Span::new(70L, 80L))],
  )
  let changes = third.diff_timeline(
    "price",
    try! Span::new(0L, 100L),
    10L,
    30L,
  )
  assert_eq(changes.length(), 2)
  assert_eq(changes[0].valid().start(), 20L)
  assert_eq(changes[0].valid().end(), Some(40L))
  assert_eq(changes[0].before(), Some("10"))
  assert_eq(changes[0].after(), Some("12"))
  assert_eq(changes[1].valid().start(), 70L)
  assert_eq(changes[1].before(), Some("10"))
  assert_eq(changes[1].after(), None)
}

///|
test "window diff is empty when corrections retain the same value" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [Change::put("x", Span::open(0L), "a")])
  let second = try! first.commit(2L, [Change::put("x", Span::open(5L), "a")])
  assert_true(second.diff_timeline("x", Span::open(0L), 1L, 2L).is_empty())
}
