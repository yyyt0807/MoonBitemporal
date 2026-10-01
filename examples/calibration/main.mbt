///|
/// Telemetry replay must know which device metadata was used in an earlier
/// report and which metadata field operators now believe applied then.
fn main raise {
  let month = try! @temporal.Span::new(0L, 30L)
  let base = try! @temporal.Ledger::new()
  let initial = try! base.commit(
    1L,
    [
      @temporal.Change::put("sensor/7/factor", month, "1.00"),
      @temporal.Change::put("sensor/7/site", month, "line-a"),
    ],
  )
  let report_day = 12L
  let reported = initial.snapshot(report_day, 1L)
  assert_eq(reported.length(), 2)
  println("Initial report used factor 1.00 at line-a")

  // The operator learns on intake step 5 that days [10, 15) had a different
  // calibration, then learns on step 7 that the device moved on day 20.
  let calibrated = try! initial.commit(
    5L,
    [
      @temporal.Change::put(
        "sensor/7/factor",
        try! @temporal.Span::new(10L, 15L),
        "1.05",
      ),
    ],
  )
  let moved = try! calibrated.commit(
    7L,
    [
      @temporal.Change::put(
        "sensor/7/site",
        try! @temporal.Span::new(20L, 30L),
        "line-b",
      ),
    ],
  )
  assert_eq(moved.get("sensor/7/factor", report_day, 1L), Some("1.00"))
  assert_eq(moved.get("sensor/7/factor", report_day, 7L), Some("1.05"))
  assert_eq(moved.get("sensor/7/site", 25L, 7L), Some("line-b"))
  println("Corrected replay uses factor 1.05 for day 12")

  let factor_coverage = try! moved.coverage("sensor/7/factor", month, 7L)
  assert_eq(factor_coverage.assigned(), 30L)
  assert_eq(factor_coverage.values().length(), 2)
  assert_eq(factor_coverage.values()[0].duration(), 25L)
  assert_eq(factor_coverage.values()[1].duration(), 5L)
  println("Factor 1.00 covers 25 days; factor 1.05 covers 5 days")

  let combined = try! moved.snapshot_timeline(
    ["sensor/7/factor", "sensor/7/site"],
    month,
    7L,
  )
  assert_eq(combined.length(), 4)
  assert_eq(combined[1].value("sensor/7/factor"), Some("1.05"))
  assert_eq(combined[3].value("sensor/7/site"), Some("line-b"))
  println("Aligned metadata timeline contains four change-point slices")

  // A downstream consumer can export only this device's calibration history.
  let projected = moved.select_keys(["sensor/7/factor"])
  assert_eq(projected.history_count("sensor/7/site"), 0)
  assert_eq(projected.history_count("sensor/7/factor"), 2)
  println("Calibration-only archive omits unrelated site history")
}
