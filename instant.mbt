///|
/// Parse a canonical signed 64-bit decimal instant without floating-point loss.
pub fn parse_instant(text : String) -> Int64 raise TemporalError {
  if text.length() == 0 {
    raise InvalidInstant("empty decimal instant")
  }
  let negative = text[0] == '-'
  let first = if negative { 1 } else { 0 }
  if first == text.length() {
    raise InvalidInstant("missing decimal digits")
  }
  if text[first] == '0' && text.length() - first > 1 {
    raise InvalidInstant("leading zeros are not canonical")
  }
  if negative && text[first] == '0' {
    raise InvalidInstant("negative zero is not canonical")
  }
  let limit = if negative {
    -9223372036854775807L - 1L
  } else {
    -9223372036854775807L
  }
  let mut value = 0L
  for i = first; i < text.length(); i = i + 1 {
    let char = text[i]
    if char < '0' || char > '9' {
      raise InvalidInstant("nondecimal character")
    }
    let digit = (char.to_int() - '0'.to_int()).to_int64()
    if value < (limit + digit) / 10L {
      raise InvalidInstant("signed 64-bit overflow")
    }
    value = value * 10L - digit
  }
  if negative {
    value
  } else {
    -value
  }
}

///|
pub fn format_instant(value : Int64) -> String {
  value.to_string()
}
