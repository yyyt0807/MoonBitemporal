# MoonBitemporal

MoonBitemporal is a pure MoonBit core for bitemporal facts: it records both **when a value applies** and **when a system learned or corrected it**. Applications can answer two distinct questions: “What do we now believe was true on day X?” and “What did we believe on day X at the time?”

The project is being developed locally. GitHub push and mooncakes.io publication are planned after local completion and review.

## Scope

- Append-only revisions for keyed facts with half-open valid-time spans.
- Caller-supplied, strictly increasing knowledge time for reproducible history.
- Point-in-time lookup and timeline reconstruction, including retroactive correction and withdrawal.
- Atomic validation of revision batches; explicit errors for bad spans, duplicate keys within a batch, stale knowledge time and resource limits.
- Portable core for Native, JavaScript, Wasm and Wasm-GC.

This is a temporal decision library. It does not persist records, manage transactions across processes, infer timezones, authenticate writers, or replace a database.

## Development

```sh
moon check --target all --deny-warn
moon test --target all --deny-warn
moon run examples/pricing --target wasm-gc
```

## License

Apache-2.0. The implementation is original; external standards and related projects are cited in `docs/ECOSYSTEM_RESEARCH.md`.
