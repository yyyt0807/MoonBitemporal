# API and archive contract

## Time model

`Span::new(start,end)` raises `TEMPORAL_INVALID_SPAN` unless `end > start`; `Span::open(start)` extends through every later representable `Int64` instant. The `end` field is exclusive. The caller chooses a consistent unit such as milliseconds or days and translates timezones before invoking the library. Mixed units are a caller error that the core cannot detect.

`Ledger::commit(known_at, changes)` requires `known_at` to exceed the preceding batch instant. Identical instants across independent processes require an external sequencer. A batch can contain several keys or disjoint intervals of one key. Later claims override earlier claims only where their valid spans overlap.

## Query selection

| Need | API |
| --- | --- |
| Value or withdrawal at one two-clock point | `get`, `observe`, `trace` |
| All visible keys at a point | `snapshot` |
| One key's full valid-time state inside a window | `timeline`, `matching_spans`, `coverage` |
| One valid instant as knowledge changes | `knowledge_timeline` |
| Several keys across one valid-time window | `snapshot_timeline` |
| Changed values between two knowledge views | `diff_knowledge`, `diff_timeline`, `change_report` |
| Different complete ledgers | `compare_ledgers`, `compare_all_keys`, `reconcile` |
| Bounded sampled valid × knowledge grid | `sample_matrix` |
| Revision-level audit | `history`, `page`, `history_page`, `impact_of_revision` |

`get` returning `None` is ambiguous between never assigned and withdrawn. `observe` returns `None` only if no eligible claim exists. A returned revision with `value() == None` is an explicit tombstone. `Segment::is_gap` and `Segment::is_deleted` expose the same distinction for a timeline.

## Archive schema v1

An archive is a JSON object with exactly `schemaVersion` and `revisions`. Each revision has exactly `knownAt`, `key`, `validFrom`, `validTo`, and `value`. `schemaVersion` is the number `1`; `revisions` is an append-ordered array. All instants are canonical signed decimal **strings**, with no leading zeros or negative zero. `validTo` is either a decimal string or `null` for an open span. `value` is either a string or `null` for a tombstone. Sequence numbers are derived from array position and are not serialized.

```json
{"schemaVersion":1,"revisions":[{"knownAt":"10","key":"sku/coffee","validFrom":"0","validTo":null,"value":"USD 10"},{"knownAt":"20","key":"sku/coffee","validFrom":"30","validTo":"45","value":"USD 9.50"}]}
```

`from_json_string` checks the raw text for duplicate object members before standard JSON parsing. It also checks input length, nesting and node count; callers can choose a stricter character limit. The typed `from_json(Json)` entry cannot recover duplicate members lost by a prior parser. Both paths enforce the revision cap, field types, interval validity, knowledge order and same-batch overlap rule. Unknown fields and unsupported schema versions are rejected. Export is deterministic for the same ordered claims.

`to_json_since(cutoff)` exports claims with `knownAt > cutoff`; `append_json` accepts them only if their earliest knowledge instant is greater than the receiver's latest instant. A tail alone does not prove it came from the same source. Use an authenticated transport and a full-prefix `reconcile` when history divergence matters. `reconcile` compares content, not cryptographic signatures.

## Report schema v1

`ChangeReport::to_json_string` emits `schemaVersion`, `validWindow`, `beforeKnown`, `afterKnown`, `keysExamined`, `keysChanged`, `fragmentCount`, and ordered `entries`. Each entry carries a key and `fragments` with `valid`, `before`, and `after`. `TemporalMatrix::to_json_string` emits sampled row and column instants and row-major cells. These report formats are for evidence exchange; they are not accepted as archives. Instants are decimal strings in both formats.

The library does not assign a privacy classification to keys or values. Treat exported archives and reports according to the caller's data policy.
