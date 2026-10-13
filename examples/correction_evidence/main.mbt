///|
/// One correction has different prior claims over its valid span. Evidence
/// includes an unchanged value with changed provenance, useful for data review.
fn main raise {
  let first = try! @temporal.Ledger::new().commit(10L, [
    @temporal.Change::put(
      "calibration/sensor",
      try! @temporal.Span::new(0L, 10L),
      "gain=1.1",
    ),
    @temporal.Change::delete(
      "calibration/sensor",
      try! @temporal.Span::new(10L, 20L),
    ),
  ])
  let corrected = first.commit(20L, [
    @temporal.Change::put(
      "calibration/sensor",
      try! @temporal.Span::new(0L, 30L),
      "gain=1.1",
    ),
  ])
  let fragments = corrected.supersession_fragments(2)
  assert_eq(fragments.length(), 3)
  assert_false(fragments[0].value_changed())
  assert_true(fragments[1].previous().unwrap().value() is None)
  assert_true(fragments[2].previous() is None)
  for fragment in fragments {
    println(fragment.to_json().stringify())
  }
  assert_eq(corrected.get("calibration/sensor", 15L, 10L), None)
  assert_eq(corrected.get("calibration/sensor", 15L, 20L), Some("gain=1.1"))
  println(
    "Correction evidence retains assigned, withdrawn and never-known prior states",
  )
}
