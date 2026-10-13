///|
/// Revoke a rule retrospectively, then reassert the same policy elsewhere.
/// The application reviews changed decisions separately from changed sources.
fn main raise {
  let before = try! @temporal.Ledger::new().commit(1L, [
    @temporal.Change::put("policy/team", @temporal.Span::open(0L), "allow"),
  ])
  let decisions = [
    before.capture_decision("request/1", "policy/team", 5L, 1L),
    before.capture_decision("request/2", "policy/team", 25L, 1L),
  ]
  let after = before.commit(2L, [
    @temporal.Change::delete("policy/team", try! @temporal.Span::new(0L, 10L)),
    @temporal.Change::put("policy/team", @temporal.Span::open(20L), "allow"),
  ])
  let review = after.audit_decisions(decisions, 2L)
  assert_true(review[0].needs_recompute())
  assert_true(review[0].current().unwrap().value() is None)
  assert_false(review[1].needs_recompute())
  assert_true(review[1].provenance_changed())
  println(
    "request/1: rule withdrawn; application must review the earlier access",
  )
  println("request/2: rule unchanged, evidence source updated")
}
