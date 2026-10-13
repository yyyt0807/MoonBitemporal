"""Generate MoonBit assertions from actual pinned Rust outputs; no copied corpus."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
data = json.loads((ROOT / "testdata/bitemporal-runtime-0.1.0.json").read_text(encoding="utf-8"))
assert data["reference"] == "bitemporal-runtime" and data["version"] == "0.1.0"


def text(value):
    return json.dumps(value, ensure_ascii=False)


lines = ["// Generated from actual Rust bitemporal-runtime 0.1.0 outputs.",
         "// Regenerate with tools/generate_reference_tests.py; excluded from handwritten LOC."]
for index, case in enumerate(data["cases"]):
    lines += ["", "///|", f'test "Rust reference shared open-span semantics case {index}" {{',
              "  let builder = try! LedgerBuilder::new()"]
    for record in case["records"]:
        lines += [f'  builder.append({record["known"]}L, [Change::put({text(record["key"])}, Span::open({record["valid"]}L), {text(record["value"])})])']
    lines += ["  let ledger = builder.freeze()"]
    keys = sorted({r["key"] for r in case["records"]})
    for query in case["queries"]:
        values = {fact["key"]: fact["value"] for fact in query["facts"]}
        lines += [f'  assert_eq(ledger.snapshot({query["valid"]}L, {query["known"]}L).length(), {len(values)})']
        for key in keys:
            expected = f"Some({text(values[key])})" if key in values else "None"
            lines += [f'  assert_eq(ledger.get({text(key)}, {query["valid"]}L, {query["known"]}L), {expected})']
    for snapshot in case["snapshots"]:
        values = {f["key"]: f["value"] for f in snapshot["facts"]}
        known = snapshot["known"]
        lines += [f'  assert_eq(ledger.snapshot({known}L, {known}L).length(), {len(values)})']
        for key in keys:
            expected = f"Some({text(values[key])})" if key in values else "None"
            lines += [f'  assert_eq(ledger.get({text(key)}, {known}L, {known}L), {expected})']
    lines += ["}"]
(ROOT / "reference_vectors_generated_test.mbt").write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"Generated {len(data['cases'])} cases from pinned Rust outputs")
