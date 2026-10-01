///|
/// A visible keyed value in a single two-clock view.
pub struct Fact {
  key : String
  value : String
  source : Revision
}

///|
pub fn Fact::key(self : Fact) -> String {
  self.key
}

///|
pub fn Fact::value(self : Fact) -> String {
  self.value
}

///|
pub fn Fact::source(self : Fact) -> Revision {
  self.source
}

///|
/// Every distinct key in deterministic lexical order, including deleted keys.
pub fn Ledger::keys(self : Ledger) -> Array[String] {
  let values : Array[String] = []
  for revision in self.revisions {
    values.push(revision.key)
  }
  values.sort_by(fn(a, b) { a.compare(b) })
  let unique : Array[String] = []
  for key in values {
    if unique.is_empty() || unique[unique.length() - 1] != key {
      unique.push(key)
    }
  }
  unique
}

///|
/// Visible values at one valid and knowledge instant, sorted by key.
pub fn Ledger::snapshot(
  self : Ledger,
  valid_at : Int64,
  known_at : Int64,
) -> Array[Fact] {
  let facts : Array[Fact] = []
  for key in self.keys() {
    match self.observe(key, valid_at, known_at) {
      Some(source) => match source.value {
        Some(value) => facts.push({ key, value, source })
        None => ()
      }
      None => ()
    }
  }
  facts
}

///|
pub fn Ledger::contains_key(
  self : Ledger,
  key : String,
  valid_at : Int64,
  known_at : Int64,
) -> Bool {
  self.get(key, valid_at, known_at) is Some(_)
}

///|
/// Number of visible keyed facts at a two-clock point.
pub fn Ledger::visible_count(
  self : Ledger,
  valid_at : Int64,
  known_at : Int64,
) -> Int {
  self.snapshot(valid_at, known_at).length()
}
