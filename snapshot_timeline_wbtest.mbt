///|
test "multi-key snapshot timeline aligns changes from distinct keys" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [
    Change::put("price", Span::open(0L), "10"),
    Change::put("tax", Span::open(0L), "2"),
  ])
  let second = try! first.commit(2L, [
    Change::put("price", try! Span::new(3L, 7L), "11"),
  ])
  let third = try! second.commit(3L, [
    Change::delete("tax", try! Span::new(5L, 8L)),
  ])
  let view = third.snapshot_timeline(
    ["tax", "price", "tax"],
    try! Span::new(0L, 10L),
    3L,
  )
  assert_eq(view.length(), 5)
  assert_eq(view[0].value("price"), Some("10"))
  assert_eq(view[1].value("price"), Some("11"))
  assert_eq(view[2].value("tax"), None)
  assert_eq(view[3].value("price"), Some("10"))
  assert_eq(view[4].value("tax"), Some("2"))
}

///|
test "multi-key timeline enforces key and segment limits" {
  let ledger = try! Ledger::new()
  let bounds = try! Span::new(0L, 10L)
  let limit = try
    ledger.snapshot_timeline(["a", "b"], bounds, 0L, max_keys=1)
  catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  assert_eq(limit, "TEMPORAL_KEY_LIMIT")
  let empty = ledger.snapshot_timeline([], bounds, 0L)
  assert_eq(empty.length(), 1)
  assert_eq(empty[0].facts().length(), 0)
}
