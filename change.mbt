///|
/// A value assignment or tombstone before it is committed.
pub struct Change {
  key : String
  valid : Span
  value : String?
}

///|
pub fn Change::put(key : String, valid : Span, value : String) -> Change {
  { key, valid, value: Some(value) }
}

///|
pub fn Change::delete(key : String, valid : Span) -> Change {
  { key, valid, value: None }
}

///|
pub fn Change::key(self : Change) -> String {
  self.key
}

///|
pub fn Change::valid(self : Change) -> Span {
  self.valid
}

///|
pub fn Change::value(self : Change) -> String? {
  self.value
}

///|
/// A committed claim. Sequence is a stable, zero-based append position.
pub struct Revision {
  key : String
  valid : Span
  known_at : Int64
  value : String?
  sequence : Int
}

///|
pub fn Revision::key(self : Revision) -> String {
  self.key
}

///|
pub fn Revision::valid(self : Revision) -> Span {
  self.valid
}

///|
pub fn Revision::known_at(self : Revision) -> Int64 {
  self.known_at
}

///|
pub fn Revision::value(self : Revision) -> String? {
  self.value
}

///|
pub fn Revision::sequence(self : Revision) -> Int {
  self.sequence
}
