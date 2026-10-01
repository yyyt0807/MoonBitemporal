///|
test "half-open spans reject reversed and empty ranges" {
  let empty_rejected = try Span::new(4L, 4L) catch {
    _ => true
  } noraise {
    _ => false
  }
  let reversed_rejected = try Span::new(5L, 4L) catch {
    _ => true
  } noraise {
    _ => false
  }
  assert_true(empty_rejected)
  assert_true(reversed_rejected)
  let span = try! Span::new(4L, 5L)
  assert_false(span.contains(3L))
  assert_true(span.contains(4L))
  assert_false(span.contains(5L))
}

///|
test "open spans include every later representable instant" {
  let span = Span::open(7L)
  assert_false(span.contains(6L))
  assert_true(span.contains(7L))
  assert_true(span.contains(9223372036854775807L))
}

///|
test "touching spans do not overlap" {
  let left = try! Span::new(0L, 5L)
  let right = try! Span::new(5L, 10L)
  assert_true(left.touches(right))
  assert_false(left.overlaps(right))
  assert_true(left.intersection(right) is None)
}

///|
test "intersection handles finite and open endpoints" {
  let open = Span::open(10L)
  let finite = try! Span::new(4L, 20L)
  let overlap = open.intersection(finite)
  assert_true(overlap is Some(_))
  match overlap {
    Some(span) => {
      assert_eq(span.start(), 10L)
      assert_eq(span.end(), Some(20L))
    }
    None => fail("expected intersection")
  }
}
