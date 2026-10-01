///|
test "archive retains full-range instants and correction history" {
  let base = try! Ledger::new()
  let first = try! base.commit(
    -9223372036854775807L - 1L,
    [Change::put("price", Span::open(-5L), "初始")],
  )
  let second = try! first.commit(
    9223372036854775807L,
    [Change::put("price", try! Span::new(0L, 1L), "更正")],
  )
  let encoded = second.to_json_string()
  let parsed = @json.parse(encoded)
  let restored = try! Ledger::from_json(parsed)
  assert_eq(restored.revision_count(), 2)
  assert_eq(restored.get("price", 0L, 0L), Some("初始"))
  assert_eq(restored.get("price", 0L, 9223372036854775807L), Some("更正"))
  assert_eq(restored.to_json_string(), encoded)
}

///|
test "archive rejects unknown fields and invalid ranges" {
  let unknown = @json.parse("{\"schemaVersion\":1,\"revisions\":[],\"extra\":true}")
  let invalid = @json.parse("{\"schemaVersion\":1,\"revisions\":[{\"knownAt\":\"1\",\"key\":\"x\",\"validFrom\":\"3\",\"validTo\":\"2\",\"value\":\"a\"}]}")
  let a = try Ledger::from_json(unknown) catch {
    _ => true
  } noraise {
    _ => false
  }
  let b = try Ledger::from_json(invalid) catch {
    _ => true
  } noraise {
    _ => false
  }
  assert_true(a)
  assert_true(b)
}

///|
test "bulk archive import retains hundreds of sequential knowledge batches" {
  let mut source = try! Ledger::new(maximum=1000)
  for i = 0; i < 500; i = i + 1 {
    source = source.commit(
      i.to_int64(),
      [Change::put("k", Span::open(0L), i.to_string())],
    )
  }
  let archive = source.to_json_string()
  let restored = try! Ledger::from_json_string(archive, maximum=1000)
  assert_eq(restored.revision_count(), 500)
  assert_eq(restored.get("k", 0L, 299L), Some("299"))
  assert_eq(restored.get("k", 0L, 499L), Some("499"))
  assert_eq(restored.to_json_string(), archive)
}

///|
test "archive rejects out-of-order batches and oversized revision count" {
  let reversed = "{\"schemaVersion\":1,\"revisions\":[{\"knownAt\":\"2\",\"key\":\"k\",\"validFrom\":\"0\",\"validTo\":null,\"value\":\"a\"},{\"knownAt\":\"1\",\"key\":\"k\",\"validFrom\":\"0\",\"validTo\":null,\"value\":\"b\"}]}"
  let order_error = try Ledger::from_json_string(reversed) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  let limit_error = try Ledger::from_json_string(reversed, maximum=1) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  assert_eq(order_error, "TEMPORAL_KNOWLEDGE_ORDER")
  assert_eq(limit_error, "TEMPORAL_REVISION_LIMIT")
}
