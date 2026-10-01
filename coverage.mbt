///|
/// Duration for one distinct assigned value inside a finite query window.
pub struct ValueDuration {
  value : String
  duration : Int64
}

///|
pub fn ValueDuration::value(self : ValueDuration) -> String { self.value }

///|
pub fn ValueDuration::duration(self : ValueDuration) -> Int64 { self.duration }

///|
/// Duration totals distinguish a never-claimed gap from an explicit deletion.
pub struct Coverage {
  total : Int64
  assigned : Int64
  withdrawn : Int64
  unclaimed : Int64
  values : Array[ValueDuration]
}

///|
pub fn Coverage::total(self : Coverage) -> Int64 { self.total }

///|
pub fn Coverage::assigned(self : Coverage) -> Int64 { self.assigned }

///|
pub fn Coverage::withdrawn(self : Coverage) -> Int64 { self.withdrawn }

///|
pub fn Coverage::unclaimed(self : Coverage) -> Int64 { self.unclaimed }

///|
pub fn Coverage::values(self : Coverage) -> Array[ValueDuration] {
  self.values.copy()
}

///|
fn checked_span_duration(span : Span) -> Int64 raise TemporalError {
  let end = match span.end {
    Some(end) => end
    None => raise UnboundedDuration
  }
  if span.start < 0L && end > 9223372036854775807L + span.start {
    raise DurationOverflow
  }
  end - span.start
}

///|
/// Aggregate the amount of valid time assigned to each value. Instants are
/// abstract units; the caller decides whether one unit means a day, second or
/// another scale. No floating-point arithmetic or calendar rules are used.
pub fn Ledger::coverage(
  self : Ledger,
  key : String,
  bounds : Span,
  known_at : Int64,
  max_segments? : Int = 4096,
) -> Coverage raise TemporalError {
  let total = checked_span_duration(bounds)
  let timeline = self.timeline(key, bounds, known_at, max_segments~)
  let mut assigned = 0L
  let mut withdrawn = 0L
  let mut unclaimed = 0L
  let durations : Map[String, Int64] = Map([])
  for segment in timeline {
    let length = checked_span_duration(segment.valid)
    match segment.source {
      None => unclaimed = unclaimed + length
      Some(source) => match source.value {
        None => withdrawn = withdrawn + length
        Some(value) => {
          assigned = assigned + length
          let previous = match durations.get(value) {
            Some(previous) => previous
            None => 0L
          }
          durations[value] = previous + length
        }
      }
    }
  }
  let values : Array[ValueDuration] = []
  for value, duration in durations {
    values.push({ value, duration })
  }
  values.sort_by(fn(a, b) { a.value.lexical_compare(b.value) })
  { total, assigned, withdrawn, unclaimed, values }
}
