///|
test "timeline preserves gaps corrections and tombstones" {
  let base = try! Ledger::new()
  let first = try! base.commit(
    10L,
    [Change::put("k", try! Span::new(5L, 15L), "old")],
  )
  let second = try! first.commit(
    20L,
    [Change::put("k", try! Span::new(8L, 12L), "new")],
  )
  let third = try! second.commit(
    30L,
    [Change::delete("k", try! Span::new(13L, 14L))],
  )
  let timeline = try! third.timeline("k", try! Span::new(0L, 20L), 30L)
  assert_eq(timeline.length(), 7)
  assert_true(timeline[0].is_gap())
  assert_eq(timeline[1].value(), Some("old"))
  assert_eq(timeline[2].value(), Some("new"))
  assert_eq(timeline[3].value(), Some("old"))
  assert_true(timeline[4].is_deleted())
  assert_eq(timeline[5].value(), Some("old"))
  assert_true(timeline[6].is_gap())
  let earlier = try! third.timeline("k", try! Span::new(0L, 20L), 15L)
  assert_eq(earlier.length(), 3)
  assert_eq(earlier[1].value(), Some("old"))
}

///|
test "open timeline extends after final boundary" {
  let base = try! Ledger::new()
  let ledger = try! base.commit(1L, [Change::put("k", Span::open(10L), "v")])
  let timeline = try! ledger.timeline("k", Span::open(0L), 1L)
  assert_eq(timeline.length(), 2)
  assert_eq(timeline[0].valid().end(), Some(10L))
  assert_eq(timeline[1].valid().end(), None)
  assert_eq(timeline[1].value(), Some("v"))
}
