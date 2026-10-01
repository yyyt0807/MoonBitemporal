///|
test "archive tail reproduces later claims without altering earlier ledger" {
  let base = try! Ledger::new()
  let first = try! base.commit(10L, [Change::put("price", Span::open(0L), "10")])
  let second = try! first.commit(20L, [Change::put("price", Span::open(5L), "11")])
  let third = try! second.commit(30L, [Change::delete("price", Span::open(9L))])
  let tail = third.to_json_since(10L)
  let restored = try! first.append_json(tail)
  assert_eq(restored.revision_count(), third.revision_count())
  assert_eq(restored.to_json_string(), third.to_json_string())
  assert_eq(first.get("price", 10L, 30L), Some("10"))
  assert_eq(restored.get("price", 10L, 30L), None)
}

///|
test "archive append rejects stale tails atomically" {
  let base = try! Ledger::new()
  let first = try! base.commit(10L, [Change::put("x", Span::open(0L), "a")])
  let second = try! first.commit(20L, [Change::put("x", Span::open(0L), "b")])
  let stale = second.to_json_since(0L)
  let rejected = try first.append_json(stale) catch {
    _ => true
  } noraise {
    _ => false
  }
  assert_true(rejected)
  assert_eq(first.revision_count(), 1)
  assert_eq(first.get("x", 1L, 99L), Some("a"))
}

///|
test "empty archive tail is an identity operation" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [Change::put("x", Span::open(0L), "a")])
  let empty = first.to_json_since(1L)
  let merged = try! first.append_json(empty)
  assert_eq(merged.to_json_string(), first.to_json_string())
}
