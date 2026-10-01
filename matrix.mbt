///|
/// One cell in a sampled valid-time × knowledge-time matrix. A missing source
/// means no claim was known; a source with `value=None` is a withdrawal.
pub struct MatrixCell {
  valid_at : Int64
  known_at : Int64
  source : Revision?
}

///|
pub fn MatrixCell::valid_at(self : MatrixCell) -> Int64 {
  self.valid_at
}

///|
pub fn MatrixCell::known_at(self : MatrixCell) -> Int64 {
  self.known_at
}

///|
pub fn MatrixCell::source(self : MatrixCell) -> Revision? {
  self.source
}

///|
pub fn MatrixCell::value(self : MatrixCell) -> String? {
  observed_value(self.source)
}

///|
pub fn MatrixCell::is_unclaimed(self : MatrixCell) -> Bool {
  self.source is None
}

///|
pub fn MatrixCell::is_withdrawn(self : MatrixCell) -> Bool {
  match self.source {
    Some(revision) => revision.value is None
    None => false
  }
}

///|
/// Row-major sample grid: rows follow caller-provided valid instants, columns
/// follow caller-provided knowledge instants. Input order and duplicates are
/// intentionally preserved for direct alignment with external data tables.
pub struct TemporalMatrix {
  key : String
  valid_samples : Array[Int64]
  knowledge_samples : Array[Int64]
  cells : Array[MatrixCell]
}

///|
pub fn TemporalMatrix::key(self : TemporalMatrix) -> String {
  self.key
}

///|
pub fn TemporalMatrix::valid_samples(self : TemporalMatrix) -> Array[Int64] {
  self.valid_samples.copy()
}

///|
pub fn TemporalMatrix::knowledge_samples(self : TemporalMatrix) -> Array[Int64] {
  self.knowledge_samples.copy()
}

///|
pub fn TemporalMatrix::rows(self : TemporalMatrix) -> Int {
  self.valid_samples.length()
}

///|
pub fn TemporalMatrix::columns(self : TemporalMatrix) -> Int {
  self.knowledge_samples.length()
}

///|
pub fn TemporalMatrix::cell_count(self : TemporalMatrix) -> Int {
  self.cells.length()
}

///|
pub fn TemporalMatrix::cell(
  self : TemporalMatrix,
  row : Int,
  column : Int,
) -> MatrixCell? {
  if row < 0 || row >= self.rows() || column < 0 || column >= self.columns() {
    return None
  }
  self.cells.get(row * self.columns() + column)
}

///|
pub fn TemporalMatrix::row(
  self : TemporalMatrix,
  index : Int,
) -> Array[MatrixCell] {
  let output : Array[MatrixCell] = []
  if index < 0 || index >= self.rows() {
    return output
  }
  let start = index * self.columns()
  for column = 0; column < self.columns(); column = column + 1 {
    output.push(self.cells[start + column])
  }
  output
}

///|
pub fn TemporalMatrix::column(
  self : TemporalMatrix,
  index : Int,
) -> Array[MatrixCell] {
  let output : Array[MatrixCell] = []
  if index < 0 || index >= self.columns() {
    return output
  }
  for row = 0; row < self.rows(); row = row + 1 {
    output.push(self.cells[row * self.columns() + index])
  }
  output
}

///|
/// Count sampled valid instants whose value differs between two knowledge
/// columns. Duplicate valid samples count separately because input positions
/// represent rows supplied by the caller.
pub fn TemporalMatrix::changed_rows(
  self : TemporalMatrix,
  before_column : Int,
  after_column : Int,
) -> Int {
  if before_column < 0 ||
    before_column >= self.columns() ||
    after_column < 0 ||
    after_column >= self.columns() {
    return 0
  }
  let mut changes = 0
  for row = 0; row < self.rows(); row = row + 1 {
    let before = self.cells[row * self.columns() + before_column].value()
    let after = self.cells[row * self.columns() + after_column].value()
    if before != after {
      changes = changes + 1
    }
  }
  changes
}

///|
/// Sample the two-clock surface of one key with explicit resource bounds.
/// This is useful for audit tables, visualizations and differential testing;
/// use `timeline` for complete unsampled interval coverage.
pub fn Ledger::sample_matrix(
  self : Ledger,
  key : String,
  valid_samples : Array[Int64],
  knowledge_samples : Array[Int64],
  max_cells? : Int = 10000,
) -> TemporalMatrix raise TemporalError {
  if max_cells < 0 ||
    (
      !knowledge_samples.is_empty() &&
      valid_samples.length() > max_cells / knowledge_samples.length()
    ) {
    raise TooManyCells(maximum=max_cells)
  }
  let cells : Array[MatrixCell] = []
  for valid_at in valid_samples {
    for known_at in knowledge_samples {
      cells.push({
        valid_at,
        known_at,
        source: self.observe(key, valid_at, known_at),
      })
    }
  }
  {
    key,
    valid_samples: valid_samples.copy(),
    knowledge_samples: knowledge_samples.copy(),
    cells,
  }
}
