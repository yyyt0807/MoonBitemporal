# October additions and review

`Ledger::snapshot_selected(keys, valid_at, known_at, max_keys?)` addresses narrow API responses and selective recomputation. It deduplicates requested keys with a bounded set, sorts only the distinct keys, then queries, enforces the unique-key budget, omits withdrawn/unclaimed keys, and retains source revisions in returned facts. Cost is `O(q + u log u + sum h_i)` for `q` input keys, `u` distinct keys and their inspected histories `h_i`, rather than sorting every ledger key. This is a bounded result API, not a new persistence model.

`Ledger::batch_at(known_at)` retrieves the exact atomic commit group at one knowledge instant using a lower-bound search over the append log and scans only that group. Cost is `O(log n + b)` for `n` revisions and batch size `b`, with `O(b)` returned memory. It returns `None` for an absent instant and does not reinterpret timezones or calendar units.

The October charter also requires a public repository, successful latest CI and mooncakes.io publication for final acceptance. Local tests cannot prove those external states. The applicant must verify them and personally finalize the one-page proposal. Since the charter says one project per entrant in principle, eligibility of six concurrent submissions requires organizer confirmation.

## 十月第二轮：完整批次分页与多键联合覆盖

`Ledger::batches_since(None, max_batches?, max_revisions?)` 从账本起点读取完整原子批次；传 `Some(known_at)` 则严格读取该游标之后的批次。结果的 `next_known_at()` 可继续请求，`has_more()` 区分结束；首批超过修订预算会报错，避免不前进的空页。空游标能包含 Int64 最小时间戳，无须做游标加一。

`joint_assigned_spans(keys, bounds, known_at, max_keys?, max_segments?)` 返回全部指定键同时有值的最大有效区间；不比较值、不执行授权规则，空键集返回整个 bounds。查询键先以有界集合去重再排序，重复键不占额外唯一键预算。运行 `moon run examples/maintenance --target wasm-gc`。详见 [本轮审查与复杂度](SECOND_REVIEW.md) 和 [十月申报资料稿](../十月项目申报书.md)。
