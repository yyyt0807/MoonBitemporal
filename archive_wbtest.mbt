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
