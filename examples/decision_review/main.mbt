///|
/// Identify invoices needing recomputation; amounts use integer cents, with
/// the business calculation in the caller rather than in the temporal core.
fn main raise {
  let published = try! @temporal.Ledger::new().commit(10L, [
    @temporal.Change::put("price/coffee", @temporal.Span::open(0L), "1000"),
  ])
  let decisions = [
    published.capture_decision("invoice/1", "price/coffee", 35L, 10L),
    published.capture_decision("invoice/2", "price/coffee", 50L, 10L),
    published.capture_decision("invoice/3", "price/coffee", 30L, 10L),
    published.capture_decision("invoice/4", "price/coffee", 45L, 10L),
  ]
  let corrected = published.commit(20L, [
    @temporal.Change::put(
      "price/coffee",
      try! @temporal.Span::new(30L, 45L),
      "950",
    ),
  ])
  let results = corrected.audit_decisions(decisions, 20L)
  let affected = results.filter(fn(result) { result.needs_recompute() })
  assert_eq(affected.length(), 2)
  for result in affected {
    let old = try! @string.parse_int(result.decision().value().unwrap())
    let new = try! @string.parse_int(result.current().unwrap().value().unwrap())
    let quantity = 3
    assert_eq((new - old) * quantity, -150)
    println(result.decision().id() + ": adjustment -150 cents for three units")
  }
  assert_eq(corrected.get("price/coffee", 35L, 10L), Some("1000"))
  println(
    "Two of four invoices require recomputation; original prices remain reproducible",
  )
}
