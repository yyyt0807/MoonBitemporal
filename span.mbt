///|
/// Half-open valid-time span. `None` means an unbounded right endpoint.
pub struct Span {
  start : Int64
  end : Int64?
}

///|
pub fn Span::new(start : Int64, end : Int64) -> Span raise TemporalError {
  if end <= start {
    raise InvalidSpan("end must be greater than start")
  }
  { start, end: Some(end) }
}

///|
pub fn Span::open(start : Int64) -> Span {
  { start, end: None }
}

///|
pub fn Span::start(self : Span) -> Int64 {
  self.start
}

///|
pub fn Span::end(self : Span) -> Int64? {
  self.end
}

///|
pub fn Span::contains(self : Span, instant : Int64) -> Bool {
  instant >= self.start && (match self.end {
    Some(end) => instant < end
    None => true
  })
}

///|
pub fn Span::overlaps(self : Span, other : Span) -> Bool {
  let before_other_end = match other.end {
    Some(end) => self.start < end
    None => true
  }
  let other_before_end = match self.end {
    Some(end) => other.start < end
    None => true
  }
  before_other_end && other_before_end
}

///|
pub fn Span::intersection(self : Span, other : Span) -> Span? {
  if !self.overlaps(other) {
    return None
  }
  let start = if self.start > other.start { self.start } else { other.start }
  let end = match (self.end, other.end) {
    (Some(a), Some(b)) => Some(if a < b { a } else { b })
    (Some(a), None) => Some(a)
    (None, Some(b)) => Some(b)
    (None, None) => None
  }
  Some({ start, end })
}

///|
/// Whether two spans share a boundary but no interior.
pub fn Span::touches(self : Span, other : Span) -> Bool {
  match (self.end, other.end) {
    (Some(a), _) if a == other.start => true
    (_, Some(b)) if b == self.start => true
    _ => false
  }
}
