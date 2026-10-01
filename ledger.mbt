///|
/// Immutable, append-only revision ledger. A successful commit returns a new ledger.
pub struct Ledger {
  revisions : Array[Revision]
  latest_time : Int64?
  maximum : Int
}

///|
pub fn Ledger::new(maximum? : Int = 1000000) -> Ledger raise TemporalError {
  if maximum <= 0 {
    raise TooManyRevisions(maximum~)
  }
  { revisions: [], latest_time: None, maximum }
}

///|
pub fn Ledger::revision_count(self : Ledger) -> Int {
  self.revisions.length()
}

///|
pub fn Ledger::latest_time(self : Ledger) -> Int64? {
  self.latest_time
}

///|
pub fn Ledger::revision(self : Ledger, index : Int) -> Revision? {
  self.revisions.get(index)
}

///|
/// Validate the entire batch before appending any revision.
pub fn Ledger::commit(
  self : Ledger,
  known_at : Int64,
  changes : Array[Change],
) -> Ledger raise TemporalError {
  if changes.is_empty() {
    raise EmptyBatch
  }
  match self.latest_time {
    Some(previous) if known_at <= previous =>
      raise KnowledgeTimeNotIncreasing(previous~, proposed=known_at)
    _ => ()
  }
  if changes.length() > self.maximum - self.revisions.length() {
    raise TooManyRevisions(maximum=self.maximum)
  }
  for i, change in changes {
    if change.key == "" {
      raise EmptyKey
    }
    for j = 0; j < i; j = j + 1 {
      if change.key == changes[j].key && change.valid.overlaps(changes[j].valid) {
        raise OverlappingBatchChanges(key=change.key, first=j, second=i)
      }
    }
  }
  let revisions = self.revisions.copy()
  for change in changes {
    revisions.push({
      key: change.key,
      valid: change.valid,
      known_at,
      value: change.value,
      sequence: revisions.length(),
    })
  }
  { revisions, latest_time: Some(known_at), maximum: self.maximum }
}

///|
/// The winning claim at both selected instants, including a tombstone if present.
pub fn Ledger::observe(
  self : Ledger,
  key : String,
  valid_at : Int64,
  known_at : Int64,
) -> Revision? {
  for i = self.revisions.length() - 1; i >= 0; i = i - 1 {
    let revision = self.revisions[i]
    if revision.key == key && revision.known_at <= known_at &&
      revision.valid.contains(valid_at) {
      return Some(revision)
    }
  }
  None
}

///|
/// Return the effective value; both an absent claim and a tombstone yield `None`.
pub fn Ledger::get(
  self : Ledger,
  key : String,
  valid_at : Int64,
  known_at : Int64,
) -> String? {
  match self.observe(key, valid_at, known_at) {
    Some(revision) => revision.value
    None => None
  }
}

///|
/// All historical claims about one key, in append order.
pub fn Ledger::history(self : Ledger, key : String) -> Array[Revision] {
  let result : Array[Revision] = []
  for revision in self.revisions {
    if revision.key == key {
      result.push(revision)
    }
  }
  result
}
