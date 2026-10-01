///|
test "revision pages preserve order and expose a terminating cursor" {
  let mut ledger = try! Ledger::new()
  for i = 0; i < 9; i = i + 1 {
    ledger = ledger.commit(
      i.to_int64(),
      [Change::put("k", Span::open(0L), i.to_string())],
    )
  }
  let first = ledger.page(0, 4)
  assert_eq(first.total(), 9)
  assert_eq(first.items().length(), 4)
  assert_eq(first.next_offset(), Some(4))
  let second = ledger.page(first.next_offset().unwrap(), 4)
  assert_eq(second.items()[0].sequence(), 4)
  assert_eq(second.next_offset(), Some(8))
  let last_page = ledger.page(second.next_offset().unwrap(), 4)
  assert_eq(last_page.items().length(), 1)
  assert_eq(last_page.next_offset(), None)
  assert_true(ledger.page(100, 4).is_empty())
}

///|
test "per-key pages retain global sequence and reject invalid limits" {
  let base = try! Ledger::new()
  let first = try! base.commit(
    1L,
    [Change::put("a", Span::open(0L), "1"), Change::put("b", Span::open(0L), "x")],
  )
  let second = try! first.commit(2L, [Change::put("a", Span::open(0L), "2")])
  let page = second.history_page("a", 0, 10)
  assert_eq(page.total(), 2)
  assert_eq(page.items()[0].sequence(), 0)
  assert_eq(page.items()[1].sequence(), 2)
  assert_eq(second.history_page("unknown", 0, 1).total(), 0)
  let invalid = try second.page(-1, 1) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  assert_eq(invalid, "TEMPORAL_INVALID_PAGE")
}
