///|
/// Structural JSON scanner used only to reject duplicate object members before
/// the standard parser folds them into a Map. Syntax is validated again by
/// `@json.parse`; this scanner enforces resource limits and key uniqueness.
priv struct JsonGuard {
  text : String
  mut offset : Int
  mut nodes : Int
  max_nodes : Int
  max_depth : Int
}

///|
fn JsonGuard::skip_space(self : JsonGuard) -> Unit {
  while self.offset < self.text.length() {
    match self.text[self.offset].to_int() {
      32 | 9 | 10 | 13 => self.offset = self.offset + 1
      _ => break
    }
  }
}

///|
fn JsonGuard::at(self : JsonGuard, ascii : Int) -> Bool {
  self.offset < self.text.length() && self.text[self.offset].to_int() == ascii
}

///|
fn JsonGuard::consume(self : JsonGuard, ascii : Int) -> Bool {
  if self.at(ascii) {
    self.offset = self.offset + 1
    true
  } else {
    false
  }
}

///|
fn JsonGuard::quoted(self : JsonGuard) -> String raise TemporalError {
  if !self.consume(34) {
    raise InvalidArchive("expected JSON string")
  }
  let start = self.offset - 1
  while self.offset < self.text.length() {
    let code = self.text[self.offset].to_int()
    if code == 34 {
      self.offset = self.offset + 1
      let key_json = @json.parse(self.text[start:self.offset]) catch {
        _ => raise InvalidArchive("malformed JSON string")
      }
      return match key_json {
        String(value) => value
        _ => raise InvalidArchive("malformed JSON string")
      }
    }
    if code == 92 {
      self.offset = self.offset + 2
    } else {
      self.offset = self.offset + 1
    }
  }
  raise InvalidArchive("unterminated JSON string")
}

///|
fn JsonGuard::scan_object(
  self : JsonGuard,
  depth : Int,
) -> Unit raise TemporalError {
  ignore(self.consume(123))
  self.skip_space()
  if self.consume(125) {
    return
  }
  let seen : Map[String, Bool] = Map([])
  while true {
    let key = self.quoted()
    if seen.contains(key) {
      raise DuplicateArchiveKey
    }
    seen[key] = true
    self.skip_space()
    if !self.consume(58) {
      raise InvalidArchive("expected colon after object key")
    }
    self.scan_value(depth)
    self.skip_space()
    if self.consume(125) {
      return
    }
    if !self.consume(44) {
      raise InvalidArchive("expected comma between object members")
    }
    self.skip_space()
  }
}

///|
fn JsonGuard::scan_array(
  self : JsonGuard,
  depth : Int,
) -> Unit raise TemporalError {
  ignore(self.consume(91))
  self.skip_space()
  if self.consume(93) {
    return
  }
  while true {
    self.scan_value(depth)
    self.skip_space()
    if self.consume(93) {
      return
    }
    if !self.consume(44) {
      raise InvalidArchive("expected comma between array elements")
    }
    self.skip_space()
  }
}

///|
fn JsonGuard::scan_atom(self : JsonGuard) -> Unit raise TemporalError {
  let start = self.offset
  while self.offset < self.text.length() {
    let code = self.text[self.offset].to_int()
    if code == 44 ||
      code == 93 ||
      code == 125 ||
      code == 32 ||
      code == 9 ||
      code == 10 ||
      code == 13 {
      break
    }
    self.offset = self.offset + 1
  }
  if self.offset == start {
    raise InvalidArchive("empty JSON atom")
  }
}

///|
fn JsonGuard::scan_value(
  self : JsonGuard,
  depth : Int,
) -> Unit raise TemporalError {
  if depth > self.max_depth {
    raise InvalidArchive("JSON nesting limit exceeded")
  }
  self.nodes = self.nodes + 1
  if self.nodes > self.max_nodes {
    raise InvalidArchive("JSON node limit exceeded")
  }
  self.skip_space()
  if self.at(123) {
    self.scan_object(depth + 1)
  } else if self.at(91) {
    self.scan_array(depth + 1)
  } else if self.at(34) {
    ignore(self.quoted())
  } else {
    self.scan_atom()
  }
}

///|
fn reject_duplicate_json_keys(text : String) -> Unit raise TemporalError {
  let scanner = JsonGuard::{
    text,
    offset: 0,
    nodes: 0,
    max_nodes: 1000000,
    max_depth: 128,
  }
  scanner.scan_value(0)
  scanner.skip_space()
  if scanner.offset != text.length() {
    raise InvalidArchive("trailing JSON content")
  }
}
