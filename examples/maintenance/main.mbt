///|
fn main raise {
  let window = try! @temporal.Span::new(0L, 100L)
  let ledger = try! @temporal.Ledger::new()
    .commit(10L, [
      @temporal.Change::put("service", window, "on"),
      @temporal.Change::put("license", window, "on"),
    ])
    .commit(20L, [
      @temporal.Change::delete("license", try! @temporal.Span::new(40L, 60L)),
    ])
  let page = try! ledger.batches_since(None, max_revisions=2)
  assert_eq(page.batches()[0].size(), 2)
  assert_true(page.has_more())
  let tail = try! ledger.batches_since(page.next_known_at())
  assert_false(tail.has_more())
  let joint = try! ledger.joint_assigned_spans(
    ["service", "license"],
    window,
    20L,
  )
  assert_eq(joint.length(), 2)
  assert_eq(joint[0].end(), Some(40L))
  assert_eq(joint[1].start(), 60L)
  println("Whole-batch replication pages and joint temporal coverage: ok")
}
