///|
/// Compare a deployed rule history with a candidate deployment before
/// accepting an update. The application owns authorization and persistence;
/// the temporal library provides reproducible change evidence.
fn main raise {
  let builder = try! @temporal.LedgerBuilder::new(maximum=100)
  builder.append(
    10L,
    [
      @temporal.Change::put("feature/search", @temporal.Span::open(0L), "off"),
      @temporal.Change::put("feature/export", @temporal.Span::open(0L), "off"),
    ],
  )
  let deployed = builder.freeze()
  assert_eq(deployed.revision_count(), 2)
  println("Deployment baseline contains two feature rules")

  // A proposed rollout changes search for days [20, 40) and enables export
  // later. The candidate remains separate from the deployed snapshot.
  builder.append(
    20L,
    [
      @temporal.Change::put(
        "feature/search",
        try! @temporal.Span::new(20L, 40L),
        "on",
      ),
      @temporal.Change::put(
        "feature/export",
        try! @temporal.Span::new(30L, 50L),
        "on",
      ),
    ],
  )
  let candidate = builder.freeze()
  let horizon = try! @temporal.Span::new(0L, 60L)
  let report = try! @temporal.compare_all_keys(
    deployed,
    candidate,
    horizon,
    10L,
    20L,
  )
  assert_eq(report.keys_examined(), 2)
  assert_eq(report.keys_changed(), 2)
  assert_eq(report.fragment_count(), 2)
  println("Candidate affects two keys and two valid-time fragments")

  let search = try! candidate.sample_matrix(
    "feature/search",
    [10L, 25L, 45L],
    [10L, 20L],
  )
  assert_eq(search.changed_rows(0, 1), 1)
  assert_eq(search.cell(1, 0).unwrap().value(), Some("off"))
  assert_eq(search.cell(1, 1).unwrap().value(), Some("on"))
  println("Sample matrix shows one changed search-rule day")

  // Full archive reconciliation proves the candidate extends the deployed
  // history rather than silently replacing it with a divergent branch.
  assert_true(deployed.is_prefix_of(candidate))
  let accepted = try! deployed.reconcile(candidate)
  assert_eq(accepted.revision_count(), 4)
  assert_eq(accepted.get("feature/export", 35L, 20L), Some("on"))
  println("Candidate reconciles with the deployed history")

  // A sibling branch at the same knowledge time must be reviewed explicitly.
  let sibling = try! deployed.commit(
    20L,
    [
      @temporal.Change::put(
        "feature/search",
        try! @temporal.Span::new(20L, 40L),
        "limited",
      ),
    ],
  )
  assert_eq(candidate.first_divergence(sibling), Some(2))
  println("A conflicting sibling rollout is detected at revision 2")

  let evidence = report.to_json_string()
  assert_true(evidence.contains("\"keysChanged\":2"))
  println("Versioned JSON change evidence is available for review")
}
