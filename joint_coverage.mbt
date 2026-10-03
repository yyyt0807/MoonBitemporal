///|
/// Maximal valid spans on which every selected key has an assigned value.
/// Empty selection is the whole bounds. This does not compare the values.
pub fn Ledger::joint_assigned_spans(
  self : Ledger,
  keys : Array[String],
  bounds : Span,
  known_at : Int64,
  max_keys? : Int = 64,
  max_segments? : Int = 4096,
) -> Array[Span] raise TemporalError {
  if max_segments <= 0 {
    raise TooManySegments(maximum=max_segments)
  }
  let selected = unique_query_keys(keys, max_keys)
  let mut result = [bounds]
  for key in selected {
    if result.is_empty() {
      break
    }
    let available = self.matching_spans(
      key,
      bounds,
      known_at,
      Assigned,
      max_segments~,
    )
    let shared : Array[Span] = []
    let mut a = 0
    let mut b = 0
    while a < result.length() && b < available.length() {
      match result[a].intersection(available[b]) {
        Some(span) => {
          if shared.length() >= max_segments {
            raise TooManySegments(maximum=max_segments)
          }
          shared.push(span)
        }
        None => ()
      }
      if end_before(result[a].end, available[b].end) {
        a += 1
      } else if end_before(available[b].end, result[a].end) {
        b += 1
      } else {
        a += 1
        b += 1
      }
    }
    result = shared
  }
  result
}
