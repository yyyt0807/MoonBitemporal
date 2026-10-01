///|
test "latest representable instant can be queried in an open valid span" {
  let base = try! Ledger::new()
  let earliest = -9223372036854775807L - 1L
  let latest = 9223372036854775807L
  let ledger = try! base.commit(
    earliest,
    [Change::put("edge", Span::open(latest), "present")],
  )
  assert_eq(ledger.get("edge", latest, earliest), Some("present"))
  assert_eq(ledger.get("edge", latest - 1L, earliest), None)
  let timeline = try! ledger.timeline("edge", Span::open(latest - 1L), earliest)
  assert_eq(timeline.length(), 2)
  assert_eq(timeline[0].valid().end(), Some(latest))
  assert_eq(timeline[1].valid().end(), None)
  assert_eq(timeline[1].value(), Some("present"))
}

///|
test "same-instant adjacent batch changes remain distinct and ordered" {
  let builder = try! LedgerBuilder::new()
  builder.append(
    10L,
    [
      Change::put("k", try! Span::new(0L, 5L), "left"),
      Change::put("k", try! Span::new(5L, 10L), "right"),
    ],
  )
  let ledger = builder.freeze()
  assert_eq(ledger.stats().batches(), 1)
  assert_eq(ledger.history_count("k"), 2)
  assert_eq(ledger.get("k", 4L, 10L), Some("left"))
  assert_eq(ledger.get("k", 5L, 10L), Some("right"))
  let restored = try! Ledger::from_json_string(ledger.to_json_string())
  assert_eq(restored.to_json_string(), ledger.to_json_string())
}

///|
test "builder and immutable commits agree across generated batches" {
  let builder = try! LedgerBuilder::new(maximum=500)
  let mut immutable = try! Ledger::new(maximum=500)
  for i = 0; i < 120; i = i + 1 {
    let key = "k" + (i % 4).to_string()
    let start = (i * 17 % 60).to_int64()
    let end = start + (i % 9 + 1).to_int64()
    let change = if i % 11 == 0 {
      Change::delete(key, try! Span::new(start, end))
    } else {
      Change::put(key, try! Span::new(start, end), i.to_string())
    }
    builder.append(i.to_int64(), [change])
    immutable = immutable.commit(i.to_int64(), [change])
  }
  let built = builder.freeze()
  assert_eq(built.to_json_string(), immutable.to_json_string())
  for key_index = 0; key_index < 4; key_index = key_index + 1 {
    let key = "k" + key_index.to_string()
    for valid_at = 0; valid_at < 70; valid_at = valid_at + 5 {
      for known_at = 0; known_at < 120; known_at = known_at + 13 {
        assert_eq(
          builder.get(key, valid_at.to_int64(), known_at.to_int64()),
          immutable.get(key, valid_at.to_int64(), known_at.to_int64()),
        )
      }
    }
  }
}
