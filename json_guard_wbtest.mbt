///|
test "text archive rejects duplicate keys including escaped spellings" {
  let inputs = [
    "{\"schemaVersion\":1,\"schemaVersion\":1,\"revisions\":[]}", "{\"schemaVersion\":1,\"revisions\":[{\"knownAt\":\"1\",\"key\":\"x\",\"validFrom\":\"0\",\"validTo\":null,\"value\":\"a\",\"\\u0076alue\":\"b\"}]}",
  ]
  for input in inputs {
    let code = try Ledger::from_json_string(input) catch {
      error => error.code()
    } noraise {
      _ => "accepted"
    }
    assert_eq(code, "TEMPORAL_DUPLICATE_ARCHIVE_KEY")
  }
}

///|
test "text archive checks nesting and node budgets before decoding" {
  let mut deeply_nested = ""
  for i = 0; i < 140; i = i + 1 {
    deeply_nested = deeply_nested + "["
  }
  deeply_nested = deeply_nested + "0"
  for i = 0; i < 140; i = i + 1 {
    deeply_nested = deeply_nested + "]"
  }
  let rejected = try Ledger::from_json_string(deeply_nested) catch {
    _ => true
  } noraise {
    _ => false
  }
  assert_true(rejected)
}
