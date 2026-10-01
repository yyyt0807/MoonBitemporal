///|
/// A validated commit and its value-level impact. The original ledger remains
/// usable, so callers may inspect the report before choosing to retain `next`.
pub struct CommitReport {
  next : Ledger
  impacts : Array[Impact]
  known_at : Int64
  appended : Int
}

///|
pub fn CommitReport::next(self : CommitReport) -> Ledger {
  self.next
}

///|
pub fn CommitReport::impacts(self : CommitReport) -> Array[Impact] {
  self.impacts.copy()
}

///|
pub fn CommitReport::known_at(self : CommitReport) -> Int64 {
  self.known_at
}

///|
pub fn CommitReport::appended(self : CommitReport) -> Int {
  self.appended
}

///|
pub fn CommitReport::changed_fragment_count(self : CommitReport) -> Int {
  self.impacts.length()
}

///|
/// Prepare an atomic batch and report exactly which value fragments would
/// change. Retain `report.next()` to accept it, or discard it to dry-run.
pub fn Ledger::commit_with_report(
  self : Ledger,
  known_at : Int64,
  changes : Array[Change],
  max_impacts? : Int = 4096,
) -> CommitReport raise TemporalError {
  if max_impacts <= 0 {
    raise TooManySegments(maximum=max_impacts)
  }
  let first_new = self.revision_count()
  let next = self.commit(known_at, changes)
  let impacts : Array[Impact] = []
  for index = first_new; index < next.revision_count(); index = index + 1 {
    for item in next.impact_of_revision(index, max_segments=max_impacts) {
      if impacts.length() >= max_impacts {
        raise TooManySegments(maximum=max_impacts)
      }
      impacts.push(item)
    }
  }
  { next, impacts, known_at, appended: changes.length(), }
}
