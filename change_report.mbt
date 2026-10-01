///|
/// Every changed valid-time fragment for one key. Fragments are ordered by
/// valid-time start and never overlap.
pub struct KeyChangeReport {
  key : String
  fragments : Array[WindowChange]
}

///|
pub fn KeyChangeReport::key(self : KeyChangeReport) -> String {
  self.key
}

///|
pub fn KeyChangeReport::fragments(
  self : KeyChangeReport,
) -> Array[WindowChange] {
  self.fragments.copy()
}

///|
pub fn KeyChangeReport::fragment_count(self : KeyChangeReport) -> Int {
  self.fragments.length()
}

///|
/// Bounded blast-radius report across all keys in two independent ledgers.
/// Entries are sorted by key; a key appears only when its effective value
/// differs on at least one valid-time fragment.
pub struct ChangeReport {
  entries : Array[KeyChangeReport]
  keys_examined : Int
  fragments : Int
  bounds : Span
  before_known : Int64
  after_known : Int64
}

///|
pub fn ChangeReport::entries(self : ChangeReport) -> Array[KeyChangeReport] {
  self.entries.copy()
}

///|
pub fn ChangeReport::keys_examined(self : ChangeReport) -> Int {
  self.keys_examined
}

///|
pub fn ChangeReport::keys_changed(self : ChangeReport) -> Int {
  self.entries.length()
}

///|
pub fn ChangeReport::fragment_count(self : ChangeReport) -> Int {
  self.fragments
}

///|
pub fn ChangeReport::bounds(self : ChangeReport) -> Span {
  self.bounds
}

///|
pub fn ChangeReport::before_known(self : ChangeReport) -> Int64 {
  self.before_known
}

///|
pub fn ChangeReport::after_known(self : ChangeReport) -> Int64 {
  self.after_known
}

///|
pub fn ChangeReport::is_empty(self : ChangeReport) -> Bool {
  self.entries.is_empty()
}

///|
fn union_ledger_keys(
  before : Ledger,
  after : Ledger,
  max_keys : Int,
) -> Array[String] raise TemporalError {
  if max_keys < 0 {
    raise TooManyKeys(maximum=max_keys)
  }
  let keys = before.keys()
  for key in after.keys() {
    keys.push(key)
  }
  keys.sort_by(fn(a, b) { a.lexical_compare(b) })
  let unique : Array[String] = []
  for key in keys {
    if unique.is_empty() || unique[unique.length() - 1] != key {
      if unique.length() >= max_keys {
        raise TooManyKeys(maximum=max_keys)
      }
      unique.push(key)
    }
  }
  unique
}

///|
/// Compare effective values across every key and a bounded valid-time window.
/// Limits are checked before unbounded reports can be returned; callers should
/// split large domains by key or valid-time range when a limit is reached.
pub fn compare_all_keys(
  before : Ledger,
  after : Ledger,
  bounds : Span,
  before_known : Int64,
  after_known : Int64,
  max_keys? : Int = 10000,
  max_fragments? : Int = 10000,
) -> ChangeReport raise TemporalError {
  if max_fragments <= 0 {
    raise TooManySegments(maximum=max_fragments)
  }
  let keys = union_ledger_keys(before, after, max_keys)
  let entries : Array[KeyChangeReport] = []
  let mut fragments = 0
  for key in keys {
    let differences = compare_ledgers(
      before,
      after,
      key,
      bounds,
      before_known,
      after_known,
      max_segments=max_fragments,
    )
    if !differences.is_empty() {
      if differences.length() > max_fragments - fragments {
        raise TooManySegments(maximum=max_fragments)
      }
      fragments = fragments + differences.length()
      entries.push({ key, fragments: differences, })
    }
  }
  {
    entries,
    keys_examined: keys.length(),
    fragments,
    bounds,
    before_known,
    after_known,
  }
}

///|
/// Run the same blast-radius comparison against two knowledge-time views of
/// a single append-only ledger.
pub fn Ledger::change_report(
  self : Ledger,
  bounds : Span,
  before_known : Int64,
  after_known : Int64,
  max_keys? : Int = 10000,
  max_fragments? : Int = 10000,
) -> ChangeReport raise TemporalError {
  compare_all_keys(
    self,
    self,
    bounds,
    before_known,
    after_known,
    max_keys~,
    max_fragments~,
  )
}
