///|
test "builder ingests many batches and freezes isolated checkpoints" {
  let builder = try! LedgerBuilder::new(maximum=1000)
  for i = 0; i < 300; i = i + 1 {
    builder.append(
      i.to_int64(),
      [Change::put("series", Span::open(0L), i.to_string())],
    )
  }
  let checkpoint = builder.freeze()
  assert_eq(checkpoint.revision_count(), 300)
  assert_eq(builder.batch_count(), 300)
  assert_eq(builder.remaining_capacity(), 700)
  assert_eq(checkpoint.get("series", 0L, 300L), Some("299"))
  builder.append(300L, [Change::put("series", Span::open(0L), "300")])
  assert_eq(builder.get("series", 0L, 300L), Some("300"))
  assert_eq(checkpoint.get("series", 0L, 300L), Some("299"))
  assert_eq(checkpoint.revision_count(), 300)
}

///|
test "builder rejects bad batches without partial mutation" {
  let builder = try! LedgerBuilder::new(maximum=3)
  builder.append(1L, [Change::put("a", Span::open(0L), "a")])
  let invalid = try builder.append(
    2L,
    [
      Change::put("b", Span::open(0L), "first"),
      Change::put("b", Span::open(0L), "second"),
    ],
  ) catch {
    error => error.code()
  } noraise {
    _ => "accepted"
  }
  assert_eq(invalid, "TEMPORAL_BATCH_OVERLAP")
  assert_eq(builder.revision_count(), 1)
  assert_eq(builder.latest_time(), Some(1L))
  assert_eq(builder.get("b", 0L, 2L), None)
  builder.append(2L, [Change::put("b", Span::open(0L), "ok")])
  assert_eq(builder.revision_count(), 2)
}

///|
test "builder resumed from ledger does not mutate the source" {
  let base = try! Ledger::new()
  let initial = try! base.commit(1L, [Change::put("k", Span::open(0L), "old")])
  let builder = LedgerBuilder::from_ledger(initial)
  assert_eq(builder.batch_count(), 1)
  builder.append(2L, [Change::put("k", Span::open(0L), "new")])
  assert_eq(builder.freeze().get("k", 0L, 2L), Some("new"))
  assert_eq(initial.get("k", 0L, 2L), Some("old"))
}
