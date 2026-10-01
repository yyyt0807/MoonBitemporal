///|
/// Compare right endpoints, treating `None` as positive infinity.
fn end_before(left : Int64?, right : Int64?) -> Bool {
  match (left, right) {
    (Some(a), Some(b)) => a < b
    (Some(_), None) => true
    _ => false
  }
}

///|
fn end_at_or_before(left : Int64?, right : Int64?) -> Bool {
  left == right || end_before(left, right)
}

///|
pub fn Span::covers(self : Span, other : Span) -> Bool {
  self.start <= other.start && end_at_or_before(other.end, self.end)
}

///|
/// Difference of two spans, ordered by starting time.
pub fn Span::subtract(self : Span, other : Span) -> Array[Span] {
  let overlap = self.intersection(other)
  match overlap {
    None => [self]
    Some(shared) => {
      let result : Array[Span] = []
      if self.start < shared.start {
        result.push({ start: self.start, end: Some(shared.start) })
      }
      if end_before(shared.end, self.end) {
        match shared.end {
          Some(start) => result.push({ start, end: self.end })
          None => ()
        }
      }
      result
    }
  }
}

///|
/// Merge overlapping or adjacent spans; return `None` for disjoint spans.
pub fn Span::coalesce(self : Span, other : Span) -> Span? {
  if !self.overlaps(other) && !self.touches(other) {
    return None
  }
  let start = if self.start < other.start { self.start } else { other.start }
  let end = if end_before(self.end, other.end) { other.end } else { self.end }
  Some({ start, end })
}

///|
/// Clip an ordered collection against a bounding span and merge the result.
pub fn normalize_spans(input : Array[Span], bounds : Span) -> Array[Span] {
  let clipped : Array[Span] = []
  for span in input {
    match span.intersection(bounds) {
      Some(part) => clipped.push(part)
      None => ()
    }
  }
  clipped.sort_by(fn(a, b) {
    if a.start < b.start { -1 } else if a.start > b.start { 1 } else { 0 }
  })
  let result : Array[Span] = []
  for span in clipped {
    if result.is_empty() {
      result.push(span)
    } else {
      let last_index = result.length() - 1
      match result[last_index].coalesce(span) {
        Some(merged) => result[last_index] = merged
        None => result.push(span)
      }
    }
  }
  result
}

///|
/// The portions of `bounds` not covered by any input span.
pub fn gaps(input : Array[Span], bounds : Span) -> Array[Span] {
  let occupied = normalize_spans(input, bounds)
  let result : Array[Span] = []
  let mut cursor = bounds.start
  for span in occupied {
    if cursor < span.start {
      result.push({ start: cursor, end: Some(span.start) })
    }
    match span.end {
      Some(end) => cursor = end
      None => return result
    }
  }
  match bounds.end {
    Some(end) if cursor < end => result.push({ start: cursor, end: Some(end) })
    None => result.push({ start: cursor, end: None })
    _ => ()
  }
  result
}
