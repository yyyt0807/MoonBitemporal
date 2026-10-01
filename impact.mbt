///|
/// A valid-time fragment whose effective value changed because of one revision.
pub struct Impact {
  key : String
  valid : Span
  before : String?
  after : String?
  previous_source : Revision?
  revision : Revision
}

///|
pub fn Impact::key(self : Impact) -> String {
  self.key
}

///|
pub fn Impact::valid(self : Impact) -> Span {
  self.valid
}

///|
pub fn Impact::before(self : Impact) -> String? {
  self.before
}

///|
pub fn Impact::after(self : Impact) -> String? {
  self.after
}

///|
pub fn Impact::previous_source(self : Impact) -> Revision? {
  self.previous_source
}

///|
pub fn Impact::revision(self : Impact) -> Revision {
  self.revision
}

///|
fn before_revision(
  ledger : Ledger,
  key : String,
  valid_at : Int64,
  known_at : Int64,
) -> Revision? {
  match ledger.index.get(key) {
    Some(positions) => {
      for i = positions.length() - 1; i >= 0; i = i - 1 {
        let item = ledger.revisions[positions[i]]
        if item.known_at < known_at && item.valid.contains(valid_at) {
          return Some(item)
        }
      }
    }
    None => ()
  }
  None
}

///|
/// Partition one revision's declared valid span by prior claims and report only
/// fragments where the effective value changed. The current ledger may contain
/// later revisions; they do not affect this historical impact calculation.
pub fn Ledger::impact_of_revision(
  self : Ledger,
  index : Int,
  max_segments? : Int = 4096,
) -> Array[Impact] raise TemporalError {
  if max_segments <= 0 {
    raise TooManySegments(maximum=max_segments)
  }
  let target = match self.revision(index) {
    Some(revision) => revision
    None => raise InvalidRevisionIndex(index)
  }
  let points : Array[Int64] = [target.valid.start]
  for candidate in self.history(target.key) {
    if candidate.known_at < target.known_at {
      match candidate.valid.intersection(target.valid) {
        Some(clipped) => {
          if clipped.start > target.valid.start {
            points.push(clipped.start)
          }
          match clipped.end {
            Some(end) => points.push(end)
            None => ()
          }
        }
        None => ()
      }
    }
  }
  match target.valid.end {
    Some(end) => points.push(end)
    None => ()
  }
  points.sort_by(fn(a, b) { if a < b { -1 } else if a > b { 1 } else { 0 } })
  let unique : Array[Int64] = []
  for point in points {
    if unique.is_empty() || unique[unique.length() - 1] != point {
      unique.push(point)
    }
  }
  let output : Array[Impact] = []
  for i = 0; i < unique.length(); i = i + 1 {
    let start = unique[i]
    let end = if i + 1 < unique.length() {
      Some(unique[i + 1])
    } else {
      target.valid.end
    }
    if end == Some(start) ||
      (i + 1 == unique.length() && target.valid.end is Some(_)) {
      continue
    }
    let previous_source = before_revision(self, target.key, start, target.known_at)
    let before = observed_value(previous_source)
    if before == target.value {
      continue
    }
    if !output.is_empty() && output[output.length() - 1].valid.end == Some(start) &&
      same_source(output[output.length() - 1].previous_source, previous_source) {
      let last = output.length() - 1
      output[last] = {
        key: target.key,
        valid: { start: output[last].valid.start, end },
        before,
        after: target.value,
        previous_source,
        revision: target,
      }
    } else {
      if output.length() >= max_segments {
        raise TooManySegments(maximum=max_segments)
      }
      output.push({
        key: target.key,
        valid: { start, end },
        before,
        after: target.value,
        previous_source,
        revision: target,
      })
    }
  }
  output
}
