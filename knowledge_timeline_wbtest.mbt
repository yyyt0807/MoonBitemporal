///|
test "knowledge timeline distinguishes ignorance correction and withdrawal" {
  let base = try! Ledger::new()
  let first = try! base.commit(10L, [
    Change::put("status", Span::open(0L), "pending"),
  ])
  let second = try! first.commit(20L, [
    Change::put("status", try! Span::new(5L, 15L), "approved"),
  ])
  let third = try! second.commit(30L, [
    Change::delete("status", try! Span::new(5L, 15L)),
  ])
  let history = third.knowledge_timeline("status", 10L, try! Span::new(0L, 40L))
  assert_eq(history.length(), 4)
  assert_true(history[0].is_unclaimed())
  assert_eq(history[1].value(), Some("pending"))
  assert_eq(history[2].value(), Some("approved"))
  assert_true(history[3].is_withdrawn())
  assert_eq(history[3].known().end(), Some(40L))
}

///|
test "knowledge timeline handles earliest Int64 and open future" {
  let base = try! Ledger::new()
  let ledger = try! base.commit(-9223372036854775807L - 1L, [
    Change::put("x", Span::open(0L), "known"),
  ])
  let history = ledger.knowledge_timeline(
    "x",
    1L,
    Span::open(-9223372036854775807L - 1L),
  )
  assert_eq(history.length(), 1)
  assert_eq(history[0].value(), Some("known"))
  assert_eq(history[0].known().end(), None)
}
