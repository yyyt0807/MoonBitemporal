///|
/// One interval of knowledge time during which the selected valid-time value
/// came from the same revision. `source=None` means no claim had yet arrived.
pub struct KnowledgeSegment {
  known : Span
  source : Revision?
}

///|
pub fn KnowledgeSegment::known(self : KnowledgeSegment) -> Span {
  self.known
}

///|
pub fn KnowledgeSegment::source(self : KnowledgeSegment) -> Revision? {
  self.source
}

///|
pub fn KnowledgeSegment::value(self : KnowledgeSegment) -> String? {
  observed_value(self.source)
}

///|
pub fn KnowledgeSegment::is_unclaimed(self : KnowledgeSegment) -> Bool {
  self.source is None
}

///|
pub fn KnowledgeSegment::is_withdrawn(self : KnowledgeSegment) -> Bool {
  match self.source {
    Some(revision) => revision.value is None
    None => false
  }
}

///|
/// Show how the application's belief about one valid instant evolved over a
/// knowledge-time window. This is the dual of `Ledger::timeline`.
pub fn Ledger::knowledge_timeline(
  self : Ledger,
  key : String,
  valid_at : Int64,
  bounds : Span,
  max_segments? : Int = 4096,
) -> Array[KnowledgeSegment] raise TemporalError {
  if max_segments <= 0 {
    raise TooManySegments(maximum=max_segments)
  }
  let applicable : Array[Revision] = []
  for revision in self.history(key) {
    if revision.valid.contains(valid_at) {
      applicable.push(revision)
    }
  }
  let points : Array[Int64] = [bounds.start]
  for revision in applicable {
    if revision.known_at > bounds.start && bounds.contains(revision.known_at) {
      points.push(revision.known_at)
    }
  }
  match bounds.end {
    Some(end) => points.push(end)
    None => ()
  }
  let output : Array[KnowledgeSegment] = []
  let mut next_revision = 0
  let mut winner : Revision? = None
  for i = 0; i < points.length(); i = i + 1 {
    let start = points[i]
    while next_revision < applicable.length() &&
          applicable[next_revision].known_at <= start {
      winner = Some(applicable[next_revision])
      next_revision = next_revision + 1
    }
    let end = if i + 1 < points.length() {
      Some(points[i + 1])
    } else {
      bounds.end
    }
    if end == Some(start) || (i + 1 == points.length() && bounds.end is Some(_)) {
      continue
    }
    if output.length() >= max_segments {
      raise TooManySegments(maximum=max_segments)
    }
    output.push({ known: { start, end, }, source: winner, })
  }
  output
}
