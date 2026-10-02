# MoonBitemporal

MoonBitemporal is an original, pure MoonBit library for facts with **two time axes**: the valid interval when a value applies in the modeled world, and the knowledge instant when the application accepted a claim. It answers both “What do we now believe applied on day X?” and “What did the application believe on day X before a later correction arrived?”

The repository is in local development. The planned module is `oyjh0381/moonbitemporal`; GitHub push and mooncakes.io publication will follow local completion and review. Do not use `moon add` until publication is confirmed.

## Why this exists

Pricing, access rules, reference data, calibration metadata and configuration all receive late corrections. Overwriting a record destroys the evidence needed to reproduce an earlier decision. A single timestamp cannot express both a backdated effective date and the later date when the correction became known. MoonBitemporal supplies those semantics without binding a MoonBit application to a particular database, clock, timezone, HTTP server or runtime target.

The ecosystem search and differences from interval trees, scheduling packages and this workspace's older projects are documented in [ecosystem research](docs/ECOSYSTEM_RESEARCH.md). Search results do not prove permanent uniqueness; repeat the check before submission and release.

## Core behavior

- `Span::new(start, end)` is half-open `[start, end)`; `Span::open(start)` has no right bound. Adjacent spans do not overlap.
- A `Change` assigns an opaque string or a tombstone to one key over a valid-time span. Keys are case-sensitive and nonempty.
- `Ledger::commit(known_at, changes)` validates the entire batch, then returns a new ledger. Knowledge instants must increase strictly between batches. Same-key changes in one batch may touch but may not overlap.
- The latest eligible claim whose valid span contains a queried instant wins. A tombstone is a visible withdrawal; a missing claim means nothing was ever known at that point.
- The caller supplies all instants as `Int64`. The library does not infer timezones, units, a system clock or trusted ordering.

```moonbit
let base = try! @temporal.Ledger::new()
let first = try! base.commit(
  10L,
  [@temporal.Change::put("sku/coffee", @temporal.Span::open(0L), "USD 10")],
)
let revised = try! first.commit(
  20L,
  [@temporal.Change::put("sku/coffee", try! @temporal.Span::new(30L, 45L), "USD 9.50")],
)
assert_eq(revised.get("sku/coffee", 35L, 10L), Some("USD 10"))
assert_eq(revised.get("sku/coffee", 35L, 20L), Some("USD 9.50"))
assert_eq(revised.get("sku/coffee", 50L, 20L), Some("USD 10"))
```

`Ledger::observe` returns the winning revision, including a tombstone. `get` returns only the effective value, so use `observe` or `trace` when absence and withdrawal must be distinguished. `timeline` partitions a valid-time window at every source change; `knowledge_timeline` shows how belief about one valid instant evolved. `diff_timeline`, `change_report` and `compare_all_keys` identify affected spans and keys. `coverage` totals assigned, withdrawn and unclaimed duration in a **finite** window. `sample_matrix` provides a bounded valid-time × knowledge-time grid.

October additions: `snapshot_selected` builds a bounded, sorted two-clock view for an explicit key set; `batch_at` retrieves one complete knowledge-time commit by binary search without scanning unrelated keys. See [October features](docs/OCTOBER_FEATURES.md).

## Ingestion, archives and integration

`Ledger::commit` keeps old values immutable and is convenient for short histories. `LedgerBuilder` appends batches in place for larger ingest workloads; `freeze()` returns a detached ledger checkpoint. `commit_with_report` is a dry-run-friendly way to inspect value-level effects before retaining the returned ledger.

`to_json_string` and `from_json_string` exchange a versioned archive. All `Int64` instants are decimal **strings**, so JavaScript consumers do not round values above 2^53. Text import limits input length, nesting and node count, rejects duplicate object members (including escaped equivalent spellings), validates every batch, and enforces a revision ceiling. `from_json(Json)` accepts an already parsed value, so duplicate keys cannot be detected at that entry point. `to_json_since` and `append_json` transfer a chronological tail; `reconcile` compares full archives and rejects a divergent shared prefix. Archive transport, authentication, durable transactions and replay authorization are the caller's responsibility.

The library's source and formats are documented in [architecture](docs/ARCHITECTURE.md), [API and archive contract](docs/API.md), [performance](docs/PERFORMANCE.md), [benchmark evidence](docs/BENCHMARK.md), [testing](docs/TESTING.md) and [security boundaries](docs/SECURITY.md).

## Run from source

Install a current [MoonBit toolchain](https://docs.moonbitlang.com/en/stable/) and run in this directory:

```sh
moon version --all
moon fmt --check
moon check --target all --deny-warn
moon build --target all --deny-warn
moon test --target all --deny-warn
moon run examples/pricing --target wasm-gc
moon run examples/access --target wasm-gc
moon run examples/calibration --target wasm-gc
moon run examples/rollout --target wasm-gc
moon run benchmarks/main --target native --release
```

The examples demonstrate invoice replay after a price correction, incident-time access review, corrected telemetry metadata and rule-rollout comparison. They contain assertions and print short verification summaries. CI is configured to run the same build and test gates on Ubuntu and Windows after the repository is pushed. Four backends are checked and tested locally: Wasm, Wasm-GC, JavaScript and Native.

## Boundaries and limitations

This library stores full revision history in memory and performs string-value comparison. It does not persist data, enforce who may submit a correction, coordinate concurrent writers, interpret calendars or parse business-specific payloads. The immutable `Ledger::commit` copies the full history; use `LedgerBuilder` for repeated large ingest. Timeline and report operations enforce caller-configurable output limits, but an application must also bound its own downstream storage and transmission costs. Revision order is defined by the supplied knowledge instants, not by an untrusted machine clock.

## Project status and license

The implementation is original and AI-assisted, not a port or copy of an upstream library. Standard concepts of valid time and system time are referenced in [ecosystem research](docs/ECOSYSTEM_RESEARCH.md); no third-party runtime package or copied test corpus is used. Source code is licensed under [Apache-2.0](LICENSE). The [October proposal draft](十月项目申报书.md) is for the applicant's own review and final authorship before official submission.
