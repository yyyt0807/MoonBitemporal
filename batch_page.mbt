///|
/// An incremental page that never splits one atomic knowledge-time commit.
pub struct BatchPage {
  batches : Array[KnowledgeBatch]
  next_known_at : Int64?
  has_more : Bool
}

///|
pub fn BatchPage::batches(self : BatchPage) -> Array[KnowledgeBatch] {
  self.batches.copy()
}

///|
pub fn BatchPage::next_known_at(self : BatchPage) -> Int64? {
  self.next_known_at
}

///|
pub fn BatchPage::has_more(self : BatchPage) -> Bool {
  self.has_more
}

///|
/// Return whole batches strictly after Some(cursor), or from the beginning
/// with None (including the minimum Int64 time). A first batch exceeding
/// max_revisions is an error, rather than a non-progressing empty page.
pub fn Ledger::batches_since(
  self : Ledger,
  known_after : Int64?,
  max_batches? : Int = 128,
  max_revisions? : Int = 4096,
) -> BatchPage raise TemporalError {
  validate_page(0, max_batches)
  if max_revisions <= 0 {
    raise TooManyRevisions(maximum=max_revisions)
  }
  let mut low = 0
  let mut high = self.revisions.length()
  if known_after is Some(after) {
    while low < high {
      let mid = low + (high - low) / 2
      if self.revisions[mid].known_at <= after {
        low = mid + 1
      } else {
        high = mid
      }
    }
  }
  let batches : Array[KnowledgeBatch] = []
  let mut used = 0
  let mut cursor = low
  let mut next_known_at : Int64? = None
  while cursor < self.revisions.length() && batches.length() < max_batches {
    let known_at = self.revisions[cursor].known_at
    let mut end = cursor + 1
    while end < self.revisions.length() &&
          self.revisions[end].known_at == known_at {
      end += 1
    }
    let size = end - cursor
    if size > max_revisions - used {
      if batches.is_empty() {
        raise TooManyRevisions(maximum=max_revisions)
      }
      break
    }
    let revisions : Array[Revision] = []
    for i = cursor; i < end; i = i + 1 {
      revisions.push(self.revisions[i])
    }
    batches.push({ known_at, revisions, })
    used += size
    next_known_at = Some(known_at)
    cursor = end
  }
  { batches, next_known_at, has_more: cursor < self.revisions.length(), }
}
