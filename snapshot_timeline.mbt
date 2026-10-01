///|
/// One valid-time slice with the visible facts for the requested key set.
pub struct SnapshotSegment {
  valid : Span
  facts : Array[Fact]
}

///|
pub fn SnapshotSegment::valid(self : SnapshotSegment) -> Span {
  self.valid
}

///|
pub fn SnapshotSegment::facts(self : SnapshotSegment) -> Array[Fact] {
  self.facts.copy()
}

///|
pub fn SnapshotSegment::value(self : SnapshotSegment, key : String) -> String? {
  for fact in self.facts {
    if fact.key == key {
      return Some(fact.value)
    }
  }
  None
}

///|
fn unique_query_keys(keys : Array[String], max_keys : Int) -> Array[String] raise TemporalError {
  if max_keys < 0 {
    raise TooManyKeys(maximum=max_keys)
  }
  let sorted = keys.copy()
  sorted.sort_by(fn(a, b) { a.lexical_compare(b) })
  let unique : Array[String] = []
  for key in sorted {
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
/// Reconstruct simultaneous facts for a bounded set of keys across a valid
/// window. Boundaries are emitted whenever any requested key's source changes.
pub fn Ledger::snapshot_timeline(
  self : Ledger,
  keys : Array[String],
  bounds : Span,
  known_at : Int64,
  max_keys? : Int = 64,
  max_segments? : Int = 4096,
) -> Array[SnapshotSegment] raise TemporalError {
  if max_segments <= 0 {
    raise TooManySegments(maximum=max_segments)
  }
  let selected = unique_query_keys(keys, max_keys)
  let points : Array[Int64] = [bounds.start]
  for key in selected {
    for segment in self.timeline(key, bounds, known_at, max_segments~) {
      points.push(segment.valid.start)
      match segment.valid.end {
        Some(end) => points.push(end)
        None => ()
      }
    }
  }
  match bounds.end {
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
  let output : Array[SnapshotSegment] = []
  for i = 0; i < unique.length(); i = i + 1 {
    let start = unique[i]
    let end = if i + 1 < unique.length() {
      Some(unique[i + 1])
    } else {
      bounds.end
    }
    if end == Some(start) ||
      (i + 1 == unique.length() && bounds.end is Some(_)) {
      continue
    }
    if output.length() >= max_segments {
      raise TooManySegments(maximum=max_segments)
    }
    let facts : Array[Fact] = []
    for key in selected {
      match self.observe(key, start, known_at) {
        Some(source) => match source.value {
          Some(value) => facts.push({ key, value, source })
          None => ()
        }
        None => ()
      }
    }
    output.push({ valid: { start, end }, facts })
  }
  output
}
