///|
test "per-key index isolates prior immutable ledgers" {
  let base = try! Ledger::new()
  let span = Span::open(0L)
  let first = try! base.commit(1L, [Change::put("a", span, "v1")])
  let second = try! first.commit(2L, [Change::put("a", span, "v2")])
  let third = try! second.commit(3L, [Change::put("b", span, "other")])
  assert_eq(base.history("a").length(), 0)
  assert_eq(first.history("a").length(), 1)
  assert_eq(second.history("a").length(), 2)
  assert_eq(third.history("b").length(), 1)
  assert_eq(first.get("a", 1L, 99L), Some("v1"))
  assert_eq(second.get("a", 1L, 99L), Some("v2"))
}
