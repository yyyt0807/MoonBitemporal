///|
test "semantic span filter keeps withdrawal distinct from never-assigned gap" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [
    Change::put("k", try! Span::new(2L, 8L), "a"),
  ])
  let second = try! first.commit(2L, [
    Change::delete("k", try! Span::new(4L, 6L)),
  ])
  let bounds = try! Span::new(0L, 10L)
  let withdrawn = second.matching_spans("k", bounds, 2L, Withdrawn)
  let unclaimed = second.matching_spans("k", bounds, 2L, Unclaimed)
  let assigned = second.matching_spans("k", bounds, 2L, Assigned)
  assert_eq(withdrawn.length(), 1)
  assert_eq(withdrawn[0].start(), 4L)
  assert_eq(withdrawn[0].end(), Some(6L))
  assert_eq(unclaimed.length(), 2)
  assert_eq(unclaimed[0].end(), Some(2L))
  assert_eq(unclaimed[1].start(), 8L)
  assert_eq(assigned.length(), 2)
}

///|
test "value matching coalesces adjacent same-value revisions" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [Change::put("k", Span::open(0L), "a")])
  let second = try! first.commit(2L, [
    Change::put("k", try! Span::new(5L, 10L), "a"),
  ])
  let matches = second.matching_spans(
    "k",
    try! Span::new(0L, 20L),
    2L,
    Equals("a"),
  )
  assert_eq(matches.length(), 1)
  assert_eq(matches[0].start(), 0L)
  assert_eq(matches[0].end(), Some(20L))
  assert_true(
    second.matching_spans("k", Span::open(0L), 2L, Equals("b")).is_empty(),
  )
}
