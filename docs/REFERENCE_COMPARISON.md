# 与 Rust bitemporal-runtime 的功能对比及交付范围

## 参考版本与项目定位

参考 [bitemporal-runtime 0.1.0 文档](https://docs.rs/bitemporal-runtime/0.1.0/bitemporal_runtime/)、[发布源码](https://docs.rs/crate/bitemporal-runtime/0.1.0/source/)及其 [GitHub 仓库](https://github.com/sikmindz/bitemporal-runtime)。参考库许可证为 **MIT OR Apache-2.0**。本项目采用 Apache-2.0，核心实现原创；本次参考公共概念、API 行为和验证结果，没有复制 Rust 实现代码。

定位是可供 MoonBit 应用直接使用的**内存双时间事实库**：原子接收修订、保留旧认知、查询任意两个时间点、导出历史，并定位迟到更正对事实及历史决策的影响。它可接入计费、权限、配置、主数据和遥测处理；持久化和业务规则由应用提供。

## 功能矩阵

| 能力 | Rust bitemporal-runtime 0.1.0 | MoonBitemporal 0.2.0 | 状态及边界 |
| --- | --- | --- | --- |
| 两条时间轴 | `valid_time`、`recorded_time`；`chrono::DateTime<Utc>` | `Span`、`known_at`；调用者提供 `Int64` | 已实现；时间单位、时区转换在调用方 |
| 追加修订 | `append_supersede` 追加记录，旧记录仍保留 | `commit` 返回新账本；`LedgerBuilder` 原地接收、`freeze` 生成隔离检查点 | 已实现；同一批次允许多键，同键区间不可相交 |
| 录入顺序 | 自由函数不检查记录时间是否严格递增 | 不同批次知识时间必须严格递增 | 明确的行为差异；外部消息乱序需先排序/统一定序 |
| 两时间点查询 | `as_of_query` 按 ID 选满足两个起点条件且 recorded_time 最大的记录 | `get`、`observe` 按键选知识时间合格且区间包含查询点的最新修订 | 开放区间、无删除、知识时间唯一时有共同语义，已做真实差分验证 |
| 有效期结束与临时更正 | 记录只有有效起点，没有有效终点 | 半开区间 `[start,end)` 或开放右端；局部更正结束后恢复未被覆盖的旧事实 | 已实现扩展；不是 Rust 记录格式的逐字段移植 |
| 撤回事实 | 没有专用 tombstone API | `Change::delete`；`observe` 区分未曾知道和显式撤回 | 已实现扩展；`get` 将二者折叠为 `None` |
| 快照 | 自由函数 `temporal_snapshot(t)` 调用 `as_of_query(t,t)`；`InMemoryDb::snapshot_at(t)` 只过滤 recorded_time | `snapshot(valid,known)` 显式提供两个时点，结果按键排序 | `snapshot(t,t)` 对应自由函数；不将两个 Rust 入口视为相同 |
| 修订来源凭据 | `append_supersede` 对同 ID 的所有旧记录生成 `SupersessionReceipt` | `supersession_fragments` 按新修订覆盖区间列出立即被替代的旧赢家、空白或撤回 | 已实现新功能；覆盖有效区间，保留同值换源；不枚举所有旧版本 |
| 密码学凭据 | SHA-256；直接 `SupersessionReceipt::new<T>` 序列化 value；`append_supersede` 先擦除为 `()` 再构造凭据 | 导出完整新旧 claim 的结构化 JSON，无哈希/签名 | **不支持密码学完整性**；不宣称字节兼容或等价安全性，应用可外部签名 |
| 历史决策复核 | 公开 API 未提供批量决策证据复核入口 | `capture_decision`、`audit_decisions`；区分事实状态变化与同值来源变化 | 已实现新功能；复核使用过的事实，不自动执行计费/授权规则 |
| 区间及影响分析 | 公开自由函数主要提供点查询/快照 | `timeline`、`knowledge_timeline`、`diff_timeline`、`change_report`、覆盖/联合覆盖 | 已实现；区间输出有预算 |
| 历史传输 | serde 类型；可选 SQLite 存储 | 版本化 JSON 全档/尾档、完整原子批次分页、分歧检查 | 已实现；格式不兼容 Rust serde 格式，传输鉴权由应用负责 |
| 值类型 | 泛型 `BitemporalRecord<T>`；内存存储使用默认 `()` | 不透明 `String` 或 tombstone | 当前不提供泛型载荷；调用方可序列化自己的结构 |
| 持久化 | 可选 `SqliteDb`、`sqlite` feature | 无数据库适配器 | **本期不实现**；调用方保存档案，库本身不提供 durable transaction |
| JSON Schema | 可选 `schema` feature | 已有明确 JSON 格式与严格导入校验，无 Schema 生成器 | **本期不实现生成器** |
| 跨后端 | Rust 原生库 | MoonBit wasm、wasm-gc、js、native | 四后端构建/测试；核心无 Rust/FFI 运行时依赖 |

矩阵依据发布源码 `src/queries.rs`、`src/types.rs`、`src/lib.rs`、`src/sqlite.rs`、`Cargo.toml`，优先采用实际实现行为。特别是快照过滤与凭据载荷处理，不从 README 的概括推导兼容性。

## 对照验证如何复现

`tools/reference/src/main.rs` 是原创适配程序，通过 Cargo 调用 **实际发布的** `bitemporal-runtime = "=0.1.0"`。`Cargo.lock` 锁定依赖；参考库 crate 的 SHA-256 为 `6c22fb27959e206a4e7054975012dfa02199ccc29c4a4392ec8831737b241533`。

输入为 1/3/5 个键、12/30/60 条历史修订；有效起点含负数与迟到更正，知识时间全局严格递增。Rust 输出按键排序以消除 HashMap 遍历顺序差异。总计 **144 个 as-of 查询、21 个自由函数快照查询**；同时实际调用 `append_supersede`，检查其旧版本凭据数和哈希长度。适配程序另验证未来生效记录在两个 Rust 快照入口下的不同结果。

```sh
cargo run --manifest-path tools/reference/Cargo.toml --locked --release > testdata/bitemporal-runtime-0.1.0.json
python tools/generate_reference_tests.py
moon fmt
git diff --exit-code -- testdata/bitemporal-runtime-0.1.0.json reference_vectors_generated_test.mbt
moon test --target all --deny-warn
```

仓库 CI 单独执行 Rust 适配程序并比较固定输出。MoonBit 日常测试使用提交的输出向量，不需要 Rust 或网络。生成测试单独标识，不计入手写有效代码量。

**验证范围限制**：只证明该输入域中的点查询和快照一致。有限区间、删除、原子批次预算、来源分片、决策复核由 MoonBit 独立模型和边界测试验证；不声称全 API、存储、哈希格式或性能与 Rust 一致。

## 本期完成标准

1. 保持旧 API、档案 v1 兼容，通过严格检查、构建和四后端测试。
2. 交付有预算的区间来源凭据；同值更正和撤回仍保留来源关系。
3. 交付批量历史决策复核；拒绝重复决策 ID、倒退复核时间、超量请求和与原始查询事实不一致的证据。
4. 提供至少三个带断言的完整业务场景，见 [场景与验证](SCENARIOS.md)。
5. 发布 `yyyt0807/moonbitemporal@0.2.0`；保留有效提交和公共 CI。

后续可独立扩展泛型载荷、数据库适配器或签名接口；这些不属于本期交付承诺。
