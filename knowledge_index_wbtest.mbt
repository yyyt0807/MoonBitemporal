///|
test "binary knowledge cutoff handles batches and times outside history" {
  let base = try! Ledger::new()
  let first = try! base.commit(-10L, [
    Change::put("k", try! Span::new(0L, 10L), "early"),
    Change::put("k", try! Span::new(10L, 20L), "other span"),
  ])
  let second = try! first.commit(5L, [
    Change::put("k", try! Span::new(0L, 10L), "late"),
  ])
  assert_eq(second.get("k", 1L, -11L), None)
  assert_eq(second.get("k", 1L, -10L), Some("early"))
  assert_eq(second.get("k", 1L, 4L), Some("early"))
  assert_eq(second.get("k", 1L, 5L), Some("late"))
  assert_eq(second.get("k", 11L, 5L), Some("other span"))
  assert_eq(second.get("k", 1L, 9223372036854775807L), Some("late"))
}

///|
test "binary cutoff agrees with forward model for every knowledge instant" {
  let ledger = generated_ledger()
  for known_at = -1; known_at < 100; known_at = known_at + 1 {
    for valid_at = 0; valid_at < 100; valid_at = valid_at + 4 {
      let expected = model_value(
        ledger,
        "key-2",
        valid_at.to_int64(),
        known_at.to_int64(),
      )
      assert_eq(
        ledger.get("key-2", valid_at.to_int64(), known_at.to_int64()),
        expected,
      )
    }
  }
}
