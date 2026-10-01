///|
/// Aggregate operational metadata. Values and keys are not included except
/// for the most revised key, so callers can log counts separately from data.
pub struct LedgerStats {
  revisions : Int
  keys : Int
  batches : Int
  tombstones : Int
  open_valid_spans : Int
  most_revised_key : String?
  most_revisions_for_key : Int
  first_knowledge_time : Int64?
  latest_knowledge_time : Int64?
}

///|
pub fn LedgerStats::revisions(self : LedgerStats) -> Int { self.revisions }

///|
pub fn LedgerStats::keys(self : LedgerStats) -> Int { self.keys }

///|
pub fn LedgerStats::batches(self : LedgerStats) -> Int { self.batches }

///|
pub fn LedgerStats::tombstones(self : LedgerStats) -> Int { self.tombstones }

///|
pub fn LedgerStats::open_valid_spans(self : LedgerStats) -> Int {
  self.open_valid_spans
}

///|
pub fn LedgerStats::most_revised_key(self : LedgerStats) -> String? {
  self.most_revised_key
}

///|
pub fn LedgerStats::most_revisions_for_key(self : LedgerStats) -> Int {
  self.most_revisions_for_key
}

///|
pub fn LedgerStats::first_knowledge_time(self : LedgerStats) -> Int64? {
  self.first_knowledge_time
}

///|
pub fn LedgerStats::latest_knowledge_time(self : LedgerStats) -> Int64? {
  self.latest_knowledge_time
}

///|
/// Scan the append log once for statistics useful to storage adapters.
pub fn Ledger::stats(self : Ledger) -> LedgerStats {
  let counts : Map[String, Int] = Map([])
  let mut batches = 0
  let mut tombstones = 0
  let mut open_valid_spans = 0
  let mut most_revised_key : String? = None
  let mut most_revisions_for_key = 0
  let mut previous_time : Int64? = None
  for revision in self.revisions {
    if previous_time != Some(revision.known_at) {
      batches = batches + 1
      previous_time = Some(revision.known_at)
    }
    if revision.value is None {
      tombstones = tombstones + 1
    }
    if revision.valid.end is None {
      open_valid_spans = open_valid_spans + 1
    }
    let count = match counts.get(revision.key) {
      Some(previous) => previous + 1
      None => 1
    }
    counts[revision.key] = count
    if count > most_revisions_for_key ||
      (count == most_revisions_for_key && (match most_revised_key {
        Some(previous) => revision.key.lexical_compare(previous) < 0
        None => true
      })) {
      most_revisions_for_key = count
      most_revised_key = Some(revision.key)
    }
  }
  let first_knowledge_time = if self.revisions.is_empty() {
    None
  } else {
    Some(self.revisions[0].known_at)
  }
  {
    revisions: self.revisions.length(),
    keys: counts.length(),
    batches,
    tombstones,
    open_valid_spans,
    most_revised_key,
    most_revisions_for_key,
    first_knowledge_time,
    latest_knowledge_time: self.latest_time,
  }
}
