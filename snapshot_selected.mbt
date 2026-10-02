///|
/// Return only the requested keys from a two-clock snapshot. Duplicate keys
/// are removed, results are in lexical order, and the key budget is checked
/// before any point queries. Useful when an API response needs a small field
/// set from a ledger containing many unrelated keys.
pub fn Ledger::snapshot_selected(
  self : Ledger,
  keys : Array[String],
  valid_at : Int64,
  known_at : Int64,
  max_keys? : Int = 1024,
) -> Array[Fact] raise TemporalError {
  let selected = unique_query_keys(keys, max_keys)
  let result : Array[Fact] = []
  for key in selected {
    match self.observe(key, valid_at, known_at) {
      Some(source) =>
        match source.value {
          Some(value) => result.push({ key, value, source, })
          None => ()
        }
      None => ()
    }
  }
  result
}
