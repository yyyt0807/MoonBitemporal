///|
/// Compare revision content while ignoring the local sequence field, which
/// is derived from append position. A common prefix must agree in every
/// semantically relevant field, including tombstones and valid endpoints.
fn same_revision_claim(left : Revision, right : Revision) -> Bool {
  left.key == right.key &&
  left.valid.start == right.valid.start &&
  left.valid.end == right.valid.end &&
  left.known_at == right.known_at &&
  left.value == right.value
}

///|
/// Reconcile a full remote archive with local state. If one log is an exact
/// prefix of the other, return the longer log as a detached local ledger.
/// Divergent shared history is rejected at the first differing sequence.
/// This operation provides content consistency, not cryptographic integrity;
/// transport authentication and durable transaction ordering belong to callers.
pub fn Ledger::reconcile(
  self : Ledger,
  remote : Ledger,
) -> Ledger raise TemporalError {
  let common = if self.revisions.length() < remote.revisions.length() {
    self.revisions.length()
  } else {
    remote.revisions.length()
  }
  for index = 0; index < common; index = index + 1 {
    if !same_revision_claim(self.revisions[index], remote.revisions[index]) {
      raise DivergentHistory(index~)
    }
  }
  let winner = if self.revisions.length() >= remote.revisions.length() {
    self
  } else {
    remote
  }
  if winner.revisions.length() > self.maximum {
    raise TooManyRevisions(maximum=self.maximum)
  }
  let revisions = winner.revisions.copy()
  {
    revisions,
    index: build_index(revisions),
    latest_time: winner.latest_time,
    maximum: self.maximum,
  }
}

///|
/// Return the first divergent position if the archives disagree, or `None`
/// when either archive is a prefix of the other.
pub fn Ledger::first_divergence(self : Ledger, other : Ledger) -> Int? {
  let common = if self.revisions.length() < other.revisions.length() {
    self.revisions.length()
  } else {
    other.revisions.length()
  }
  for index = 0; index < common; index = index + 1 {
    if !same_revision_claim(self.revisions[index], other.revisions[index]) {
      return Some(index)
    }
  }
  None
}

///|
/// Whether this ledger's entire sequence is an exact prefix of `other`.
pub fn Ledger::is_prefix_of(self : Ledger, other : Ledger) -> Bool {
  self.revisions.length() <= other.revisions.length() &&
  self.first_divergence(other) is None
}
