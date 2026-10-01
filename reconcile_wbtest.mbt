///|
test "reconcile accepts an exact remote extension and preserves local state" {
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [Change::put("k", Span::open(0L), "a")])
  let second = try! first.commit(2L, [Change::put("k", Span::open(5L), "b")])
  assert_true(first.is_prefix_of(second))
  assert_false(second.is_prefix_of(first))
  assert_eq(first.first_divergence(second), None)
  let reconciled = try! first.reconcile(second)
  assert_eq(reconciled.revision_count(), 2)
  assert_eq(reconciled.get("k", 6L, 2L), Some("b"))
  assert_eq(first.revision_count(), 1)
  let local_longer = try! second.reconcile(first)
  assert_eq(local_longer.to_json_string(), second.to_json_string())
}

///|
test "reconcile rejects equal-length diverged histories" {
  let base = try! Ledger::new()
  let left = try! base.commit(1L, [Change::put("k", Span::open(0L), "a")])
  let right = try! base.commit(1L, [Change::put("k", Span::open(0L), "b")])
  assert_eq(left.first_divergence(right), Some(0))
  let code = try left.reconcile(right) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  assert_eq(code, "TEMPORAL_DIVERGENT_HISTORY")
}

///|
test "reconcile compares claim spans and enforces receiver capacity" {
  let base = try! Ledger::new(maximum=1)
  let receiver = try! base.commit(1L, [Change::put("k", Span::open(0L), "a")])
  let remote_base = try! Ledger::new(maximum=3)
  let remote_first = try! remote_base.commit(
    1L,
    [Change::put("k", Span::open(0L), "a")],
  )
  let remote = try! remote_first.commit(2L, [Change::delete("k", Span::open(5L))])
  let code = try receiver.reconcile(remote) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  assert_eq(code, "TEMPORAL_REVISION_LIMIT")
  let different_span = try! remote_base.commit(
    1L,
    [Change::put("k", Span::open(1L), "a")],
  )
  assert_eq(receiver.first_divergence(different_span), Some(0))
}
