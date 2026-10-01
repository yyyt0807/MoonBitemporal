///|
test "coverage distinguishes unclaimed assigned and withdrawn time" {
  let base = try! Ledger::new()
  let first = try! base.commit(
    1L,
    [Change::put("rate", try! Span::new(2L, 8L), "A")],
  )
  let second = try! first.commit(
    2L,
    [Change::delete("rate", try! Span::new(5L, 7L))],
  )
  let report = second.coverage("rate", try! Span::new(0L, 10L), 2L)
  assert_eq(report.total(), 10L)
  assert_eq(report.assigned(), 4L)
  assert_eq(report.withdrawn(), 2L)
  assert_eq(report.unclaimed(), 4L)
  assert_eq(report.values().length(), 1)
  assert_eq(report.values()[0].value(), "A")
  assert_eq(report.values()[0].duration(), 4L)
}

///|
test "duration rejects unbounded and unrepresentable windows" {
  let ledger = try! Ledger::new()
  let unbounded = try ledger.coverage("x", Span::open(0L), 0L) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  let huge = try ledger.coverage(
    "x",
    try! Span::new(-9223372036854775807L - 1L, 9223372036854775807L),
    0L,
  ) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  assert_eq(unbounded, "TEMPORAL_UNBOUNDED_DURATION")
  assert_eq(huge, "TEMPORAL_DURATION_OVERFLOW")
}
