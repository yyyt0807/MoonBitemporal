///|
/// Select a semantic state from a two-clock valid-time timeline.
pub(all) enum SpanFilter {
  Assigned
  Equals(String)
  Withdrawn
  Unclaimed
}

///|
fn SpanFilter::accepts(self : SpanFilter, segment : Segment) -> Bool {
  match self {
    Assigned => segment.value() is Some(_)
    Equals(expected) => segment.value() == Some(expected)
    Withdrawn => segment.is_deleted()
    Unclaimed => segment.is_gap()
  }
}

///|
/// Return maximal spans matching a semantic state, merging adjacent matching
/// segments even if their winning revision identities differ.
pub fn Ledger::matching_spans(
  self : Ledger,
  key : String,
  bounds : Span,
  known_at : Int64,
  filter : SpanFilter,
  max_segments? : Int = 4096,
) -> Array[Span] raise TemporalError {
  if max_segments <= 0 {
    raise TooManySegments(maximum=max_segments)
  }
  let timeline = self.timeline(key, bounds, known_at, max_segments~)
  let output : Array[Span] = []
  for segment in timeline {
    if filter.accepts(segment) {
      if !output.is_empty() && output[output.length() - 1].touches(segment.valid) {
        let last = output.length() - 1
        output[last] = {
          start: output[last].start,
          end: segment.valid.end,
        }
      } else {
        if output.length() >= max_segments {
          raise TooManySegments(maximum=max_segments)
        }
        output.push(segment.valid)
      }
    }
  }
  output
}
