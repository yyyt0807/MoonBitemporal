# Security and data handling boundaries

MoonBitemporal is an in-memory semantic core. It does not authenticate a writer, authorize a correction, attest an archive, guarantee persistence or coordinate concurrent processes. Applications must provide these controls before using its results to make security, billing or compliance decisions.

- **Knowledge order:** The caller supplies a strictly increasing `Int64` per batch. A wall-clock timestamp from an untrusted source is not an adequate transaction sequencer. Durable adapters should commit the order and archive together.
- **Archive integrity:** Text import rejects duplicate JSON keys, unknown fields, malformed decimal instants, invalid intervals and illegal batches. These checks protect interpretation but are not a signature or provenance proof. Use authenticated transport and storage, and compare full histories with `reconcile` when a tail's ancestry is uncertain.
- **Resource limits:** Archive text, JSON nesting and node count, revision count, report segments, key count, page size and matrix cells have explicit caps. The defaults fit ordinary in-memory use; hostile or large inputs may require stricter caller limits. `from_json(Json)` cannot detect duplicate members already collapsed by another parser.
- **Confidentiality:** Keys and payload strings can contain sensitive values. `trace`, archives and change reports may expose previous values. Avoid logging them without a reviewable redaction policy. The library intentionally does not claim anonymization.
- **Concurrency:** `Ledger` values are independent immutable snapshots. `LedgerBuilder` is mutable and intended for one coordinated writer; do not share it across concurrent writers without an external lock and ordering policy.
- **Time semantics:** The library has no timezone or calendar understanding. Translate to a consistent integral unit before submission, and document how daylight-saving changes and leap seconds are handled in the adapter.

Report a suspected correctness or security issue through the repository's issue tracker after the public repository is created. Until then, keep sensitive example data out of commits.
