///|
/// The applicable claim chain for a point query, newest first. The first
/// candidate is the winner; later entries are superseded but still auditable.
pub struct DecisionTrace {
  key : String
  valid_at : Int64
  known_at : Int64
  candidates : Array[Revision]
  truncated : Bool
}

///|
pub fn DecisionTrace::key(self : DecisionTrace) -> String { self.key }

///|
pub fn DecisionTrace::valid_at(self : DecisionTrace) -> Int64 { self.valid_at }

///|
pub fn DecisionTrace::known_at(self : DecisionTrace) -> Int64 { self.known_at }

///|
pub fn DecisionTrace::winner(self : DecisionTrace) -> Revision? {
  self.candidates.get(0)
}

///|
pub fn DecisionTrace::value(self : DecisionTrace) -> String? {
  observed_value(self.winner())
}

///|
pub fn DecisionTrace::candidates(self : DecisionTrace) -> Array[Revision] {
  self.candidates.copy()
}

///|
pub fn DecisionTrace::truncated(self : DecisionTrace) -> Bool {
  self.truncated
}

///|
pub fn DecisionTrace::superseded_count(self : DecisionTrace) -> Int {
  if self.candidates.is_empty() { 0 } else { self.candidates.length() - 1 }
}

///|
/// Explain precedence for one point without exposing unrelated keys or valid
/// intervals. The limit caps returned claims but never discards the winner.
pub fn Ledger::trace(
  self : Ledger,
  key : String,
  valid_at : Int64,
  known_at : Int64,
  max_candidates? : Int = 64,
) -> DecisionTrace raise TemporalError {
  if max_candidates <= 0 {
    raise TooManyRevisions(maximum=max_candidates)
  }
  let candidates : Array[Revision] = []
  let mut truncated = false
  match self.index.get(key) {
    Some(positions) => {
      let eligible = key_upper_bound(self.revisions, positions, known_at, true)
      for i = eligible - 1; i >= 0; i = i - 1 {
        let item = self.revisions[positions[i]]
        if item.valid.contains(valid_at) {
          if candidates.length() >= max_candidates {
            truncated = true
            break
          }
          candidates.push(item)
        }
      }
    }
    None => ()
  }
  { key, valid_at, known_at, candidates, truncated }
}
