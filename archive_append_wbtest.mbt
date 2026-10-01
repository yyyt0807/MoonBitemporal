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

///|
test "bulk tail append preserves a long sequence without repeated commits" {
  let base = try! Ledger::new(maximum=2000)
  let first = try! base.commit(
    0L,
    [Change::put("anchor", Span::open(0L), "base")],
  )
  let mut remote = try! Ledger::new(maximum=2000)
  for i = 1; i <= 500; i = i + 1 {
    remote = remote.commit(
      i.to_int64(),
      [Change::put("sensor", Span::open(0L), i.to_string())],
    )
  }
  let merged = try! first.append_ledger(remote)
  assert_eq(merged.revision_count(), 501)
  assert_eq(merged.revision(1).unwrap().sequence(), 1)
  assert_eq(merged.revision(500).unwrap().sequence(), 500)
  assert_eq(merged.get("anchor", 0L, 500L), Some("base"))
  assert_eq(merged.get("sensor", 0L, 500L), Some("500"))
  assert_eq(first.revision_count(), 1)
}
