///|
test "change report JSON preserves full-width time values as strings" {
  let base = try! Ledger::new()
  let initial = try! base.commit(1L, [
    Change::put("k", Span::open(-9223372036854775807L - 1L), "old"),
  ])
  let revised = try! initial.commit(9223372036854775807L, [
    Change::put("k", Span::open(0L), "new"),
  ])
  let report = try! revised.change_report(
    try! Span::new(0L, 1L),
    1L,
    9223372036854775807L,
  )
  let encoded = report.to_json_string()
  assert_true(encoded.contains("\"afterKnown\":\"9223372036854775807\""))
  assert_true(encoded.contains("\"before\":\"old\""))
  assert_true(encoded.contains("\"after\":\"new\""))
  assert_true(encoded.contains("\"schemaVersion\":1"))
}

///|
test "matrix JSON distinguishes no claim from a tombstone" {
  let base = try! Ledger::new()
  let assigned = try! base.commit(10L, [Change::put("k", Span::open(0L), "v")])
  let withdrawn = try! assigned.commit(20L, [
    Change::delete("k", Span::open(0L)),
  ])
  let matrix = try! withdrawn.sample_matrix("k", [0L], [0L, 10L, 20L])
  let encoded = matrix.to_json_string()
  assert_true(encoded.contains("\"state\":\"unclaimed\""))
  assert_true(encoded.contains("\"state\":\"assigned\""))
  assert_true(encoded.contains("\"state\":\"withdrawn\""))
  assert_eq(matrix.cell_count(), 3)
}
