///|
test "independent ledger comparison finds candidate deployment changes" {
  let base = try! Ledger::new()
  let deployed = try! base.commit(1L, [
    Change::put("rule", try! Span::new(0L, 100L), "allow"),
  ])
  let candidate = try! base.commit(5L, [
    Change::put("rule", try! Span::new(0L, 40L), "allow"),
    Change::put("rule", try! Span::new(40L, 100L), "deny"),
  ])
  let changed = compare_ledgers(
    deployed,
    candidate,
    "rule",
    try! Span::new(0L, 100L),
    1L,
    5L,
  )
  assert_eq(changed.length(), 1)
  assert_eq(changed[0].valid().start(), 40L)
  assert_eq(changed[0].valid().end(), Some(100L))
  assert_eq(changed[0].before(), Some("allow"))
  assert_eq(changed[0].after(), Some("deny"))
}

///|
test "cross-ledger diff respects open-ended windows" {
  let base = try! Ledger::new()
  let deployed = try! base.commit(1L, [Change::put("x", Span::open(0L), "a")])
  let candidate = try! base.commit(1L, [Change::put("x", Span::open(0L), "b")])
  let changed = compare_ledgers(
    deployed,
    candidate,
    "x",
    Span::open(0L),
    1L,
    1L,
  )
  assert_eq(changed.length(), 1)
  assert_eq(changed[0].valid().end(), None)
}
