///|
/// One maximal interval on which the winning revision is constant.
pub struct Segment {
  valid : Span
  source : Revision?
}

///|
pub fn Segment::valid(self : Segment) -> Span {
  self.valid
}

///|
pub fn Segment::source(self : Segment) -> Revision? {
  self.source
}

///|
pub fn Segment::value(self : Segment) -> String? {
  match self.source {
    Some(revision) => revision.value
    None => None
  }
}

///|
pub fn Segment::is_gap(self : Segment) -> Bool {
  self.source is None
}

///|
pub fn Segment::is_deleted(self : Segment) -> Bool {
  match self.source {
    Some(revision) => revision.value is None
    None => false
  }
}

///|
fn same_source(left : Revision?, right : Revision?) -> Bool {
  match (left, right) {
    (None, None) => true
    (Some(a), Some(b)) => a.sequence == b.sequence
    _ => false
  }
}

///|
/// Reconstruct every winner across a bounded valid-time window.
/// The output also includes never-assigned gaps and explicit tombstones.
pub fn Ledger::timeline(
  self : Ledger,
  key : String,
  bounds : Span,
  known_at : Int64,
  max_segments? : Int = 4096,
) -> Array[Segment] raise TemporalError {
  if max_segments <= 0 {
    raise TooManySegments(maximum=max_segments)
  }
  let points : Array[Int64] = [bounds.start]
  let events : Array[TimelineEvent] = []
  for revision in self.history(key) {
    if revision.known_at <= known_at {
      match revision.valid.intersection(bounds) {
        Some(part) => {
          events.push({ start: part.start, end: part.end, source: revision })
          if part.start > bounds.start {
            points.push(part.start)
          }
          match part.end {
            Some(end) => points.push(end)
            None => ()
          }
        }
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
  events.sort_by(fn(a, b) {
    if a.start < b.start { -1 } else if a.start > b.start { 1 } else { 0 }
  })
  let output : Array[Segment] = []
  let heap : Array[TimelineHeapItem] = []
  let mut next_event = 0
  for i = 0; i < unique.length(); i = i + 1 {
    let start = unique[i]
    while next_event < events.length() && events[next_event].start <= start {
      let event = events[next_event]
      timeline_heap_push(heap, { end: event.end, source: event.source })
      next_event = next_event + 1
    }
    let end = if i + 1 < unique.length() {
      Some(unique[i + 1])
    } else {
      bounds.end
    }
    if end == Some(start) {
      continue
    }
    if i + 1 == unique.length() && bounds.end is Some(_) {
      continue
    }
    let source = timeline_heap_winner(heap, start)
    let valid : Span = { start, end }
    if !output.is_empty() && same_source(output[output.length() - 1].source, source) {
      let last = output.length() - 1
      output[last] = { valid: { start: output[last].valid.start, end }, source }
    } else {
      if output.length() >= max_segments {
        raise TooManySegments(maximum=max_segments)
      }
      output.push({ valid, source })
    }
  }
  output
}
