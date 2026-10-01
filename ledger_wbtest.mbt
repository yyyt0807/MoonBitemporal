///|
test "retroactive correction does not erase prior knowledge" {
  let span = try! Span::new(100L, 200L)
  let original = try! Ledger::new()
  let first = try! original.commit(10L, [Change::put("price", span, "10")])
  let corrected = try! first.commit(20L, [
    Change::put("price", try! Span::new(120L, 150L), "12"),
  ])
  assert_eq(corrected.get("price", 130L, 15L), Some("10"))
  assert_eq(corrected.get("price", 130L, 20L), Some("12"))
  assert_eq(corrected.get("price", 110L, 20L), Some("10"))
  assert_eq(first.get("price", 130L, 20L), Some("10"))
  assert_eq(original.revision_count(), 0)
}

///|
test "tombstone hides only its valid span" {
  let span = try! Span::new(0L, 100L)
  let base = try! Ledger::new()
  let first = try! base.commit(1L, [Change::put("access", span, "on")])
  let second = try! first.commit(2L, [
    Change::delete("access", try! Span::new(40L, 60L)),
  ])
  assert_eq(second.get("access", 30L, 2L), Some("on"))
  assert_eq(second.get("access", 50L, 1L), Some("on"))
  assert_eq(second.get("access", 50L, 2L), None)
  assert_true(second.observe("access", 50L, 2L) is Some(_))
}

///|
test "invalid batch is atomic" {
  let base = try! Ledger::new()
  let span = try! Span::new(0L, 10L)
  let rejected = try
    base.commit(1L, [Change::put("a", span, "x"), Change::put("a", span, "y")])
  catch {
    _ => true
  } noraise {
    _ => false
  }
  assert_true(rejected)
  assert_eq(base.revision_count(), 0)
  let first = try! base.commit(1L, [Change::put("a", span, "x")])
  let stale_rejected = try
    first.commit(1L, [Change::put("b", span, "y")])
  catch {
    _ => true
  } noraise {
    _ => false
  }
  assert_true(stale_rejected)
  assert_eq(first.revision_count(), 1)
}
