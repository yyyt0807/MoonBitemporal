///|
/// Replay every batch from another validated ledger after the receiver's last
/// knowledge time. This is useful for a transport adapter carrying archive
/// tails. Failure leaves the original immutable ledger untouched.
pub fn Ledger::append_ledger(
  self : Ledger,
  incoming : Ledger,
) -> Ledger raise TemporalError {
  let mut result = self
  let mut pending : Array[Change] = []
  let mut pending_time : Int64? = None
  for revision in incoming.revisions {
    match pending_time {
      Some(at) if at != revision.known_at => {
        result = result.commit(at, pending)
        pending = []
        pending_time = Some(revision.known_at)
      }
      None => pending_time = Some(revision.known_at)
      _ => ()
    }
    pending.push({
      key: revision.key,
      valid: revision.valid,
      value: revision.value,
    })
  }
  match pending_time {
    Some(at) => result.commit(at, pending)
    None => result
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
