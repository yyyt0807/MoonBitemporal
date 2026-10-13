///|
test "first receipt includes unclaimed span even for withdrawal" {
  let ledger = (try! Ledger::new()).commit(0L, [
    Change::delete("key", Span::open(0L)),
  ])
  let receipt = ledger.supersession_fragments(0)
  assert_eq(receipt.length(), 1)
  assert_true(receipt[0].previous() is None)
  assert_eq(receipt[0].valid().end(), None)
  assert_false(receipt[0].value_changed())
  assert_eq(receipt[0].replacement().sequence(), 0)
}

///|
test "receipt retains same value sources and bounded partial overlap" {
  let a = (try! Ledger::new()).commit(1L, [
    Change::put("key", Span::open(0L), "A"),
  ])
  let b = a.commit(2L, [Change::put("key", try! Span::new(10L, 20L), "A")])
  let c = b.commit(3L, [Change::put("key", try! Span::new(5L, 25L), "A")])
  let receipt = c.supersession_fragments(2)
  assert_eq(receipt.length(), 3)
  for i, fragment in receipt {
    assert_false(fragment.value_changed())
    assert_eq(
      fragment.previous().map(fn(r) { r.sequence() }),
      Some(if i == 1 { 1 } else { 0 }),
    )
    assert_eq(fragment.replacement().sequence(), 2)
  }
  assert_eq(receipt[0].valid().start(), 5L)
  assert_eq(receipt[0].valid().end(), Some(10L))
  assert_eq(receipt[1].valid().end(), Some(20L))
  assert_eq(receipt[2].valid().end(), Some(25L))
}

///|
test "receipt partitions gaps assignments and tombstones without unrelated keys" {
  let a = (try! Ledger::new()).commit(1L, [
    Change::put("key", try! Span::new(0L, 10L), "A"),
    Change::delete("key", try! Span::new(10L, 20L)),
    Change::put("other", Span::open(0L), "X"),
  ])
  let b = a.commit(2L, [Change::put("key", try! Span::new(0L, 30L), "B")])
  let receipt = b.supersession_fragments(3)
  assert_eq(receipt.length(), 3)
  assert_eq(receipt[0].previous().map(fn(r) { r.value() }), Some(Some("A")))
  assert_eq(receipt[1].previous().map(fn(r) { r.value() }), Some(None))
  assert_true(receipt[2].previous() is None)
  for fragment in receipt {
    assert_true(fragment.value_changed())
  }
}

///|
test "historical receipts exclude later claims and simultaneous disjoint changes" {
  let a = (try! Ledger::new()).commit(1L, [
    Change::put("key", Span::open(0L), "A"),
  ])
  let b = a.commit(2L, [
    Change::put("key", try! Span::new(0L, 10L), "B"),
    Change::put("key", Span::open(10L), "C"),
  ])
  let c = b.commit(3L, [Change::delete("key", Span::open(0L))])
  for index in [1, 2] {
    let receipt = c.supersession_fragments(index)
    assert_eq(receipt.length(), 1)
    assert_eq(receipt[0].previous().map(fn(r) { r.sequence() }), Some(0))
  }
}

///|
test "receipt strict cutoff handles minimum knowledge time and maximum valid point" {
  let ledger = (try! Ledger::new()).commit(-9223372036854775808L, [
    Change::put("key", Span::open(9223372036854775807L), "A"),
  ])
  let receipt = ledger.supersession_fragments(0)
  assert_eq(receipt.length(), 1)
  assert_true(receipt[0].previous() is None)
  assert_true(receipt[0].valid().contains(9223372036854775807L))
}

///|
test "receipt index and budget errors are typed" {
  let ledger = (try! Ledger::new()).commit(1L, [
    Change::put("k", Span::open(0L), "A"),
  ])
  for index in [-1, 1] {
    let code = try {
      ledger.supersession_fragments(index) |> ignore
      "unexpected"
    } catch {
      error => error.code()
    }
    assert_eq(code, "TEMPORAL_REVISION_INDEX")
  }
  let code = try {
    ledger.supersession_fragments(0, max_fragments=0) |> ignore
    "unexpected"
  } catch {
    error => error.code()
  }
  assert_eq(code, "TEMPORAL_SEGMENT_LIMIT")
}

///|
test "receipt fragment ceiling rejects incomplete evidence" {
  let a = (try! Ledger::new()).commit(1L, [
    Change::put("k", try! Span::new(10L, 20L), "A"),
  ])
  let b = a.commit(2L, [Change::put("k", try! Span::new(0L, 30L), "B")])
  let code = try {
    b.supersession_fragments(1, max_fragments=2) |> ignore
    "unexpected"
  } catch {
    error => error.code()
  }
  assert_eq(code, "TEMPORAL_SEGMENT_LIMIT")
  assert_eq(b.supersession_fragments(1, max_fragments=3).length(), 3)
}

///|
test "generated receipts agree with independent strict forward scan" {
  let ledger = generated_ledger()
  for index = 0; index < ledger.revision_count(); index = index + 1 {
    let target = ledger.revisions[index]
    let receipt = ledger.supersession_fragments(index)
    for point = target.valid.start
        point < target.valid.end.unwrap()
        point = point + 1L {
      let mut expected : Revision? = None
      for old in ledger.revisions {
        if old.known_at < target.known_at &&
          old.key == target.key &&
          old.valid.contains(point) {
          expected = Some(old)
        }
      }
      let matches = receipt.filter(fn(fragment) {
        fragment.valid().contains(point)
      })
      assert_eq(matches.length(), 1)
      assert_true(same_decision_source(matches[0].previous(), expected))
    }
  }
}

///|
test "receipt deterministic JSON preserves complete content and 64 bit instants" {
  let ledger = (try! Ledger::new()).commit(9007199254740993L, [
    Change::put("é\"", Span::open(-9223372036854775808L), "new\nvalue"),
  ])
  let receipt = ledger.supersession_fragments(0)
  let text = receipt[0].to_json().stringify()
  assert_true(text.contains("9007199254740993"))
  assert_true(text.contains("-9223372036854775808"))
  assert_eq(receipt[0].to_json(), try! @json.parse(text))
}
