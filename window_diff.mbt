///|
/// A maximal valid-time fragment whose effective value changed between two
/// knowledge-time views.
pub struct WindowChange {
  valid : Span
  before : String?
  after : String?
}

///|
pub fn WindowChange::valid(self : WindowChange) -> Span {
  self.valid
}

///|
pub fn WindowChange::before(self : WindowChange) -> String? {
  self.before
}

///|
pub fn WindowChange::after(self : WindowChange) -> String? {
  self.after
}

///|
fn append_window_change(
  output : Array[WindowChange],
  valid : Span,
  before : String?,
  after : String?,
  maximum : Int,
) -> Unit raise TemporalError {
  if !output.is_empty() {
    let last = output.length() - 1
    if output[last].before == before && output[last].after == after &&
      output[last].valid.touches(valid) {
      output[last] = {
        valid: { start: output[last].valid.start, end: valid.end },
        before,
        after,
      }
      return
    }
  }
  if output.length() >= maximum {
    raise TooManySegments(maximum~)
  }
  output.push({ valid, before, after })
}

///|
/// Compare two complete valid-time timelines with a linear two-pointer merge.
/// Unchanged fragments are omitted; adjacent equal changes are coalesced.
pub fn Ledger::diff_timeline(
  self : Ledger,
  key : String,
  bounds : Span,
  before_known : Int64,
  after_known : Int64,
  max_segments? : Int = 4096,
) -> Array[WindowChange] raise TemporalError {
  if max_segments <= 0 {
    raise TooManySegments(maximum=max_segments)
  }
  let before = self.timeline(key, bounds, before_known, max_segments~)
  let after = self.timeline(key, bounds, after_known, max_segments~)
  let output : Array[WindowChange] = []
  let mut left = 0
  let mut right = 0
  while left < before.length() && right < after.length() {
    let a = before[left]
    let b = after[right]
    match a.valid.intersection(b.valid) {
      Some(valid) => {
        let old_value = a.value()
        let new_value = b.value()
        if old_value != new_value {
          append_window_change(output, valid, old_value, new_value, max_segments)
        }
      }
      None => ()
    }
    if end_before(a.valid.end, b.valid.end) {
      left = left + 1
    } else if end_before(b.valid.end, a.valid.end) {
      right = right + 1
    } else {
      left = left + 1
      right = right + 1
    }
  }
  output
}
