# Fixed workload and local timing record

The executable [`benchmarks/main`](../benchmarks/main/main.mbt) appends 2,000 one-change knowledge batches through `LedgerBuilder` across 16 keys, freezes a ledger, makes 5,000 indexed point queries, reconstructs one valid-time timeline, then exports and imports the entire archive. It checks the restored result and prints a deterministic checksum. This workload is intended to detect gross performance regressions and correctness failures; it is not a representative production trace.

Run from the repository root:

```sh
moon run benchmarks/main --target native --release
```

Expected output on the 2026-10-01 source revision:

```text
revisions=2000 queries=5000 timeline_segments=95
checksum=6108083
```

One local exploratory measurement on Windows NT 10.0.19045.0 with `moonc v0.10.14` built the Native release executable, then invoked that executable five times after the build. Process wall times measured by PowerShell `Stopwatch` were 44.14, 38.89, 39.52, 45.23 and 42.51 ms; median 42.51 ms. These include process startup and archive text work. Processor details were unavailable in this sandbox. Do not compare this figure with other systems or infer per-operation latency from it. Re-run the workload on the target machine and inspect the same checksum before drawing performance conclusions.
