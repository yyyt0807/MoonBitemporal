# Keep two explicit clocks and an append-only revision log

The library accepts caller-supplied integer valid-time and knowledge-time values and never reads a wall clock. Revisions remain append-only, and a later claim wins only inside its own valid-time span. This makes retroactive corrections reproducible across Native, JavaScript and WebAssembly without binding the core to a database, timezone library or operating-system clock; callers must supply trustworthy monotonic knowledge times.
