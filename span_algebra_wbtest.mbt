///|
test "subtraction splits a span and preserves open suffix" {
  let whole = Span::open(0L)
  let removed = try! Span::new(10L, 20L)
  let pieces = whole.subtract(removed)
  assert_eq(pieces.length(), 2)
  assert_eq(pieces[0].start(), 0L)
  assert_eq(pieces[0].end(), Some(10L))
  assert_eq(pieces[1].start(), 20L)
  assert_eq(pieces[1].end(), None)
}

///|
test "normalization clips sorts and merges touching intervals" {
  let bounds = try! Span::new(0L, 20L)
  let spans = [
    try! Span::new(11L, 30L),
    try! Span::new(-2L, 3L),
    try! Span::new(3L, 5L),
    try! Span::new(12L, 15L),
  ]
  let result = normalize_spans(spans, bounds)
  assert_eq(result.length(), 2)
  assert_eq(result[0].start(), 0L)
  assert_eq(result[0].end(), Some(5L))
  assert_eq(result[1].start(), 11L)
  assert_eq(result[1].end(), Some(20L))
}

///|
test "gaps return uncovered intervals" {
  let bounds = try! Span::new(0L, 20L)
  let holes = gaps([try! Span::new(2L, 7L), try! Span::new(10L, 15L)], bounds)
  assert_eq(holes.length(), 3)
  assert_eq(holes[0].start(), 0L)
  assert_eq(holes[0].end(), Some(2L))
  assert_eq(holes[1].start(), 7L)
  assert_eq(holes[1].end(), Some(10L))
  assert_eq(holes[2].start(), 15L)
  assert_eq(holes[2].end(), Some(20L))
}
