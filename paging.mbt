///|
/// One bounded page of immutable revisions. `next_offset` is the offset to
/// request next, or `None` when this page reaches the end of the sequence.
pub struct RevisionPage {
  items : Array[Revision]
  offset : Int
  total : Int
  next_offset : Int?
}

///|
pub fn RevisionPage::items(self : RevisionPage) -> Array[Revision] {
  self.items.copy()
}

///|
pub fn RevisionPage::offset(self : RevisionPage) -> Int {
  self.offset
}

///|
pub fn RevisionPage::total(self : RevisionPage) -> Int {
  self.total
}

///|
pub fn RevisionPage::next_offset(self : RevisionPage) -> Int? {
  self.next_offset
}

///|
pub fn RevisionPage::is_empty(self : RevisionPage) -> Bool {
  self.items.is_empty()
}

///|
fn validate_page(offset : Int, max_items : Int) -> Unit raise TemporalError {
  if offset < 0 {
    raise InvalidPage("offset must be non-negative")
  }
  if max_items <= 0 || max_items > 10000 {
    raise InvalidPage("max_items must be in 1..10000")
  }
}

///|
fn page_end(offset : Int, max_items : Int, total : Int) -> Int {
  if offset >= total {
    total
  } else if max_items >= total - offset {
    total
  } else {
    offset + max_items
  }
}

///|
/// Page through the full append log without copying unrelated revisions.
pub fn Ledger::page(
  self : Ledger,
  offset : Int,
  max_items : Int,
) -> RevisionPage raise TemporalError {
  validate_page(offset, max_items)
  let total = self.revisions.length()
  let end = page_end(offset, max_items, total)
  let items : Array[Revision] = []
  if offset < total {
    for i = offset; i < end; i = i + 1 {
      items.push(self.revisions[i])
    }
  }
  let next_offset = if end < total { Some(end) } else { None }
  { items, offset, total, next_offset, }
}

///|
/// Page through revisions for one key. Offsets are positions in that key's
/// history, while each returned revision retains its global sequence number.
pub fn Ledger::history_page(
  self : Ledger,
  key : String,
  offset : Int,
  max_items : Int,
) -> RevisionPage raise TemporalError {
  validate_page(offset, max_items)
  let positions = match self.index.get(key) {
    Some(positions) => positions
    None => []
  }
  let total = positions.length()
  let end = page_end(offset, max_items, total)
  let items : Array[Revision] = []
  if offset < total {
    for i = offset; i < end; i = i + 1 {
      items.push(self.revisions[positions[i]])
    }
  }
  let next_offset = if end < total { Some(end) } else { None }
  { items, offset, total, next_offset, }
}
