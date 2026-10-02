# October additions and review

`Ledger::snapshot_selected(keys, valid_at, known_at, max_keys?)` addresses narrow API responses and selective recomputation. It sorts and deduplicates requested keys before querying, enforces the unique-key budget, omits withdrawn/unclaimed keys, and retains source revisions in returned facts. Cost is `O(q log q + sum h_i)` for `q` requested keys and their inspected histories `h_i`, rather than sorting every ledger key. This is a bounded result API, not a new persistence model.

`Ledger::batch_at(known_at)` retrieves the exact atomic commit group at one knowledge instant using a lower-bound search over the append log and scans only that group. Cost is `O(log n + b)` for `n` revisions and batch size `b`, with `O(b)` returned memory. It returns `None` for an absent instant and does not reinterpret timezones or calendar units.

The October charter also requires a public repository, successful latest CI and mooncakes.io publication for final acceptance. Local tests cannot prove those external states. The applicant must verify them and personally finalize the one-page proposal. Since the charter says one project per entrant in principle, eligibility of six concurrent submissions requires organizer confirmation.
