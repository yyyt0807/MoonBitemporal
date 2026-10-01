///|
/// Deliberately simple forward-scan model, independent of the key index and
/// sweep heap, used as a differential oracle for generated histories.
fn model_value(
  ledger : Ledger,
  key : String,
  valid_at : Int64,
  known_at : Int64,
) -> String? {
  let mut value : String? = None
  for revision in ledger.revisions {
    if revision.key == key && revision.known_at <= known_at &&
      revision.valid.contains(valid_at) {
      value = revision.value
    }
  }
  value
}

///|
fn generated_ledger() -> Ledger {
  let mut ledger = try! Ledger::new()
  for i = 0; i < 90; i = i + 1 {
    let key = "key-" + (i % 5).to_string()
    let start = (i * 37 % 83).to_int64()
    let end = start + (i * 11 % 18 + 1).to_int64()
    let span = try! Span::new(start, end)
    let change = if i % 9 == 0 {
      Change::delete(key, span)
    } else {
      Change::put(key, span, "value-" + (i % 7).to_string())
    }
    ledger = try! ledger.commit(i.to_int64(), [change])
  }
  ledger
}

///|
test "indexed point lookups agree with independent forward-scan model" {
  let ledger = generated_ledger()
  for key_index = 0; key_index < 5; key_index = key_index + 1 {
    let key = "key-" + key_index.to_string()
    for valid_at = 0; valid_at < 100; valid_at = valid_at + 3 {
      for known_at = 0; known_at < 90; known_at = known_at + 7 {
        let expected = model_value(
          ledger,
          key,
          valid_at.to_int64(),
          known_at.to_int64(),
        )
        assert_eq(
          ledger.get(key, valid_at.to_int64(), known_at.to_int64()),
          expected,
        )
      }
    }
  }
}

///|
test "sweep segments partition a window and match the model at each point" {
  let ledger = generated_ledger()
  for key_index = 0; key_index < 5; key_index = key_index + 1 {
    let key = "key-" + key_index.to_string()
    for known_at in [0L, 17L, 44L, 89L] {
      let segments = ledger.timeline(
        key,
        try! Span::new(0L, 100L),
        known_at,
      )
      assert_true(!segments.is_empty())
      assert_eq(segments[0].valid().start(), 0L)
      assert_eq(segments[segments.length() - 1].valid().end(), Some(100L))
      for i = 1; i < segments.length(); i = i + 1 {
        assert_eq(segments[i - 1].valid().end(), Some(segments[i].valid().start()))
      }
      for valid_at = 0; valid_at < 100; valid_at = valid_at + 1 {
        let mut matches = 0
        let mut actual : String? = None
        for segment in segments {
          if segment.valid().contains(valid_at.to_int64()) {
            matches = matches + 1
            actual = segment.value()
          }
        }
        assert_eq(matches, 1)
        assert_eq(actual, model_value(ledger, key, valid_at.to_int64(), known_at))
      }
    }
  }
}

///|
test "knowledge segments agree with point model across revisions" {
  let ledger = generated_ledger()
  for key_index = 0; key_index < 5; key_index = key_index + 1 {
    let key = "key-" + key_index.to_string()
    for valid_at in [0L, 20L, 45L, 80L] {
      let segments = ledger.knowledge_timeline(
        key,
        valid_at,
        try! Span::new(0L, 90L),
      )
      for known_at = 0; known_at < 90; known_at = known_at + 1 {
        let mut count = 0
        let mut actual : String? = None
        for segment in segments {
          if segment.known().contains(known_at.to_int64()) {
            count = count + 1
            actual = segment.value()
          }
        }
        assert_eq(count, 1)
        assert_eq(actual, model_value(ledger, key, valid_at, known_at.to_int64()))
      }
    }
  }
}

///|
test "archive and key projection preserve independently modeled values" {
  let ledger = generated_ledger()
  let restored = try! Ledger::from_json_string(ledger.to_json_string())
  assert_eq(restored.revision_count(), ledger.revision_count())
  for key_index = 0; key_index < 5; key_index = key_index + 1 {
    let key = "key-" + key_index.to_string()
    let subset = restored.select_keys([key])
    for valid_at = 0; valid_at < 100; valid_at = valid_at + 7 {
      for known_at in [0L, 20L, 50L, 89L] {
        let expected = model_value(ledger, key, valid_at.to_int64(), known_at)
        assert_eq(subset.get(key, valid_at.to_int64(), known_at), expected)
      }
    }
  }
}
