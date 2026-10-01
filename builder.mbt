///|
/// Efficient mutable ingest path for applications that accept many batches.
/// `Ledger::commit` is convenient for small immutable histories but copies the
/// previous log and rebuilds its index on every call. Builder appends in place
/// and makes an isolated immutable snapshot only when `freeze` is requested.
pub struct LedgerBuilder {
  revisions : Array[Revision]
  index : Map[String, Array[Int]]
  mut latest_time : Int64?
  maximum : Int
  mut batches : Int
}

///|
pub fn LedgerBuilder::new(
  maximum? : Int = 1000000,
) -> LedgerBuilder raise TemporalError {
  if maximum <= 0 {
    raise TooManyRevisions(maximum~)
  }
  { revisions: [], index: Map([]), latest_time: None, maximum, batches: 0, }
}

///|
/// Continue ingesting after an immutable checkpoint. Arrays are copied so
/// subsequent builder appends cannot mutate the supplied ledger.
pub fn LedgerBuilder::from_ledger(source : Ledger) -> LedgerBuilder {
  let revisions = source.revisions.copy()
  let mut batches = 0
  let mut previous : Int64? = None
  for revision in revisions {
    if previous != Some(revision.known_at) {
      batches = batches + 1
      previous = Some(revision.known_at)
    }
  }
  {
    revisions,
    index: build_index(revisions),
    latest_time: source.latest_time,
    maximum: source.maximum,
    batches,
  }
}

///|
pub fn LedgerBuilder::revision_count(self : LedgerBuilder) -> Int {
  self.revisions.length()
}

///|
pub fn LedgerBuilder::batch_count(self : LedgerBuilder) -> Int {
  self.batches
}

///|
pub fn LedgerBuilder::latest_time(self : LedgerBuilder) -> Int64? {
  self.latest_time
}

///|
pub fn LedgerBuilder::remaining_capacity(self : LedgerBuilder) -> Int {
  self.maximum - self.revisions.length()
}

///|
/// Validate all changes before modifying either the log or the per-key index.
/// On rejection, the builder retains its prior state.
pub fn LedgerBuilder::append(
  self : LedgerBuilder,
  known_at : Int64,
  changes : Array[Change],
) -> Unit raise TemporalError {
  if changes.is_empty() {
    raise EmptyBatch
  }
  match self.latest_time {
    Some(previous) if known_at <= previous =>
      raise KnowledgeTimeNotIncreasing(previous~, proposed=known_at)
    _ => ()
  }
  if changes.length() > self.remaining_capacity() {
    raise TooManyRevisions(maximum=self.maximum)
  }
  validate_batch_changes(changes)
  for change in changes {
    let sequence = self.revisions.length()
    self.revisions.push({
      key: change.key,
      valid: change.valid,
      known_at,
      value: change.value,
      sequence,
    })
    match self.index.get(change.key) {
      Some(positions) => positions.push(sequence)
      None => self.index[change.key] = [sequence]
    }
  }
  self.latest_time = Some(known_at)
  self.batches = self.batches + 1
}

///|
/// Return a detached immutable checkpoint. Keeping this value while appending
/// further batches to the builder is safe.
pub fn LedgerBuilder::freeze(self : LedgerBuilder) -> Ledger {
  let revisions = self.revisions.copy()
  {
    revisions,
    index: build_index(revisions),
    latest_time: self.latest_time,
    maximum: self.maximum,
  }
}

///|
/// Query the current builder without allocating a full ledger checkpoint.
pub fn LedgerBuilder::observe(
  self : LedgerBuilder,
  key : String,
  valid_at : Int64,
  known_at : Int64,
) -> Revision? {
  match self.index.get(key) {
    Some(positions) => {
      let eligible = key_upper_bound(self.revisions, positions, known_at, true)
      for i = eligible - 1; i >= 0; i = i - 1 {
        let revision = self.revisions[positions[i]]
        if revision.valid.contains(valid_at) {
          return Some(revision)
        }
      }
    }
    None => ()
  }
  None
}

///|
pub fn LedgerBuilder::get(
  self : LedgerBuilder,
  key : String,
  valid_at : Int64,
  known_at : Int64,
) -> String? {
  observed_value(self.observe(key, valid_at, known_at))
}
