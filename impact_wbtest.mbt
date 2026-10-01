///|
test "revision impact identifies corrected subspan and previous belief" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [
    Change::put("price", try! Span::new(0L, 100L), "10"),
  ])
  let second = try! first.commit(2L, [
    Change::put("price", try! Span::new(40L, 60L), "11"),
  ])
  let third = try! second.commit(3L, [
    Change::delete("price", try! Span::new(50L, 70L)),
  ])
  let correction = third.impact_of_revision(1)
  assert_eq(correction.length(), 1)
  assert_eq(correction[0].before(), Some("10"))
  assert_eq(correction[0].after(), Some("11"))
  assert_eq(correction[0].valid().start(), 40L)
  assert_eq(correction[0].valid().end(), Some(60L))
  let withdrawal = third.impact_of_revision(2)
  assert_eq(withdrawal.length(), 2)
  assert_eq(withdrawal[0].before(), Some("11"))
  assert_eq(withdrawal[1].before(), Some("10"))
  assert_eq(withdrawal[0].after(), None)
}

///|
test "same-value correction has no value impact" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [Change::put("k", Span::open(0L), "v")])
  let second = try! first.commit(2L, [Change::put("k", Span::open(5L), "v")])
  assert_true(second.impact_of_revision(1).is_empty())
}
