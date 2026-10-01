///|
test "snapshot sorts keys and hides tombstones" {
  let base = try! Ledger::new()
  let window = Span::open(0L)
  let first = try! base.commit(
    1L,
    [
      Change::put("z", window, "last"),
      Change::put("a", window, "first"),
      Change::put("m", window, "middle"),
    ],
  )
  let second = try! first.commit(2L, [Change::delete("m", window)])
  let facts = second.snapshot(5L, 2L)
  assert_eq(facts.length(), 2)
  assert_eq(facts[0].key(), "a")
  assert_eq(facts[1].key(), "z")
  assert_eq(second.keys(), ["a", "m", "z"])
  assert_false(second.contains_key("m", 5L, 2L))
  assert_eq(second.visible_count(5L, 1L), 3)
}

///|
test "key ordering is lexical when keys have different lengths" {
  let base = try! Ledger::new()
  let ledger = try! base.commit(
    1L,
    [
      Change::put("tax", Span::open(0L), "t"),
      Change::put("site", Span::open(0L), "s"),
      Change::put("price", Span::open(0L), "p"),
    ],
  )
  assert_eq(ledger.keys(), ["price", "site", "tax"])
  let facts = ledger.snapshot(0L, 1L)
  assert_eq(facts[0].key(), "price")
  assert_eq(facts[1].key(), "site")
  assert_eq(facts[2].key(), "tax")
}
