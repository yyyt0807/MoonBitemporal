# Verification and test coverage

The standard local gate is:

```sh
moon fmt --check
moon check --target all --deny-warn
moon build --target all --deny-warn
moon test --target all --deny-warn
moon run examples/pricing --target wasm-gc
moon run examples/access --target wasm-gc
moon run examples/calibration --target wasm-gc
moon run examples/rollout --target wasm-gc
```

The GitHub Actions workflow runs these checks on Ubuntu and Windows. Local success does not prove a remote CI run passed; verify the public default branch and its latest run after push.

Tests cover normal assignment, retroactive correction, withdrawal, adjacent and overlapping batches, empty or invalid inputs, signed 64-bit boundaries, unbounded spans, overflow, archive round trips, duplicate JSON members, out-of-order knowledge batches, limits, immutable snapshot isolation, builder equivalence, tail replay and divergent archive detection. Generated histories compare point queries and both timeline axes with a deliberately simple forward-scan model. Four backend test targets—Wasm, Wasm-GC, JavaScript and Native—must all pass.

The runnable examples serve as integration checks: pricing reproduces an old invoice; access distinguishes what an incident-time system knew from later policy correction; calibration aligns metadata changes; rollout compares a candidate rule history against a deployed one and rejects a divergent sibling branch. Their assertions must pass, not merely their process startup.

Stress-oriented cases include a 1,000-change disjoint batch, hundreds of sequential archive batches, long builder ingestion and generated overlap histories. These are correctness workloads rather than benchmark results. The library limits input size, revision count, segment count, key count and sampled matrix cells; callers can set tighter budgets for untrusted workloads. No network service or concurrent writer exists in the core, so remote throughput and race properties require adapter-specific testing.
