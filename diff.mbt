///|
/// Value-level change between two chosen views of the same set of keys.
pub struct ValueChange {
  key : String
  before : String?
  after : String?
  before_source : Revision?
  after_source : Revision?
}

///|
pub fn ValueChange::key(self : ValueChange) -> String {
  self.key
}

///|
pub fn ValueChange::before(self : ValueChange) -> String? {
  self.before
}

///|
pub fn ValueChange::after(self : ValueChange) -> String? {
  self.after
}

///|
pub fn ValueChange::before_source(self : ValueChange) -> Revision? {
  self.before_source
}

///|
pub fn ValueChange::after_source(self : ValueChange) -> Revision? {
  self.after_source
}

///|
fn observed_value(source : Revision?) -> String? {
  match source {
    Some(revision) => revision.value
    None => None
  }
}

///|
/// Compare what was believed at two knowledge times for one valid instant.
pub fn Ledger::diff_knowledge(
  self : Ledger,
  valid_at : Int64,
  before_at : Int64,
  after_at : Int64,
) -> Array[ValueChange] {
  let output : Array[ValueChange] = []
  for key in self.keys() {
    let before_source = self.observe(key, valid_at, before_at)
    let after_source = self.observe(key, valid_at, after_at)
    let before = observed_value(before_source)
    let after = observed_value(after_source)
    if before != after {
      output.push({ key, before, after, before_source, after_source })
    }
  }
  output
}

///|
/// Compare two valid instants according to one knowledge-time view.
pub fn Ledger::diff_valid(
  self : Ledger,
  before_at : Int64,
  after_at : Int64,
  known_at : Int64,
) -> Array[ValueChange] {
  let output : Array[ValueChange] = []
  for key in self.keys() {
    let before_source = self.observe(key, before_at, known_at)
    let after_source = self.observe(key, after_at, known_at)
    let before = observed_value(before_source)
    let after = observed_value(after_source)
    if before != after {
      output.push({ key, before, after, before_source, after_source })
    }
  }
  output
}
