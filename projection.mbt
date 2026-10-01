///|
fn projected_ledger(source : Ledger, selected : Array[Revision]) -> Ledger {
  let revisions : Array[Revision] = []
  for item in selected {
    revisions.push({
      key: item.key,
      valid: item.valid,
      known_at: item.known_at,
      value: item.value,
      sequence: revisions.length(),
    })
  }
  let latest_time = if revisions.is_empty() {
    None
  } else {
    Some(revisions[revisions.length() - 1].known_at)
  }
  {
    revisions,
    index: build_index(revisions),
    latest_time,
    maximum: source.maximum,
  }
}

///|
/// Materialize the ledger prefix known at or before a chosen instant. The
/// resulting ledger can be archived independently, preserving earlier views.
pub fn Ledger::as_known_at(self : Ledger, cutoff : Int64) -> Ledger {
  let selected : Array[Revision] = []
  for revision in self.revisions {
    if revision.known_at > cutoff {
      break
    }
    selected.push(revision)
  }
  projected_ledger(self, selected)
}

///|
/// Materialize only requested keys. Sequence numbers are renumbered in the
/// projection; knowledge instants and valid spans retain their original values.
pub fn Ledger::select_keys(self : Ledger, keys : Array[String]) -> Ledger {
  let selected_keys : Map[String, Bool] = Map([])
  for key in keys {
    selected_keys[key] = true
  }
  let selected : Array[Revision] = []
  for revision in self.revisions {
    if selected_keys.contains(revision.key) {
      selected.push(revision)
    }
  }
  projected_ledger(self, selected)
}

///|
/// The number of revisions about a key, independent of current visibility.
pub fn Ledger::history_count(self : Ledger, key : String) -> Int {
  match self.index.get(key) {
    Some(positions) => positions.length()
    None => 0
  }
}
