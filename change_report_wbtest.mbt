///|
test "change report groups impacts by key and omits unchanged values" {
  let base = try! Ledger::new()
  let initial = try! base.commit(
    1L,
    [
      Change::put("price", Span::open(0L), "10"),
      Change::put("tax", Span::open(0L), "5"),
      Change::put("site", Span::open(0L), "A"),
    ],
  )
  let revised = try! initial.commit(
    2L,
    [
      Change::put("price", try! Span::new(10L, 20L), "12"),
      Change::put("tax", try! Span::new(10L, 20L), "5"),
      Change::delete("site", try! Span::new(15L, 25L)),
    ],
  )
  let report = try! revised.change_report(try! Span::new(0L, 30L), 1L, 2L)
  assert_eq(revised.keys(), ["price", "site", "tax"])
  assert_eq(report.keys_examined(), 3)
  assert_eq(report.keys_changed(), 2)
  assert_eq(report.fragment_count(), 2)
  assert_eq(report.entries()[0].key(), "price")
  assert_eq(report.entries()[1].key(), "site")
  assert_eq(report.entries()[0].fragments()[0].before(), Some("10"))
  assert_eq(report.entries()[1].fragments()[0].after(), None)
}

///|
test "change report includes keys introduced by candidate archive" {
  let base = try! Ledger::new()
  let previous = try! base.commit(1L, [Change::put("old", Span::open(0L), "A")])
  let candidate = try! base.commit(
    1L,
    [Change::put("new", Span::open(0L), "B")],
  )
  let report = try! compare_all_keys(previous, candidate, Span::open(0L), 1L, 1L)
  assert_eq(report.keys_examined(), 2)
  assert_eq(report.keys_changed(), 2)
  assert_eq(report.entries()[0].key(), "new")
  assert_eq(report.entries()[1].key(), "old")
}

///|
test "change report enforces both key and fragment budgets" {
  let base = try! Ledger::new()
  let candidate = try! base.commit(
    1L,
    [
      Change::put("a", Span::open(0L), "1"),
      Change::put("b", Span::open(0L), "1"),
    ],
  )
  let keys = try compare_all_keys(base, candidate, Span::open(0L), 0L, 1L, max_keys=1) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  let fragments = try compare_all_keys(
    base,
    candidate,
    Span::open(0L),
    0L,
    1L,
    max_fragments=1,
  ) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  assert_eq(keys, "TEMPORAL_KEY_LIMIT")
  assert_eq(fragments, "TEMPORAL_SEGMENT_LIMIT")
}
