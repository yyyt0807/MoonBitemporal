///|
priv struct BatchEntry {
  key : String
  valid : Span
  original_index : Int
}

///|
/// For one key, any intersecting pair in start order has an intersecting
/// adjacent pair. Sorting therefore reduces overlap validation from O(k²)
/// pair checks to O(k log k) sorting plus one linear pass.
fn validate_batch_changes(changes : Array[Change]) -> Unit raise TemporalError {
  let entries : Array[BatchEntry] = []
  for index, change in changes {
    if change.key == "" {
      raise EmptyKey
    }
    entries.push({
      key: change.key,
      valid: change.valid,
      original_index: index,
    })
  }
  entries.sort_by(fn(a, b) {
    let key_order = a.key.lexical_compare(b.key)
    if key_order != 0 {
      key_order
    } else if a.valid.start < b.valid.start {
      -1
    } else if a.valid.start > b.valid.start {
      1
    } else {
      0
    }
  })
  for i = 1; i < entries.length(); i = i + 1 {
    let previous = entries[i - 1]
    let current = entries[i]
    if previous.key == current.key && previous.valid.overlaps(current.valid) {
      let first = if previous.original_index < current.original_index {
        previous.original_index
      } else {
        current.original_index
      }
      let second = if previous.original_index > current.original_index {
        previous.original_index
      } else {
        current.original_index
      }
      raise OverlappingBatchChanges(key=current.key, first~, second~)
    }
  }
}
