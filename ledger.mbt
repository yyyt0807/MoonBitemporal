///|
/// Immutable, append-only revision ledger. A successful commit returns a new ledger.
pub struct Ledger {
  revisions : Array[Revision]
  index : Map[String, Array[Int]]
  latest_time : Int64?
  maximum : Int
}

///|
pub fn Ledger::new(maximum? : Int = 1000000) -> Ledger raise TemporalError {
  if maximum <= 0 {
    raise TooManyRevisions(maximum~)
  }
  { revisions: [], index: Map([]), latest_time: None, maximum }
}

///|
/// Build a private index instead of sharing mutable per-key arrays between ledgers.
fn build_index(revisions : Array[Revision]) -> Map[String, Array[Int]] {
  let index : Map[String, Array[Int]] = Map([])
  for i, revision in revisions {
    match index.get(revision.key) {
      Some(positions) => positions.push(i)
      None => index[revision.key] = [i]
    }
  }
  index
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
  validate_batch_changes(changes)
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
  {
    revisions,
    index: build_index(revisions),
    latest_time: Some(known_at),
    maximum: self.maximum,
  }
}

///|
/// The winning claim at both selected instants, including a tombstone if present.
pub fn Ledger::observe(
  self : Ledger,
  key : String,
  valid_at : Int64,
  known_at : Int64,
) -> Revision? {
  match self.index.get(key) {
    Some(positions) => {
      for i = positions.length() - 1; i >= 0; i = i - 1 {
        let revision = self.revisions[positions[i]]
        if revision.known_at <= known_at && revision.valid.contains(valid_at) {
          return Some(revision)
        }
      }
    }
    None => ()
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
  match self.index.get(key) {
    Some(positions) => {
      for position in positions {
        result.push(self.revisions[position])
      }
    }
    None => ()
  }
  result
}
