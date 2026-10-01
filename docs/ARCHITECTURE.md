# Architecture and invariants

MoonBitemporal has one domain context, defined in [`CONTEXT.md`](../CONTEXT.md). It represents a claim as `(key, valid span, knowledge instant, value-or-tombstone, sequence)`. Instants are signed 64-bit integers supplied by the caller. A valid span is half-open; `None` as its right endpoint means an unbounded future. The latest appended eligible claim wins. A correction is a new claim and never modifies old claims.

## Invariants

1. A finite valid span has `start < end`. `[a,b)` and `[b,c)` touch but do not overlap.
2. A commit batch has at least one change and no empty key. Two changes for the same key in one batch cannot overlap; they may touch. All changes in a batch have one knowledge instant.
3. Knowledge instants strictly increase between batches, while multiple claims within one batch share that instant. The caller is responsible for obtaining and persisting that order.
4. A revision's sequence is its zero-based append position. The per-key index lists those positions in append order. `Ledger::commit`, archive import, projection, reconciliation and builder freeze reconstruct a coherent index.
5. An absent source and a tombstone are distinct states even though both produce `None` from `get`. `observe`, `timeline`, `trace` and the sampled matrix preserve this distinction.
6. A rejected commit, batch report, archive import or reconciliation leaves previously returned immutable ledgers untouched. The builder validates a whole batch before appending any item.

## Main modules

| Files | Responsibility |
| --- | --- |
| `span.mbt`, `span_algebra.mbt` | Half-open interval construction, intersection, subtraction, normalization and gaps. |
| `change.mbt`, `ledger.mbt`, `batch_validation.mbt` | Claims, immutable commits, per-key index and atomic batch validation. |
| `builder.mbt` | Mutable O(k)-append path with detached immutable checkpoints. |
| `timeline.mbt`, `timeline_heap.mbt`, `knowledge_timeline.mbt` | Two axis reconstructions; valid-time reconstruction uses a sweep heap. |
| `snapshot.mbt`, `snapshot_timeline.mbt`, `trace.mbt`, `matrix.mbt` | Point, multi-key, explanation and sampled two-clock views. |
| `diff.mbt`, `window_diff.mbt`, `impact.mbt`, `change_report.mbt` | Value-level changes within and between histories. |
| `archive_*.mbt`, `json_guard.mbt`, `instant.mbt`, `reconcile.mbt` | Versioned exchange, strict parsing and history reconciliation. |
| `coverage.mbt`, `span_filter.mbt`, `paging.mbt`, `statistics.mbt` | Bounded analytical and adapter-facing queries. |

## Precedence and reconstruction

A point query first uses the per-key index and binary-searches the last claim with `known_at <= query_known`. It scans backward until it finds a valid-time containing claim. The first match is the winner, including a tombstone. This is correct because the log is ordered by strictly increasing batch time, and no same-key spans overlap inside one batch.

A valid-time timeline collects starts and ends of eligible claims clipped to the requested window. It sorts those boundaries and start events, sweeps left to right and keeps active claims in a max-heap ordered by sequence. Expired heap entries are removed lazily. Each output segment is maximal for one winning source; adjacent equal-value claims may remain separate so provenance is preserved. `diff_timeline` instead merges adjacent fragments with equal before/after values, because its result is a value-level impact report.

The knowledge-time timeline is the dual view: fix a valid instant and walk applicable revisions in knowledge order. These explicit two-axis operations make a retroactive correction visible without erasing the belief held before its intake.

## Trade-offs

The immutable ledger copies its entire log and rebuilds its index per commit; this makes snapshots simple and independent but costs O(N) per batch. `LedgerBuilder` supports high-volume ingestion without repeated full copies and pays O(N) only at each explicit `freeze()`. The library uses opaque strings rather than a generic user-defined value type so archives, comparisons and examples behave uniformly across four MoonBit targets. Storage adapters can encode a domain value into a string; the core does not interpret that payload.

See [ADR 0001](adr/0001-two-clocks-and-append-only-revisions.md) for the two-clock decision and [performance](PERFORMANCE.md) for query costs.
