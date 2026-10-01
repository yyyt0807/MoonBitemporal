///|
/// Replay every batch from another validated ledger after the receiver's last
/// knowledge time. This is useful for a transport adapter carrying archive
/// tails. Failure leaves the original immutable ledger untouched.
pub fn Ledger::append_ledger(
  self : Ledger,
  incoming : Ledger,
) -> Ledger raise TemporalError {
  if incoming.revisions.is_empty() {
    return self
  }
  let first_incoming = incoming.revisions[0].known_at
  match self.latest_time {
    Some(previous) if first_incoming <= previous =>
      raise KnowledgeTimeNotIncreasing(previous~, proposed=first_incoming)
    _ => ()
  }
  if incoming.revisions.length() > self.maximum - self.revisions.length() {
    raise TooManyRevisions(maximum=self.maximum)
  }
  let revisions = self.revisions.copy()
  for item in incoming.revisions {
    revisions.push({
      key: item.key,
      valid: item.valid,
      known_at: item.known_at,
      value: item.value,
      sequence: revisions.length(),
    })
  }
  {
    revisions,
    index: build_index(revisions),
    latest_time: incoming.latest_time,
    maximum: self.maximum,
  }
}

///|
/// Parse a validated archive tail and append it to the receiver.
pub fn Ledger::append_json(
  self : Ledger,
  value : Json,
) -> Ledger raise TemporalError {
  let incoming = Ledger::from_json(value, maximum=self.maximum)
  self.append_ledger(incoming)
}

///|
pub fn Ledger::append_json_string(
  self : Ledger,
  text : String,
  max_chars? : Int = 16 * 1024 * 1024,
) -> Ledger raise TemporalError {
  let incoming = Ledger::from_json_string(
    text,
    maximum=self.maximum,
    max_chars~,
  )
  self.append_ledger(incoming)
}
