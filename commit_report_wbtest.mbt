///|
test "commit report can be inspected without changing base ledger" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [Change::put("price", Span::open(0L), "10")])
  let report = first.commit_with_report(
    2L,
    [
      Change::put("price", try! Span::new(2L, 4L), "11"),
      Change::put("tax", Span::open(0L), "5"),
    ],
  )
  assert_eq(report.appended(), 2)
  assert_eq(report.known_at(), 2L)
  assert_eq(report.changed_fragment_count(), 2)
  assert_eq(first.revision_count(), 1)
  assert_eq(first.get("price", 3L, 2L), Some("10"))
  let accepted = report.next()
  assert_eq(accepted.revision_count(), 3)
  assert_eq(accepted.get("price", 3L, 2L), Some("11"))
  assert_eq(accepted.get("tax", 3L, 2L), Some("5"))
}

///|
test "report impact budget rejects oversized effects without touching base" {
  let base = try! Ledger::new()
  let bad = try base.commit_with_report(
    1L,
    [
      Change::put("a", Span::open(0L), "1"),
      Change::put("b", Span::open(0L), "1"),
    ],
    max_impacts=1,
  ) catch {
    _ => true
  } noraise {
    _ => false
  }
  assert_true(bad)
  assert_eq(base.revision_count(), 0)
}
