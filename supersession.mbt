///|
/// One interval covered by a new revision, retaining the immediately prior
/// winning claim even when its value is identical. Not a cryptographic receipt.
pub struct SupersessionFragment {
  valid : Span
  previous : Revision?
  replacement : Revision
}

///|
pub fn SupersessionFragment::valid(self : SupersessionFragment) -> Span {
  self.valid
}

///|
pub fn SupersessionFragment::previous(self : SupersessionFragment) -> Revision? {
  self.previous
}

///|
pub fn SupersessionFragment::replacement(
  self : SupersessionFragment,
) -> Revision {
  self.replacement
}

///|
pub fn SupersessionFragment::value_changed(self : SupersessionFragment) -> Bool {
  observed_value(self.previous) != self.replacement.value
}

///|
/// Partition a revision's whole valid span by the prior winners. Gaps,
/// withdrawals and same-value reassertions are included. Later revisions do
/// not alter this historical receipt. Sequence IDs are local to this archive.
pub fn Ledger::supersession_fragments(
  self : Ledger,
  index : Int32,
  max_fragments~ : Int32 = 4096,
) -> Array[SupersessionFragment] raise TemporalError {
  let target = match self.revision(index) {
    Some(revision) => revision
    None => raise InvalidRevisionIndex(index)
  }
  let prior = self.timeline_at(
    target.key,
    target.valid,
    target.known_at,
    false,
    max_fragments,
  )
  prior.map(fn(segment) {
    { valid: segment.valid, previous: segment.source, replacement: target, }
  })
}

///|
fn revision_evidence_json(revision : Revision?) -> Json {
  match revision {
    None => Json::null()
    Some(source) => {
      let fields : Map[String, Json] = Map([])
      fields["sequence"] = Json(source.sequence)
      fields["key"] = Json::string(source.key)
      fields["valid"] = span_json(source.valid)
      fields["knownAt"] = Json::string(format_instant(source.known_at))
      fields["value"] = optional_text_json(source.value)
      Json::object(fields)
    }
  }
}

///|
/// Complete claim content accompanies the local sequence references; callers
/// may authenticate this deterministic JSON externally. No digest is supplied.
pub fn SupersessionFragment::to_json(self : SupersessionFragment) -> Json {
  let fields : Map[String, Json] = Map([])
  fields["schemaVersion"] = Json::number(1.0)
  fields["valid"] = span_json(self.valid)
  fields["previous"] = revision_evidence_json(self.previous)
  fields["replacement"] = revision_evidence_json(Some(self.replacement))
  fields["valueChanged"] = Json(self.value_changed())
  Json::object(fields)
}
