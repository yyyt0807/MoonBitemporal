///|
/// A correction arrived after the first invoice was issued. Valid time is
/// measured in business days; knowledge time is an ordered intake sequence.
fn main raise {
  let quarter = try! @temporal.Span::new(0L, 90L)
  let opening = try! @temporal.Ledger::new()
  let published = try! opening.commit(
    10L,
    [@temporal.Change::put("sku/coffee", quarter, "USD 10.00")],
  )

  // At knowledge time 10, the invoice for day 35 used the original price.
  let original_invoice = published.get("sku/coffee", 35L, 10L)
  assert_eq(original_invoice, Some("USD 10.00"))
  println("Invoice originally issued for day 35: USD 10.00")

  // A correction on knowledge day 20 applies only to valid days [30, 45).
  let revised = try! published.commit_with_report(
    20L,
    [
      @temporal.Change::put(
        "sku/coffee",
        try! @temporal.Span::new(30L, 45L),
        "USD 9.50",
      ),
    ],
  )
  assert_eq(revised.changed_fragment_count(), 1)
  let ledger = revised.next()
  let corrected_bill = ledger.get("sku/coffee", 35L, 20L)
  assert_eq(corrected_bill, Some("USD 9.50"))
  assert_eq(ledger.get("sku/coffee", 50L, 20L), Some("USD 10.00"))
  println("Corrected bill for day 35: USD 9.50")

  // The system can still reproduce the originally sent invoice.
  let historical_belief = ledger.get("sku/coffee", 35L, 10L)
  assert_eq(historical_belief, original_invoice)
  println("Replayed prior belief for day 35: USD 10.00")

  // Export a tail for a remote billing worker that already has the base.
  let tail = ledger.to_json_since(10L)
  let worker = try! published.append_json(tail)
  assert_eq(worker.get("sku/coffee", 35L, 20L), corrected_bill)
  println("Archive tail replay agrees with the corrected bill")

  // Whole-window comparison identifies exactly the affected invoice days.
  let differences = ledger.diff_timeline("sku/coffee", quarter, 10L, 20L)
  assert_eq(differences.length(), 1)
  assert_eq(differences[0].valid().start(), 30L)
  assert_eq(differences[0].valid().end(), Some(45L))
  println("Changed valid-day range: [30, 45)")
}
