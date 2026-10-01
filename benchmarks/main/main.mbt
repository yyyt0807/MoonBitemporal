///|
/// A fixed, deterministic workload for external wall-clock measurement.
/// It exercises builder ingestion, indexed point lookups, sweep timelines and
/// versioned archive import. No platform timer is embedded in the library.
fn main raise {
  let builder = try! @temporal.LedgerBuilder::new(maximum=3000)
  for i = 0; i < 2000; i = i + 1 {
    let key = "sensor/" + (i % 16).to_string()
    let start = (i * 31 % 1024).to_int64()
    let end = start + (i % 31 + 1).to_int64()
    builder.append(i.to_int64(), [
      @temporal.Change::put(
        key,
        try! @temporal.Span::new(start, end),
        i.to_string(),
      ),
    ])
  }
  let ledger = builder.freeze()
  assert_eq(ledger.revision_count(), 2000)
  let mut checksum = 0L
  for i = 0; i < 5000; i = i + 1 {
    let key = "sensor/" + (i % 16).to_string()
    let valid_at = (i * 17 % 1024).to_int64()
    match ledger.observe(key, valid_at, 1999L) {
      Some(revision) => checksum = checksum + revision.sequence().to_int64()
      None => checksum = checksum + 1L
    }
  }
  let timeline = try! ledger.timeline(
    "sensor/0",
    try! @temporal.Span::new(0L, 1024L),
    1999L,
  )
  checksum = checksum + timeline.length().to_int64()
  let restored = try! @temporal.Ledger::from_json_string(
    ledger.to_json_string(),
    maximum=3000,
  )
  assert_eq(restored.revision_count(), 2000)
  assert_eq(
    restored.get("sensor/0", 0L, 1999L),
    ledger.get("sensor/0", 0L, 1999L),
  )
  println(
    "revisions=2000 queries=5000 timeline_segments=" +
    timeline.length().to_string(),
  )
  println("checksum=" + checksum.to_string())
}
