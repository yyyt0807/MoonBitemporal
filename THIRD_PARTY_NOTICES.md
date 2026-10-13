# Reference and third-party notices

MoonBitemporal's runtime implementation is original and licensed under Apache-2.0.

## Behavioral reference

- Name: **bitemporal-runtime 0.1.0**.
- Repository: https://github.com/sikmindz/bitemporal-runtime
- Published documentation/source: https://docs.rs/crate/bitemporal-runtime/0.1.0
- License: **MIT OR Apache-2.0**; see the upstream license texts in the published crate.
- Scope: API/behavior comparison and execution of the published Rust crate from the original adapter in `tools/reference/src/main.rs`. No upstream runtime source or test corpus is copied into this repository.
- Fixtures: `testdata/bitemporal-runtime-0.1.0.json` is output obtained by executing the adapter on original deterministic inputs. `reference_vectors_generated_test.mbt` is generated from that output by the original Python script; it is explicitly excluded from handwritten source counts.
- Rust-only dependencies: Cargo.lock records chrono (MIT OR Apache-2.0), serde/serde_json (MIT OR Apache-2.0), sha2 (MIT OR Apache-2.0), thiserror (MIT OR Apache-2.0) and their resolved dependencies. They are fetched by Cargo for optional reference validation; their code is not vendored or linked into the MoonBit runtime.

The MoonBit package imports the MoonBit standard library JSON module; the invoice example also uses the standard string parser. There is no third-party MoonBit runtime dependency. Reference tooling and fixtures do not establish wire compatibility, hash compatibility or performance equivalence.
