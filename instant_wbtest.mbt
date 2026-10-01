///|
test "canonical instant roundtrips signed boundaries" {
  let values = [
    -9223372036854775807L - 1L,
    -100L,
    -1L,
    0L,
    1L,
    100L,
    9223372036854775807L,
  ]
  for value in values {
    assert_eq(parse_instant(format_instant(value)), value)
  }
}

///|
test "instant parser rejects ambiguous spellings and overflow" {
  let invalid = [
    "",
    "-",
    "+1",
    "00",
    "01",
    "-0",
    "-01",
    "1 ",
    " 1",
    "9223372036854775808",
    "-9223372036854775809",
  ]
  for input in invalid {
    let rejected = try parse_instant(input) catch {
      _ => true
    } noraise {
      _ => false
    }
    assert_true(rejected)
  }
}
