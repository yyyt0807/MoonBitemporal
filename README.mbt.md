# MoonBitemporal

Pure MoonBit bitemporal revision and as-of query core. It records separate valid and knowledge times, preserves retroactive corrections, and exposes point queries, timelines, impact reports, archive exchange and a high-volume builder. See [README.md](README.md) for executable examples, integration boundaries and verification commands.

## Install as a dependency

```sh
moon add yyyt0807/moonbitemporal@0.1.0
```

Import the library in the consuming package's `moon.pkg`:

```text
import {
  "yyyt0807/moonbitemporal" @temporal,
}
```

Repository owner and maintenance commit identity: `yyyt0807`. License: Apache-2.0.
## 十月第二轮：完整批次分页与多键联合覆盖

`Ledger::batches_since(None, max_batches?, max_revisions?)` 从账本起点读取完整原子批次；传 `Some(known_at)` 则严格读取该游标之后的批次。结果的 `next_known_at()` 可继续请求，`has_more()` 区分结束；首批超过修订预算会报错，避免不前进的空页。空游标能包含 Int64 最小时间戳，无须做游标加一。

`joint_assigned_spans(keys, bounds, known_at, max_keys?, max_segments?)` 返回全部指定键同时有值的最大有效区间；不比较值、不执行授权规则，空键集返回整个 bounds。查询键先以有界集合去重再排序，重复键不占额外唯一键预算。运行 `moon run examples/maintenance --target wasm-gc`。详见 [本轮审查与复杂度](docs/SECOND_REVIEW.md) 和 [十月申报资料稿](十月项目申报书.md)。
