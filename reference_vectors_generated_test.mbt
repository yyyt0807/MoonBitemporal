// Generated from actual Rust bitemporal-runtime 0.1.0 outputs.
// Regenerate with tools/generate_reference_tests.py; excluded from handwritten LOC.

///|
test "Rust reference shared open-span semantics case 0" {
  let builder = try! @moonbitemporal.LedgerBuilder::new()
  builder.append(1L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(-10L),
      "value-0",
    ),
  ])
  builder.append(4L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(7L),
      "value-1",
    ),
  ])
  builder.append(7L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(24L),
      "value-2",
    ),
  ])
  builder.append(10L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(0L),
      "value-3",
    ),
  ])
  builder.append(13L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(17L),
      "value-4",
    ),
  ])
  builder.append(16L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(-7L),
      "value-5",
    ),
  ])
  builder.append(19L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(10L),
      "value-6",
    ),
  ])
  builder.append(22L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(27L),
      "value-0",
    ),
  ])
  builder.append(25L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(3L),
      "value-1",
    ),
  ])
  builder.append(28L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(20L),
      "value-2",
    ),
  ])
  builder.append(31L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(-4L),
      "value-3",
    ),
  ])
  builder.append(34L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(13L),
      "value-4",
    ),
  ])
  let ledger = builder.freeze()
  assert_eq(ledger.snapshot(-11L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, -1L), None)
  assert_eq(ledger.snapshot(-11L, 1L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 1L), None)
  assert_eq(ledger.snapshot(-11L, 7L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 7L), None)
  assert_eq(ledger.snapshot(-11L, 25L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 25L), None)
  assert_eq(ledger.snapshot(-11L, 80L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 80L), None)
  assert_eq(ledger.snapshot(-11L, 200L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 200L), None)
  assert_eq(ledger.snapshot(-10L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", -10L, -1L), None)
  assert_eq(ledger.snapshot(-10L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 1L), Some("value-0"))
  assert_eq(ledger.snapshot(-10L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 7L), Some("value-0"))
  assert_eq(ledger.snapshot(-10L, 25L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 25L), Some("value-0"))
  assert_eq(ledger.snapshot(-10L, 80L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 80L), Some("value-0"))
  assert_eq(ledger.snapshot(-10L, 200L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 200L), Some("value-0"))
  assert_eq(ledger.snapshot(0L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 0L, -1L), None)
  assert_eq(ledger.snapshot(0L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 0L, 1L), Some("value-0"))
  assert_eq(ledger.snapshot(0L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", 0L, 7L), Some("value-0"))
  assert_eq(ledger.snapshot(0L, 25L).length(), 1)
  assert_eq(ledger.get("key-0", 0L, 25L), Some("value-5"))
  assert_eq(ledger.snapshot(0L, 80L).length(), 1)
  assert_eq(ledger.get("key-0", 0L, 80L), Some("value-3"))
  assert_eq(ledger.snapshot(0L, 200L).length(), 1)
  assert_eq(ledger.get("key-0", 0L, 200L), Some("value-3"))
  assert_eq(ledger.snapshot(10L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 10L, -1L), None)
  assert_eq(ledger.snapshot(10L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 10L, 1L), Some("value-0"))
  assert_eq(ledger.snapshot(10L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", 10L, 7L), Some("value-1"))
  assert_eq(ledger.snapshot(10L, 25L).length(), 1)
  assert_eq(ledger.get("key-0", 10L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(10L, 80L).length(), 1)
  assert_eq(ledger.get("key-0", 10L, 80L), Some("value-3"))
  assert_eq(ledger.snapshot(10L, 200L).length(), 1)
  assert_eq(ledger.get("key-0", 10L, 200L), Some("value-3"))
  assert_eq(ledger.snapshot(20L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 20L, -1L), None)
  assert_eq(ledger.snapshot(20L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 20L, 1L), Some("value-0"))
  assert_eq(ledger.snapshot(20L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", 20L, 7L), Some("value-1"))
  assert_eq(ledger.snapshot(20L, 25L).length(), 1)
  assert_eq(ledger.get("key-0", 20L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(20L, 80L).length(), 1)
  assert_eq(ledger.get("key-0", 20L, 80L), Some("value-4"))
  assert_eq(ledger.snapshot(20L, 200L).length(), 1)
  assert_eq(ledger.get("key-0", 20L, 200L), Some("value-4"))
  assert_eq(ledger.snapshot(30L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 30L, -1L), None)
  assert_eq(ledger.snapshot(30L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 30L, 1L), Some("value-0"))
  assert_eq(ledger.snapshot(30L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", 30L, 7L), Some("value-2"))
  assert_eq(ledger.snapshot(30L, 25L).length(), 1)
  assert_eq(ledger.get("key-0", 30L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(30L, 80L).length(), 1)
  assert_eq(ledger.get("key-0", 30L, 80L), Some("value-4"))
  assert_eq(ledger.snapshot(30L, 200L).length(), 1)
  assert_eq(ledger.get("key-0", 30L, 200L), Some("value-4"))
  assert_eq(ledger.snapshot(31L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 31L, -1L), None)
  assert_eq(ledger.snapshot(31L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 31L, 1L), Some("value-0"))
  assert_eq(ledger.snapshot(31L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", 31L, 7L), Some("value-2"))
  assert_eq(ledger.snapshot(31L, 25L).length(), 1)
  assert_eq(ledger.get("key-0", 31L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(31L, 80L).length(), 1)
  assert_eq(ledger.get("key-0", 31L, 80L), Some("value-4"))
  assert_eq(ledger.snapshot(31L, 200L).length(), 1)
  assert_eq(ledger.get("key-0", 31L, 200L), Some("value-4"))
  assert_eq(ledger.snapshot(60L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 60L, -1L), None)
  assert_eq(ledger.snapshot(60L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 60L, 1L), Some("value-0"))
  assert_eq(ledger.snapshot(60L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", 60L, 7L), Some("value-2"))
  assert_eq(ledger.snapshot(60L, 25L).length(), 1)
  assert_eq(ledger.get("key-0", 60L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(60L, 80L).length(), 1)
  assert_eq(ledger.get("key-0", 60L, 80L), Some("value-4"))
  assert_eq(ledger.snapshot(60L, 200L).length(), 1)
  assert_eq(ledger.get("key-0", 60L, 200L), Some("value-4"))
  assert_eq(ledger.snapshot(-1L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", -1L, -1L), None)
  assert_eq(ledger.snapshot(0L, 0L).length(), 0)
  assert_eq(ledger.get("key-0", 0L, 0L), None)
  assert_eq(ledger.snapshot(1L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 1L, 1L), Some("value-0"))
  assert_eq(ledger.snapshot(7L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", 7L, 7L), Some("value-1"))
  assert_eq(ledger.snapshot(25L, 25L).length(), 1)
  assert_eq(ledger.get("key-0", 25L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(80L, 80L).length(), 1)
  assert_eq(ledger.get("key-0", 80L, 80L), Some("value-4"))
  assert_eq(ledger.snapshot(200L, 200L).length(), 1)
  assert_eq(ledger.get("key-0", 200L, 200L), Some("value-4"))
}

///|
test "Rust reference shared open-span semantics case 1" {
  let builder = try! @moonbitemporal.LedgerBuilder::new()
  builder.append(1L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(-10L),
      "value-0",
    ),
  ])
  builder.append(4L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(7L),
      "value-1",
    ),
  ])
  builder.append(7L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(24L),
      "value-2",
    ),
  ])
  builder.append(10L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(0L),
      "value-3",
    ),
  ])
  builder.append(13L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(17L),
      "value-4",
    ),
  ])
  builder.append(16L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(-7L),
      "value-5",
    ),
  ])
  builder.append(19L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(10L),
      "value-6",
    ),
  ])
  builder.append(22L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(27L),
      "value-0",
    ),
  ])
  builder.append(25L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(3L),
      "value-1",
    ),
  ])
  builder.append(28L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(20L),
      "value-2",
    ),
  ])
  builder.append(31L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(-4L),
      "value-3",
    ),
  ])
  builder.append(34L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(13L),
      "value-4",
    ),
  ])
  builder.append(37L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(30L),
      "value-5",
    ),
  ])
  builder.append(40L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(6L),
      "value-6",
    ),
  ])
  builder.append(43L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(23L),
      "value-0",
    ),
  ])
  builder.append(46L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(-1L),
      "value-1",
    ),
  ])
  builder.append(49L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(16L),
      "value-2",
    ),
  ])
  builder.append(52L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(-8L),
      "value-3",
    ),
  ])
  builder.append(55L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(9L),
      "value-4",
    ),
  ])
  builder.append(58L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(26L),
      "value-5",
    ),
  ])
  builder.append(61L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(2L),
      "value-6",
    ),
  ])
  builder.append(64L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(19L),
      "value-0",
    ),
  ])
  builder.append(67L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(-5L),
      "value-1",
    ),
  ])
  builder.append(70L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(12L),
      "value-2",
    ),
  ])
  builder.append(73L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(29L),
      "value-3",
    ),
  ])
  builder.append(76L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(5L),
      "value-4",
    ),
  ])
  builder.append(79L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(22L),
      "value-5",
    ),
  ])
  builder.append(82L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(-2L),
      "value-6",
    ),
  ])
  builder.append(85L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(15L),
      "value-0",
    ),
  ])
  builder.append(88L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(-9L),
      "value-1",
    ),
  ])
  let ledger = builder.freeze()
  assert_eq(ledger.snapshot(-11L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, -1L), None)
  assert_eq(ledger.get("key-1", -11L, -1L), None)
  assert_eq(ledger.get("key-2", -11L, -1L), None)
  assert_eq(ledger.snapshot(-11L, 1L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 1L), None)
  assert_eq(ledger.get("key-1", -11L, 1L), None)
  assert_eq(ledger.get("key-2", -11L, 1L), None)
  assert_eq(ledger.snapshot(-11L, 7L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 7L), None)
  assert_eq(ledger.get("key-1", -11L, 7L), None)
  assert_eq(ledger.get("key-2", -11L, 7L), None)
  assert_eq(ledger.snapshot(-11L, 25L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 25L), None)
  assert_eq(ledger.get("key-1", -11L, 25L), None)
  assert_eq(ledger.get("key-2", -11L, 25L), None)
  assert_eq(ledger.snapshot(-11L, 80L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 80L), None)
  assert_eq(ledger.get("key-1", -11L, 80L), None)
  assert_eq(ledger.get("key-2", -11L, 80L), None)
  assert_eq(ledger.snapshot(-11L, 200L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 200L), None)
  assert_eq(ledger.get("key-1", -11L, 200L), None)
  assert_eq(ledger.get("key-2", -11L, 200L), None)
  assert_eq(ledger.snapshot(-10L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", -10L, -1L), None)
  assert_eq(ledger.get("key-1", -10L, -1L), None)
  assert_eq(ledger.get("key-2", -10L, -1L), None)
  assert_eq(ledger.snapshot(-10L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", -10L, 1L), None)
  assert_eq(ledger.get("key-2", -10L, 1L), None)
  assert_eq(ledger.snapshot(-10L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", -10L, 7L), None)
  assert_eq(ledger.get("key-2", -10L, 7L), None)
  assert_eq(ledger.snapshot(-10L, 25L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 25L), Some("value-0"))
  assert_eq(ledger.get("key-1", -10L, 25L), None)
  assert_eq(ledger.get("key-2", -10L, 25L), None)
  assert_eq(ledger.snapshot(-10L, 80L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 80L), Some("value-0"))
  assert_eq(ledger.get("key-1", -10L, 80L), None)
  assert_eq(ledger.get("key-2", -10L, 80L), None)
  assert_eq(ledger.snapshot(-10L, 200L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-1", -10L, 200L), None)
  assert_eq(ledger.get("key-2", -10L, 200L), None)
  assert_eq(ledger.snapshot(0L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 0L, -1L), None)
  assert_eq(ledger.get("key-1", 0L, -1L), None)
  assert_eq(ledger.get("key-2", 0L, -1L), None)
  assert_eq(ledger.snapshot(0L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 0L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 0L, 1L), None)
  assert_eq(ledger.get("key-2", 0L, 1L), None)
  assert_eq(ledger.snapshot(0L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", 0L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 0L, 7L), None)
  assert_eq(ledger.get("key-2", 0L, 7L), None)
  assert_eq(ledger.snapshot(0L, 25L).length(), 2)
  assert_eq(ledger.get("key-0", 0L, 25L), Some("value-3"))
  assert_eq(ledger.get("key-1", 0L, 25L), None)
  assert_eq(ledger.get("key-2", 0L, 25L), Some("value-5"))
  assert_eq(ledger.snapshot(0L, 80L).length(), 3)
  assert_eq(ledger.get("key-0", 0L, 80L), Some("value-1"))
  assert_eq(ledger.get("key-1", 0L, 80L), Some("value-1"))
  assert_eq(ledger.get("key-2", 0L, 80L), Some("value-3"))
  assert_eq(ledger.snapshot(0L, 200L).length(), 3)
  assert_eq(ledger.get("key-0", 0L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 0L, 200L), Some("value-1"))
  assert_eq(ledger.get("key-2", 0L, 200L), Some("value-1"))
  assert_eq(ledger.snapshot(10L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 10L, -1L), None)
  assert_eq(ledger.get("key-1", 10L, -1L), None)
  assert_eq(ledger.get("key-2", 10L, -1L), None)
  assert_eq(ledger.snapshot(10L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 10L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 10L, 1L), None)
  assert_eq(ledger.get("key-2", 10L, 1L), None)
  assert_eq(ledger.snapshot(10L, 7L).length(), 2)
  assert_eq(ledger.get("key-0", 10L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 10L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 10L, 7L), None)
  assert_eq(ledger.snapshot(10L, 25L).length(), 3)
  assert_eq(ledger.get("key-0", 10L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-1", 10L, 25L), Some("value-1"))
  assert_eq(ledger.get("key-2", 10L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(10L, 80L).length(), 3)
  assert_eq(ledger.get("key-0", 10L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-1", 10L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-2", 10L, 80L), Some("value-6"))
  assert_eq(ledger.snapshot(10L, 200L).length(), 3)
  assert_eq(ledger.get("key-0", 10L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 10L, 200L), Some("value-4"))
  assert_eq(ledger.get("key-2", 10L, 200L), Some("value-1"))
  assert_eq(ledger.snapshot(20L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 20L, -1L), None)
  assert_eq(ledger.get("key-1", 20L, -1L), None)
  assert_eq(ledger.get("key-2", 20L, -1L), None)
  assert_eq(ledger.snapshot(20L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 20L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 20L, 1L), None)
  assert_eq(ledger.get("key-2", 20L, 1L), None)
  assert_eq(ledger.snapshot(20L, 7L).length(), 2)
  assert_eq(ledger.get("key-0", 20L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 20L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 20L, 7L), None)
  assert_eq(ledger.snapshot(20L, 25L).length(), 3)
  assert_eq(ledger.get("key-0", 20L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-1", 20L, 25L), Some("value-4"))
  assert_eq(ledger.get("key-2", 20L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(20L, 80L).length(), 3)
  assert_eq(ledger.get("key-0", 20L, 80L), Some("value-0"))
  assert_eq(ledger.get("key-1", 20L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-2", 20L, 80L), Some("value-2"))
  assert_eq(ledger.snapshot(20L, 200L).length(), 3)
  assert_eq(ledger.get("key-0", 20L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 20L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 20L, 200L), Some("value-1"))
  assert_eq(ledger.snapshot(30L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 30L, -1L), None)
  assert_eq(ledger.get("key-1", 30L, -1L), None)
  assert_eq(ledger.get("key-2", 30L, -1L), None)
  assert_eq(ledger.snapshot(30L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 30L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 30L, 1L), None)
  assert_eq(ledger.get("key-2", 30L, 1L), None)
  assert_eq(ledger.snapshot(30L, 7L).length(), 3)
  assert_eq(ledger.get("key-0", 30L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 30L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 30L, 7L), Some("value-2"))
  assert_eq(ledger.snapshot(30L, 25L).length(), 3)
  assert_eq(ledger.get("key-0", 30L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-1", 30L, 25L), Some("value-0"))
  assert_eq(ledger.get("key-2", 30L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(30L, 80L).length(), 3)
  assert_eq(ledger.get("key-0", 30L, 80L), Some("value-3"))
  assert_eq(ledger.get("key-1", 30L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-2", 30L, 80L), Some("value-5"))
  assert_eq(ledger.snapshot(30L, 200L).length(), 3)
  assert_eq(ledger.get("key-0", 30L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 30L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 30L, 200L), Some("value-1"))
  assert_eq(ledger.snapshot(31L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 31L, -1L), None)
  assert_eq(ledger.get("key-1", 31L, -1L), None)
  assert_eq(ledger.get("key-2", 31L, -1L), None)
  assert_eq(ledger.snapshot(31L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 31L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 31L, 1L), None)
  assert_eq(ledger.get("key-2", 31L, 1L), None)
  assert_eq(ledger.snapshot(31L, 7L).length(), 3)
  assert_eq(ledger.get("key-0", 31L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 31L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 31L, 7L), Some("value-2"))
  assert_eq(ledger.snapshot(31L, 25L).length(), 3)
  assert_eq(ledger.get("key-0", 31L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-1", 31L, 25L), Some("value-0"))
  assert_eq(ledger.get("key-2", 31L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(31L, 80L).length(), 3)
  assert_eq(ledger.get("key-0", 31L, 80L), Some("value-3"))
  assert_eq(ledger.get("key-1", 31L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-2", 31L, 80L), Some("value-5"))
  assert_eq(ledger.snapshot(31L, 200L).length(), 3)
  assert_eq(ledger.get("key-0", 31L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 31L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 31L, 200L), Some("value-1"))
  assert_eq(ledger.snapshot(60L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 60L, -1L), None)
  assert_eq(ledger.get("key-1", 60L, -1L), None)
  assert_eq(ledger.get("key-2", 60L, -1L), None)
  assert_eq(ledger.snapshot(60L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 60L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 60L, 1L), None)
  assert_eq(ledger.get("key-2", 60L, 1L), None)
  assert_eq(ledger.snapshot(60L, 7L).length(), 3)
  assert_eq(ledger.get("key-0", 60L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 60L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 60L, 7L), Some("value-2"))
  assert_eq(ledger.snapshot(60L, 25L).length(), 3)
  assert_eq(ledger.get("key-0", 60L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-1", 60L, 25L), Some("value-0"))
  assert_eq(ledger.get("key-2", 60L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(60L, 80L).length(), 3)
  assert_eq(ledger.get("key-0", 60L, 80L), Some("value-3"))
  assert_eq(ledger.get("key-1", 60L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-2", 60L, 80L), Some("value-5"))
  assert_eq(ledger.snapshot(60L, 200L).length(), 3)
  assert_eq(ledger.get("key-0", 60L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 60L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 60L, 200L), Some("value-1"))
  assert_eq(ledger.snapshot(-1L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", -1L, -1L), None)
  assert_eq(ledger.get("key-1", -1L, -1L), None)
  assert_eq(ledger.get("key-2", -1L, -1L), None)
  assert_eq(ledger.snapshot(0L, 0L).length(), 0)
  assert_eq(ledger.get("key-0", 0L, 0L), None)
  assert_eq(ledger.get("key-1", 0L, 0L), None)
  assert_eq(ledger.get("key-2", 0L, 0L), None)
  assert_eq(ledger.snapshot(1L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 1L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 1L, 1L), None)
  assert_eq(ledger.get("key-2", 1L, 1L), None)
  assert_eq(ledger.snapshot(7L, 7L).length(), 2)
  assert_eq(ledger.get("key-0", 7L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 7L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 7L, 7L), None)
  assert_eq(ledger.snapshot(25L, 25L).length(), 3)
  assert_eq(ledger.get("key-0", 25L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-1", 25L, 25L), Some("value-4"))
  assert_eq(ledger.get("key-2", 25L, 25L), Some("value-1"))
  assert_eq(ledger.snapshot(80L, 80L).length(), 3)
  assert_eq(ledger.get("key-0", 80L, 80L), Some("value-3"))
  assert_eq(ledger.get("key-1", 80L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-2", 80L, 80L), Some("value-5"))
  assert_eq(ledger.snapshot(200L, 200L).length(), 3)
  assert_eq(ledger.get("key-0", 200L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 200L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 200L, 200L), Some("value-1"))
}

///|
test "Rust reference shared open-span semantics case 2" {
  let builder = try! @moonbitemporal.LedgerBuilder::new()
  builder.append(1L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(-10L),
      "value-0",
    ),
  ])
  builder.append(4L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(7L),
      "value-1",
    ),
  ])
  builder.append(7L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(24L),
      "value-2",
    ),
  ])
  builder.append(10L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(0L),
      "value-3",
    ),
  ])
  builder.append(13L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(17L),
      "value-4",
    ),
  ])
  builder.append(16L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(-7L),
      "value-5",
    ),
  ])
  builder.append(19L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(10L),
      "value-6",
    ),
  ])
  builder.append(22L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(27L),
      "value-0",
    ),
  ])
  builder.append(25L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(3L),
      "value-1",
    ),
  ])
  builder.append(28L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(20L),
      "value-2",
    ),
  ])
  builder.append(31L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(-4L),
      "value-3",
    ),
  ])
  builder.append(34L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(13L),
      "value-4",
    ),
  ])
  builder.append(37L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(30L),
      "value-5",
    ),
  ])
  builder.append(40L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(6L),
      "value-6",
    ),
  ])
  builder.append(43L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(23L),
      "value-0",
    ),
  ])
  builder.append(46L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(-1L),
      "value-1",
    ),
  ])
  builder.append(49L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(16L),
      "value-2",
    ),
  ])
  builder.append(52L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(-8L),
      "value-3",
    ),
  ])
  builder.append(55L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(9L),
      "value-4",
    ),
  ])
  builder.append(58L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(26L),
      "value-5",
    ),
  ])
  builder.append(61L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(2L),
      "value-6",
    ),
  ])
  builder.append(64L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(19L),
      "value-0",
    ),
  ])
  builder.append(67L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(-5L),
      "value-1",
    ),
  ])
  builder.append(70L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(12L),
      "value-2",
    ),
  ])
  builder.append(73L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(29L),
      "value-3",
    ),
  ])
  builder.append(76L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(5L),
      "value-4",
    ),
  ])
  builder.append(79L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(22L),
      "value-5",
    ),
  ])
  builder.append(82L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(-2L),
      "value-6",
    ),
  ])
  builder.append(85L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(15L),
      "value-0",
    ),
  ])
  builder.append(88L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(-9L),
      "value-1",
    ),
  ])
  builder.append(91L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(8L),
      "value-2",
    ),
  ])
  builder.append(94L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(25L),
      "value-3",
    ),
  ])
  builder.append(97L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(1L),
      "value-4",
    ),
  ])
  builder.append(100L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(18L),
      "value-5",
    ),
  ])
  builder.append(103L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(-6L),
      "value-6",
    ),
  ])
  builder.append(106L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(11L),
      "value-0",
    ),
  ])
  builder.append(109L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(28L),
      "value-1",
    ),
  ])
  builder.append(112L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(4L),
      "value-2",
    ),
  ])
  builder.append(115L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(21L),
      "value-3",
    ),
  ])
  builder.append(118L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(-3L),
      "value-4",
    ),
  ])
  builder.append(121L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(14L),
      "value-5",
    ),
  ])
  builder.append(124L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(-10L),
      "value-6",
    ),
  ])
  builder.append(127L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(7L),
      "value-0",
    ),
  ])
  builder.append(130L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(24L),
      "value-1",
    ),
  ])
  builder.append(133L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(0L),
      "value-2",
    ),
  ])
  builder.append(136L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(17L),
      "value-3",
    ),
  ])
  builder.append(139L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(-7L),
      "value-4",
    ),
  ])
  builder.append(142L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(10L),
      "value-5",
    ),
  ])
  builder.append(145L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(27L),
      "value-6",
    ),
  ])
  builder.append(148L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(3L),
      "value-0",
    ),
  ])
  builder.append(151L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(20L),
      "value-1",
    ),
  ])
  builder.append(154L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(-4L),
      "value-2",
    ),
  ])
  builder.append(157L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(13L),
      "value-3",
    ),
  ])
  builder.append(160L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(30L),
      "value-4",
    ),
  ])
  builder.append(163L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(6L),
      "value-5",
    ),
  ])
  builder.append(166L, [
    @moonbitemporal.Change::put(
      "key-0",
      @moonbitemporal.Span::open(23L),
      "value-6",
    ),
  ])
  builder.append(169L, [
    @moonbitemporal.Change::put(
      "key-1",
      @moonbitemporal.Span::open(-1L),
      "value-0",
    ),
  ])
  builder.append(172L, [
    @moonbitemporal.Change::put(
      "key-2",
      @moonbitemporal.Span::open(16L),
      "value-1",
    ),
  ])
  builder.append(175L, [
    @moonbitemporal.Change::put(
      "key-3",
      @moonbitemporal.Span::open(-8L),
      "value-2",
    ),
  ])
  builder.append(178L, [
    @moonbitemporal.Change::put(
      "key-4",
      @moonbitemporal.Span::open(9L),
      "value-3",
    ),
  ])
  let ledger = builder.freeze()
  assert_eq(ledger.snapshot(-11L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, -1L), None)
  assert_eq(ledger.get("key-1", -11L, -1L), None)
  assert_eq(ledger.get("key-2", -11L, -1L), None)
  assert_eq(ledger.get("key-3", -11L, -1L), None)
  assert_eq(ledger.get("key-4", -11L, -1L), None)
  assert_eq(ledger.snapshot(-11L, 1L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 1L), None)
  assert_eq(ledger.get("key-1", -11L, 1L), None)
  assert_eq(ledger.get("key-2", -11L, 1L), None)
  assert_eq(ledger.get("key-3", -11L, 1L), None)
  assert_eq(ledger.get("key-4", -11L, 1L), None)
  assert_eq(ledger.snapshot(-11L, 7L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 7L), None)
  assert_eq(ledger.get("key-1", -11L, 7L), None)
  assert_eq(ledger.get("key-2", -11L, 7L), None)
  assert_eq(ledger.get("key-3", -11L, 7L), None)
  assert_eq(ledger.get("key-4", -11L, 7L), None)
  assert_eq(ledger.snapshot(-11L, 25L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 25L), None)
  assert_eq(ledger.get("key-1", -11L, 25L), None)
  assert_eq(ledger.get("key-2", -11L, 25L), None)
  assert_eq(ledger.get("key-3", -11L, 25L), None)
  assert_eq(ledger.get("key-4", -11L, 25L), None)
  assert_eq(ledger.snapshot(-11L, 80L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 80L), None)
  assert_eq(ledger.get("key-1", -11L, 80L), None)
  assert_eq(ledger.get("key-2", -11L, 80L), None)
  assert_eq(ledger.get("key-3", -11L, 80L), None)
  assert_eq(ledger.get("key-4", -11L, 80L), None)
  assert_eq(ledger.snapshot(-11L, 200L).length(), 0)
  assert_eq(ledger.get("key-0", -11L, 200L), None)
  assert_eq(ledger.get("key-1", -11L, 200L), None)
  assert_eq(ledger.get("key-2", -11L, 200L), None)
  assert_eq(ledger.get("key-3", -11L, 200L), None)
  assert_eq(ledger.get("key-4", -11L, 200L), None)
  assert_eq(ledger.snapshot(-10L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", -10L, -1L), None)
  assert_eq(ledger.get("key-1", -10L, -1L), None)
  assert_eq(ledger.get("key-2", -10L, -1L), None)
  assert_eq(ledger.get("key-3", -10L, -1L), None)
  assert_eq(ledger.get("key-4", -10L, -1L), None)
  assert_eq(ledger.snapshot(-10L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", -10L, 1L), None)
  assert_eq(ledger.get("key-2", -10L, 1L), None)
  assert_eq(ledger.get("key-3", -10L, 1L), None)
  assert_eq(ledger.get("key-4", -10L, 1L), None)
  assert_eq(ledger.snapshot(-10L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", -10L, 7L), None)
  assert_eq(ledger.get("key-2", -10L, 7L), None)
  assert_eq(ledger.get("key-3", -10L, 7L), None)
  assert_eq(ledger.get("key-4", -10L, 7L), None)
  assert_eq(ledger.snapshot(-10L, 25L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 25L), Some("value-0"))
  assert_eq(ledger.get("key-1", -10L, 25L), None)
  assert_eq(ledger.get("key-2", -10L, 25L), None)
  assert_eq(ledger.get("key-3", -10L, 25L), None)
  assert_eq(ledger.get("key-4", -10L, 25L), None)
  assert_eq(ledger.snapshot(-10L, 80L).length(), 1)
  assert_eq(ledger.get("key-0", -10L, 80L), Some("value-0"))
  assert_eq(ledger.get("key-1", -10L, 80L), None)
  assert_eq(ledger.get("key-2", -10L, 80L), None)
  assert_eq(ledger.get("key-3", -10L, 80L), None)
  assert_eq(ledger.get("key-4", -10L, 80L), None)
  assert_eq(ledger.snapshot(-10L, 200L).length(), 2)
  assert_eq(ledger.get("key-0", -10L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-1", -10L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-2", -10L, 200L), None)
  assert_eq(ledger.get("key-3", -10L, 200L), None)
  assert_eq(ledger.get("key-4", -10L, 200L), None)
  assert_eq(ledger.snapshot(0L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 0L, -1L), None)
  assert_eq(ledger.get("key-1", 0L, -1L), None)
  assert_eq(ledger.get("key-2", 0L, -1L), None)
  assert_eq(ledger.get("key-3", 0L, -1L), None)
  assert_eq(ledger.get("key-4", 0L, -1L), None)
  assert_eq(ledger.snapshot(0L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 0L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 0L, 1L), None)
  assert_eq(ledger.get("key-2", 0L, 1L), None)
  assert_eq(ledger.get("key-3", 0L, 1L), None)
  assert_eq(ledger.get("key-4", 0L, 1L), None)
  assert_eq(ledger.snapshot(0L, 7L).length(), 1)
  assert_eq(ledger.get("key-0", 0L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 0L, 7L), None)
  assert_eq(ledger.get("key-2", 0L, 7L), None)
  assert_eq(ledger.get("key-3", 0L, 7L), None)
  assert_eq(ledger.get("key-4", 0L, 7L), None)
  assert_eq(ledger.snapshot(0L, 25L).length(), 2)
  assert_eq(ledger.get("key-0", 0L, 25L), Some("value-5"))
  assert_eq(ledger.get("key-1", 0L, 25L), None)
  assert_eq(ledger.get("key-2", 0L, 25L), None)
  assert_eq(ledger.get("key-3", 0L, 25L), Some("value-3"))
  assert_eq(ledger.get("key-4", 0L, 25L), None)
  assert_eq(ledger.snapshot(0L, 80L).length(), 3)
  assert_eq(ledger.get("key-0", 0L, 80L), Some("value-1"))
  assert_eq(ledger.get("key-1", 0L, 80L), None)
  assert_eq(ledger.get("key-2", 0L, 80L), Some("value-1"))
  assert_eq(ledger.get("key-3", 0L, 80L), Some("value-3"))
  assert_eq(ledger.get("key-4", 0L, 80L), None)
  assert_eq(ledger.snapshot(0L, 200L).length(), 5)
  assert_eq(ledger.get("key-0", 0L, 200L), Some("value-1"))
  assert_eq(ledger.get("key-1", 0L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 0L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-3", 0L, 200L), Some("value-2"))
  assert_eq(ledger.get("key-4", 0L, 200L), Some("value-2"))
  assert_eq(ledger.snapshot(10L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 10L, -1L), None)
  assert_eq(ledger.get("key-1", 10L, -1L), None)
  assert_eq(ledger.get("key-2", 10L, -1L), None)
  assert_eq(ledger.get("key-3", 10L, -1L), None)
  assert_eq(ledger.get("key-4", 10L, -1L), None)
  assert_eq(ledger.snapshot(10L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 10L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 10L, 1L), None)
  assert_eq(ledger.get("key-2", 10L, 1L), None)
  assert_eq(ledger.get("key-3", 10L, 1L), None)
  assert_eq(ledger.get("key-4", 10L, 1L), None)
  assert_eq(ledger.snapshot(10L, 7L).length(), 2)
  assert_eq(ledger.get("key-0", 10L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 10L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 10L, 7L), None)
  assert_eq(ledger.get("key-3", 10L, 7L), None)
  assert_eq(ledger.get("key-4", 10L, 7L), None)
  assert_eq(ledger.snapshot(10L, 25L).length(), 3)
  assert_eq(ledger.get("key-0", 10L, 25L), Some("value-5"))
  assert_eq(ledger.get("key-1", 10L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-2", 10L, 25L), None)
  assert_eq(ledger.get("key-3", 10L, 25L), Some("value-1"))
  assert_eq(ledger.get("key-4", 10L, 25L), None)
  assert_eq(ledger.snapshot(10L, 80L).length(), 4)
  assert_eq(ledger.get("key-0", 10L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-1", 10L, 80L), Some("value-6"))
  assert_eq(ledger.get("key-2", 10L, 80L), Some("value-1"))
  assert_eq(ledger.get("key-3", 10L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-4", 10L, 80L), None)
  assert_eq(ledger.snapshot(10L, 200L).length(), 5)
  assert_eq(ledger.get("key-0", 10L, 200L), Some("value-2"))
  assert_eq(ledger.get("key-1", 10L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 10L, 200L), Some("value-5"))
  assert_eq(ledger.get("key-3", 10L, 200L), Some("value-2"))
  assert_eq(ledger.get("key-4", 10L, 200L), Some("value-3"))
  assert_eq(ledger.snapshot(20L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 20L, -1L), None)
  assert_eq(ledger.get("key-1", 20L, -1L), None)
  assert_eq(ledger.get("key-2", 20L, -1L), None)
  assert_eq(ledger.get("key-3", 20L, -1L), None)
  assert_eq(ledger.get("key-4", 20L, -1L), None)
  assert_eq(ledger.snapshot(20L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 20L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 20L, 1L), None)
  assert_eq(ledger.get("key-2", 20L, 1L), None)
  assert_eq(ledger.get("key-3", 20L, 1L), None)
  assert_eq(ledger.get("key-4", 20L, 1L), None)
  assert_eq(ledger.snapshot(20L, 7L).length(), 2)
  assert_eq(ledger.get("key-0", 20L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 20L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 20L, 7L), None)
  assert_eq(ledger.get("key-3", 20L, 7L), None)
  assert_eq(ledger.get("key-4", 20L, 7L), None)
  assert_eq(ledger.snapshot(20L, 25L).length(), 4)
  assert_eq(ledger.get("key-0", 20L, 25L), Some("value-5"))
  assert_eq(ledger.get("key-1", 20L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-2", 20L, 25L), None)
  assert_eq(ledger.get("key-3", 20L, 25L), Some("value-1"))
  assert_eq(ledger.get("key-4", 20L, 25L), Some("value-4"))
  assert_eq(ledger.snapshot(20L, 80L).length(), 5)
  assert_eq(ledger.get("key-0", 20L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-1", 20L, 80L), Some("value-0"))
  assert_eq(ledger.get("key-2", 20L, 80L), Some("value-1"))
  assert_eq(ledger.get("key-3", 20L, 80L), Some("value-2"))
  assert_eq(ledger.get("key-4", 20L, 80L), Some("value-2"))
  assert_eq(ledger.snapshot(20L, 200L).length(), 5)
  assert_eq(ledger.get("key-0", 20L, 200L), Some("value-1"))
  assert_eq(ledger.get("key-1", 20L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 20L, 200L), Some("value-1"))
  assert_eq(ledger.get("key-3", 20L, 200L), Some("value-2"))
  assert_eq(ledger.get("key-4", 20L, 200L), Some("value-3"))
  assert_eq(ledger.snapshot(30L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 30L, -1L), None)
  assert_eq(ledger.get("key-1", 30L, -1L), None)
  assert_eq(ledger.get("key-2", 30L, -1L), None)
  assert_eq(ledger.get("key-3", 30L, -1L), None)
  assert_eq(ledger.get("key-4", 30L, -1L), None)
  assert_eq(ledger.snapshot(30L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 30L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 30L, 1L), None)
  assert_eq(ledger.get("key-2", 30L, 1L), None)
  assert_eq(ledger.get("key-3", 30L, 1L), None)
  assert_eq(ledger.get("key-4", 30L, 1L), None)
  assert_eq(ledger.snapshot(30L, 7L).length(), 3)
  assert_eq(ledger.get("key-0", 30L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 30L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 30L, 7L), Some("value-2"))
  assert_eq(ledger.get("key-3", 30L, 7L), None)
  assert_eq(ledger.get("key-4", 30L, 7L), None)
  assert_eq(ledger.snapshot(30L, 25L).length(), 5)
  assert_eq(ledger.get("key-0", 30L, 25L), Some("value-5"))
  assert_eq(ledger.get("key-1", 30L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-2", 30L, 25L), Some("value-0"))
  assert_eq(ledger.get("key-3", 30L, 25L), Some("value-1"))
  assert_eq(ledger.get("key-4", 30L, 25L), Some("value-4"))
  assert_eq(ledger.snapshot(30L, 80L).length(), 5)
  assert_eq(ledger.get("key-0", 30L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-1", 30L, 80L), Some("value-5"))
  assert_eq(ledger.get("key-2", 30L, 80L), Some("value-1"))
  assert_eq(ledger.get("key-3", 30L, 80L), Some("value-2"))
  assert_eq(ledger.get("key-4", 30L, 80L), Some("value-3"))
  assert_eq(ledger.snapshot(30L, 200L).length(), 5)
  assert_eq(ledger.get("key-0", 30L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 30L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 30L, 200L), Some("value-1"))
  assert_eq(ledger.get("key-3", 30L, 200L), Some("value-2"))
  assert_eq(ledger.get("key-4", 30L, 200L), Some("value-3"))
  assert_eq(ledger.snapshot(31L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 31L, -1L), None)
  assert_eq(ledger.get("key-1", 31L, -1L), None)
  assert_eq(ledger.get("key-2", 31L, -1L), None)
  assert_eq(ledger.get("key-3", 31L, -1L), None)
  assert_eq(ledger.get("key-4", 31L, -1L), None)
  assert_eq(ledger.snapshot(31L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 31L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 31L, 1L), None)
  assert_eq(ledger.get("key-2", 31L, 1L), None)
  assert_eq(ledger.get("key-3", 31L, 1L), None)
  assert_eq(ledger.get("key-4", 31L, 1L), None)
  assert_eq(ledger.snapshot(31L, 7L).length(), 3)
  assert_eq(ledger.get("key-0", 31L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 31L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 31L, 7L), Some("value-2"))
  assert_eq(ledger.get("key-3", 31L, 7L), None)
  assert_eq(ledger.get("key-4", 31L, 7L), None)
  assert_eq(ledger.snapshot(31L, 25L).length(), 5)
  assert_eq(ledger.get("key-0", 31L, 25L), Some("value-5"))
  assert_eq(ledger.get("key-1", 31L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-2", 31L, 25L), Some("value-0"))
  assert_eq(ledger.get("key-3", 31L, 25L), Some("value-1"))
  assert_eq(ledger.get("key-4", 31L, 25L), Some("value-4"))
  assert_eq(ledger.snapshot(31L, 80L).length(), 5)
  assert_eq(ledger.get("key-0", 31L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-1", 31L, 80L), Some("value-5"))
  assert_eq(ledger.get("key-2", 31L, 80L), Some("value-1"))
  assert_eq(ledger.get("key-3", 31L, 80L), Some("value-2"))
  assert_eq(ledger.get("key-4", 31L, 80L), Some("value-3"))
  assert_eq(ledger.snapshot(31L, 200L).length(), 5)
  assert_eq(ledger.get("key-0", 31L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 31L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 31L, 200L), Some("value-1"))
  assert_eq(ledger.get("key-3", 31L, 200L), Some("value-2"))
  assert_eq(ledger.get("key-4", 31L, 200L), Some("value-3"))
  assert_eq(ledger.snapshot(60L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", 60L, -1L), None)
  assert_eq(ledger.get("key-1", 60L, -1L), None)
  assert_eq(ledger.get("key-2", 60L, -1L), None)
  assert_eq(ledger.get("key-3", 60L, -1L), None)
  assert_eq(ledger.get("key-4", 60L, -1L), None)
  assert_eq(ledger.snapshot(60L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 60L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 60L, 1L), None)
  assert_eq(ledger.get("key-2", 60L, 1L), None)
  assert_eq(ledger.get("key-3", 60L, 1L), None)
  assert_eq(ledger.get("key-4", 60L, 1L), None)
  assert_eq(ledger.snapshot(60L, 7L).length(), 3)
  assert_eq(ledger.get("key-0", 60L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 60L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 60L, 7L), Some("value-2"))
  assert_eq(ledger.get("key-3", 60L, 7L), None)
  assert_eq(ledger.get("key-4", 60L, 7L), None)
  assert_eq(ledger.snapshot(60L, 25L).length(), 5)
  assert_eq(ledger.get("key-0", 60L, 25L), Some("value-5"))
  assert_eq(ledger.get("key-1", 60L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-2", 60L, 25L), Some("value-0"))
  assert_eq(ledger.get("key-3", 60L, 25L), Some("value-1"))
  assert_eq(ledger.get("key-4", 60L, 25L), Some("value-4"))
  assert_eq(ledger.snapshot(60L, 80L).length(), 5)
  assert_eq(ledger.get("key-0", 60L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-1", 60L, 80L), Some("value-5"))
  assert_eq(ledger.get("key-2", 60L, 80L), Some("value-1"))
  assert_eq(ledger.get("key-3", 60L, 80L), Some("value-2"))
  assert_eq(ledger.get("key-4", 60L, 80L), Some("value-3"))
  assert_eq(ledger.snapshot(60L, 200L).length(), 5)
  assert_eq(ledger.get("key-0", 60L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 60L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 60L, 200L), Some("value-1"))
  assert_eq(ledger.get("key-3", 60L, 200L), Some("value-2"))
  assert_eq(ledger.get("key-4", 60L, 200L), Some("value-3"))
  assert_eq(ledger.snapshot(-1L, -1L).length(), 0)
  assert_eq(ledger.get("key-0", -1L, -1L), None)
  assert_eq(ledger.get("key-1", -1L, -1L), None)
  assert_eq(ledger.get("key-2", -1L, -1L), None)
  assert_eq(ledger.get("key-3", -1L, -1L), None)
  assert_eq(ledger.get("key-4", -1L, -1L), None)
  assert_eq(ledger.snapshot(0L, 0L).length(), 0)
  assert_eq(ledger.get("key-0", 0L, 0L), None)
  assert_eq(ledger.get("key-1", 0L, 0L), None)
  assert_eq(ledger.get("key-2", 0L, 0L), None)
  assert_eq(ledger.get("key-3", 0L, 0L), None)
  assert_eq(ledger.get("key-4", 0L, 0L), None)
  assert_eq(ledger.snapshot(1L, 1L).length(), 1)
  assert_eq(ledger.get("key-0", 1L, 1L), Some("value-0"))
  assert_eq(ledger.get("key-1", 1L, 1L), None)
  assert_eq(ledger.get("key-2", 1L, 1L), None)
  assert_eq(ledger.get("key-3", 1L, 1L), None)
  assert_eq(ledger.get("key-4", 1L, 1L), None)
  assert_eq(ledger.snapshot(7L, 7L).length(), 2)
  assert_eq(ledger.get("key-0", 7L, 7L), Some("value-0"))
  assert_eq(ledger.get("key-1", 7L, 7L), Some("value-1"))
  assert_eq(ledger.get("key-2", 7L, 7L), None)
  assert_eq(ledger.get("key-3", 7L, 7L), None)
  assert_eq(ledger.get("key-4", 7L, 7L), None)
  assert_eq(ledger.snapshot(25L, 25L).length(), 5)
  assert_eq(ledger.get("key-0", 25L, 25L), Some("value-5"))
  assert_eq(ledger.get("key-1", 25L, 25L), Some("value-6"))
  assert_eq(ledger.get("key-2", 25L, 25L), Some("value-2"))
  assert_eq(ledger.get("key-3", 25L, 25L), Some("value-1"))
  assert_eq(ledger.get("key-4", 25L, 25L), Some("value-4"))
  assert_eq(ledger.snapshot(80L, 80L).length(), 5)
  assert_eq(ledger.get("key-0", 80L, 80L), Some("value-4"))
  assert_eq(ledger.get("key-1", 80L, 80L), Some("value-5"))
  assert_eq(ledger.get("key-2", 80L, 80L), Some("value-1"))
  assert_eq(ledger.get("key-3", 80L, 80L), Some("value-2"))
  assert_eq(ledger.get("key-4", 80L, 80L), Some("value-3"))
  assert_eq(ledger.snapshot(200L, 200L).length(), 5)
  assert_eq(ledger.get("key-0", 200L, 200L), Some("value-6"))
  assert_eq(ledger.get("key-1", 200L, 200L), Some("value-0"))
  assert_eq(ledger.get("key-2", 200L, 200L), Some("value-1"))
  assert_eq(ledger.get("key-3", 200L, 200L), Some("value-2"))
  assert_eq(ledger.get("key-4", 200L, 200L), Some("value-3"))
}
