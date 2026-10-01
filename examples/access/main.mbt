///|
/// Reconstruct the decision basis that an access gateway had at incident time
/// and compare it with a later backdated revocation.
fn main raise {
  let assignment = try! @temporal.Span::new(100L, 200L)
  let base = try! @temporal.Ledger::new()
  let issued = try! base.commit(1000L, [
    @temporal.Change::put("employee/42/role", assignment, "operator"),
    @temporal.Change::put("employee/42/site", assignment, "warehouse-a"),
  ])
  let incident_day = 150L
  let incident_known = 1000L
  let originally_visible = issued.snapshot(incident_day, incident_known)
  assert_eq(originally_visible.length(), 2)
  assert_eq(
    issued.get("employee/42/role", incident_day, incident_known),
    Some("operator"),
  )
  println("At incident time: operator role and warehouse-a site were visible")

  // Human review accepts a revocation later, effective before the incident.
  let reviewed = try! issued.commit_with_report(1100L, [
    @temporal.Change::delete(
      "employee/42/role",
      try! @temporal.Span::new(140L, 160L),
    ),
  ])
  assert_eq(reviewed.changed_fragment_count(), 1)
  let ledger = reviewed.next()
  assert_eq(
    ledger.get("employee/42/role", incident_day, incident_known),
    Some("operator"),
  )
  assert_eq(ledger.get("employee/42/role", incident_day, 1100L), None)
  assert_eq(
    ledger.get("employee/42/site", incident_day, 1100L),
    Some("warehouse-a"),
  )
  println("Current reconstruction: role withdrawn for incident day")

  let changes = ledger.diff_knowledge(incident_day, incident_known, 1100L)
  assert_eq(changes.length(), 1)
  assert_eq(changes[0].key(), "employee/42/role")
  assert_eq(changes[0].before(), Some("operator"))
  assert_eq(changes[0].after(), None)
  println("Knowledge diff identifies only the role claim")

  let trace = try! ledger.trace("employee/42/role", incident_day, 1100L)
  assert_eq(trace.superseded_count(), 1)
  assert_eq(trace.winner().unwrap().known_at(), 1100L)
  assert_eq(trace.candidates()[1].known_at(), 1000L)
  println("Decision trace retains both the withdrawal and superseded grant")

  // The valid-time window shows exactly which incident days changed.
  let revised_days = ledger.diff_timeline(
    "employee/42/role", assignment, incident_known, 1100L,
  )
  assert_eq(revised_days.length(), 1)
  assert_eq(revised_days[0].valid().start(), 140L)
  assert_eq(revised_days[0].valid().end(), Some(160L))
  println("Affected assignment days: [140, 160)")
}
