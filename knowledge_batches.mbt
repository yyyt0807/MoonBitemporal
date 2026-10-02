///|
/// One atomic commit group from the append log. Its revisions retain their
/// global sequence numbers and original valid spans.
pub struct KnowledgeBatch {
  known_at : Int64
  revisions : Array[Revision]
}

///|
pub fn KnowledgeBatch::known_at(self : KnowledgeBatch) -> Int64 {
  self.known_at
}

///|
pub fn KnowledgeBatch::revisions(self : KnowledgeBatch) -> Array[Revision] {
  self.revisions.copy()
}

///|
pub fn KnowledgeBatch::size(self : KnowledgeBatch) -> Int {
  self.revisions.length()
}

///|
/// Locate an exact knowledge-time commit by binary search. This lets event
/// adapters replay or inspect a batch without scanning every historical key.
pub fn Ledger::batch_at(self : Ledger, known_at : Int64) -> KnowledgeBatch? {
  let mut low = 0
  let mut high = self.revisions.length()
  while low < high {
    let middle = low + (high - low) / 2
    if self.revisions[middle].known_at < known_at {
      low = middle + 1
    } else {
      high = middle
    }
  }
  if low == self.revisions.length() || self.revisions[low].known_at != known_at {
    return None
  }
  let revisions : Array[Revision] = []
  let mut cursor = low
  while cursor < self.revisions.length() &&
        self.revisions[cursor].known_at == known_at {
    revisions.push(self.revisions[cursor])
    cursor = cursor + 1
  }
  Some({ known_at, revisions, })
}
