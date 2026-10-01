///|
test "sweep timeline agrees with point queries after many overlapping claims" {
  let mut ledger = try! Ledger::new()
  for i = 0; i < 80; i = i + 1 {
    let start = (i * 7 % 51).to_int64()
    let end = start + 10L + (i % 13).to_int64()
    ledger = ledger.commit(i.to_int64(), [
      Change::put("k", try! Span::new(start, end), i.to_string()),
    ])
  }
  let segments = ledger.timeline("k", try! Span::new(0L, 100L), 79L)
  assert_true(segments.length() < 161)
  for instant = 0; instant < 100; instant = instant + 1 {
    let mut from_timeline : String? = None
    for segment in segments {
      if segment.valid().contains(instant.to_int64()) {
        from_timeline = segment.value()
      }
    }
    assert_eq(from_timeline, ledger.get("k", instant.to_int64(), 79L))
  }
}
