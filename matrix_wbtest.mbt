///|
test "sample matrix exposes the two-clock correction surface" {
  let base = try! Ledger::new()
  let first = try! base.commit(
    10L,
    [Change::put("k", try! Span::new(0L, 20L), "old")],
  )
  let second = try! first.commit(
    20L,
    [Change::put("k", try! Span::new(5L, 10L), "new")],
  )
  let matrix = try! second.sample_matrix("k", [2L, 7L, 15L], [5L, 10L, 20L])
  assert_eq(matrix.rows(), 3)
  assert_eq(matrix.columns(), 3)
  assert_eq(matrix.cell_count(), 9)
  assert_true(matrix.cell(1, 0).unwrap().is_unclaimed())
  assert_eq(matrix.cell(1, 1).unwrap().value(), Some("old"))
  assert_eq(matrix.cell(1, 2).unwrap().value(), Some("new"))
  assert_eq(matrix.changed_rows(1, 2), 1)
  assert_eq(matrix.row(1).length(), 3)
  assert_eq(matrix.column(2).length(), 3)
  assert_true(matrix.cell(-1, 0) is None)
}

///|
test "matrix preserves input order and enforces product limit" {
  let ledger = try! Ledger::new()
  let matrix = try! ledger.sample_matrix("unknown", [10L, 5L, 10L], [2L, 1L])
  assert_eq(matrix.valid_samples(), [10L, 5L, 10L])
  assert_eq(matrix.knowledge_samples(), [2L, 1L])
  assert_eq(matrix.cell(2, 1).unwrap().valid_at(), 10L)
  assert_eq(matrix.cell(2, 1).unwrap().known_at(), 1L)
  let code = try ledger.sample_matrix(
    "unknown",
    [1L, 2L, 3L],
    [1L, 2L],
    max_cells=5,
  ) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  assert_eq(code, "TEMPORAL_CELL_LIMIT")
}
