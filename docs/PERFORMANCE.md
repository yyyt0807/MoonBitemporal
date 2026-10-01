# Algorithm and performance notes

Let `N` be total revisions, `k` the size of one submitted batch, `K` the distinct key count, `r` the number of revisions for the queried key, `b` the number of valid-time boundaries after clipping, `S` the number of output segments, and `V × T` the sampled matrix size.

| Operation | Time | Extra space | Reason |
| --- | --- | --- | --- |
| Immutable `Ledger::commit` | O(k log k + N + k) | O(N + k) | Sort-and-sweep batch validation, then log copy and index rebuild. |
| `LedgerBuilder::append` | O(k log k + k) expected | O(k) growth | Validate once; append to log and key indexes in place. Hash map assumptions apply. |
| `LedgerBuilder::freeze` | O(N) | O(N) | Detached log copy and index reconstruction. |
| `Ledger::get` / `observe` | O(log r + r) worst case | O(1) | Binary knowledge cutoff followed by backward valid-span scan. |
| `timeline` | O(r log r + b log r) | O(r + b + S) | Collect and sort events; heap sweep for winning claim. |
| `knowledge_timeline` | O(r) | O(r + S) | Applicable revisions already follow append order. |
| `diff_timeline` | Two timeline costs plus O(S_before + S_after) | Output and timelines | Two-pointer merge of partitioned windows. |
| `snapshot` | O(K log K + Σ per-key point query) | O(K) | Sort keys then use indexed point lookups. |
| `sample_matrix` | O(V × T × (log r + r)) worst case | O(V × T) | Each cell is a point query; product is capped before allocation. |
| `from_json` / `append_ledger` | O(N + Σ k_i log k_i) / O(N) | O(N) | Linear construction instead of one immutable commit per imported batch. |

The point-query worst case occurs when many later revisions for the same key have valid spans that do not cover the requested valid instant. The per-key index reduces irrelevant-key work and the binary cutoff removes revisions learned after the query, but it is not a full interval tree. `timeline` is preferable when many neighboring valid instants must be examined. `LedgerBuilder` is preferable for long write sequences; retaining an immutable ledger after **every** commit intentionally costs O(N²) total across N single-change commits.

For the scale reference in the October charter, this repository has more than 4,000 nonempty, noncomment MoonBit lines, including tests and runnable examples. This is a project size indicator, not a speed claim. The generated-history differential tests compare optimized queries against an independent forward-scan model. A fixed native release workload and one local timing record are in [benchmark evidence](BENCHMARK.md); they do not establish general throughput. Future benchmarks should vary key count, overlap density, batch size, checkpoint frequency and archive length on stated hardware.

Potential future optimization: persist per-key interval search structures for very large, overlap-heavy histories. That would improve worst-case point lookup but increase update cost and memory, complicate immutable snapshots and add another consistency invariant. Implement it only after workload measurements show the backward scan is a practical bottleneck.
