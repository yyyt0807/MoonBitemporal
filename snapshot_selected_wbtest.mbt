///|
test "selected snapshot returns sorted visible values without unrelated keys" {
  let base = try! Ledger::new()
  let ledger = try! base.commit(10L, [
    Change::put("a", Span::open(0L), "A"),
    Change::put("b", Span::open(0L), "B"),
    Change::put("c", Span::open(0L), "C"),
  ])
  let result = try! ledger.snapshot_selected(
    ["c", "a", "a", "missing"],
    5L,
    10L,
  )
  assert_eq(result.length(), 2)
  assert_eq(result[0].key(), "a")
  assert_eq(result[1].value(), "C")
}

///|
test "selected snapshot excludes withdrawn claims and enforces key budget" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [Change::put("a", Span::open(0L), "A")])
  let second = try! first.commit(2L, [Change::delete("a", Span::open(0L))])
  assert_eq((try! second.snapshot_selected(["a"], 0L, 2L)).length(), 0)
  let code = try
    second.snapshot_selected(["a", "b"], 0L, 2L, max_keys=1)
  catch {
    error => error.code()
  } noraise {
    _ => "unexpected success"
  }
  assert_eq(code, "TEMPORAL_KEY_LIMIT")
}
