//! Original behavioral adapter. Uses the published reference crate, not a
//! reimplementation. Shared domain: open valid spans, no tombstones, unique
//! increasing recorded instants. Comparisons normalize unspecified query order.
use bitemporal_runtime::{append_supersede, as_of_query, temporal_snapshot, BitemporalRecord, InMemoryDb};
use chrono::{TimeZone, Utc};
use serde_json::{json, Value};

fn time(value: i64) -> chrono::DateTime<Utc> {
    Utc.timestamp_opt(value, 0).single().unwrap()
}

fn normalize(records: Vec<BitemporalRecord<String>>) -> Value {
    let mut sorted = records;
    sorted.sort_by(|a, b| a.id.cmp(&b.id));
    json!(sorted.into_iter().map(|r| json!({"key": r.id, "value": r.value})).collect::<Vec<_>>())
}

fn main() {
    let mut cases = Vec::new();
    for (keys, count) in [(1, 12), (3, 30), (5, 60)] {
        let mut records = Vec::new();
        let mut input = Vec::new();
        let mut receipt_count = 0;
        for i in 0..count {
            let key = format!("key-{}", i % keys);
            let valid = (i * 17 % 41) as i64 - 10;
            let known = i as i64 * 3 + 1;
            let value = format!("value-{}", i % 7);
            let receipts = append_supersede(&mut records, BitemporalRecord {
                id: key.clone(), valid_time: time(valid), recorded_time: time(known), value: value.clone(),
            }).unwrap();
            assert_eq!(receipts.len(), (i / keys) as usize);
            for receipt in &receipts {
                assert_eq!(receipt.receipt_digest.len(), 64);
                assert_eq!(receipt.superseding_id, key);
            }
            receipt_count += receipts.len();
            input.push(json!({"key": key, "valid": valid, "known": known, "value": value}));
        }
        let mut queries = Vec::new();
        for valid in [-11, -10, 0, 10, 20, 30, 31, 60] {
            for known in [-1, 1, 7, 25, 80, 200] {
                queries.push(json!({"valid": valid, "known": known,
                    "facts": normalize(as_of_query(&records, time(valid), time(known)))}));
            }
        }
        let snapshots: Vec<_> = [-1, 0, 1, 7, 25, 80, 200].into_iter()
            .map(|known| json!({"known": known, "facts": normalize(temporal_snapshot(&records, time(known)))})).collect();
        cases.push(json!({"records": input, "queries": queries, "snapshots": snapshots, "referenceReceiptCount": receipt_count}));
    }
    // Upstream free-function snapshot and InMemoryDb snapshot_at have different
    // valid-time filtering. Explicitly record that distinction rather than
    // assuming all similarly named snapshot APIs are interchangeable.
    let future = BitemporalRecord { id: "future".to_string(), valid_time: time(100), recorded_time: time(1), value: "scheduled".to_string() };
    assert!(temporal_snapshot(&[future], time(10)).is_empty());
    let mut db = InMemoryDb::new();
    db.insert(BitemporalRecord { id: "future".into(), valid_time: time(100), recorded_time: time(1), value: () });
    assert_eq!(db.snapshot_at(time(10)).len(), 1);
    println!("{}", serde_json::to_string_pretty(&json!({"reference": "bitemporal-runtime", "version": "0.1.0", "cases": cases,
        "snapshotBoundary": {"freeFunctionCount": 0, "inMemoryCount": 1}})).unwrap());
}
