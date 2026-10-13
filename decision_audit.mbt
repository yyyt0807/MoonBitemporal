///|
/// A fact used by a caller's decision at two explicit instants. This captures
/// fact evidence, not the application's full rule or computed business result.
pub struct DecisionEvidence {
  id : String
  key : String
  valid_at : Int64
  known_at : Int64
  source : Revision?
}

///|
pub fn DecisionEvidence::id(self : DecisionEvidence) -> String {
  self.id
}

///|
pub fn DecisionEvidence::key(self : DecisionEvidence) -> String {
  self.key
}

///|
pub fn DecisionEvidence::valid_at(self : DecisionEvidence) -> Int64 {
  self.valid_at
}

///|
pub fn DecisionEvidence::known_at(self : DecisionEvidence) -> Int64 {
  self.known_at
}

///|
pub fn DecisionEvidence::source(self : DecisionEvidence) -> Revision? {
  self.source
}

///|
pub fn DecisionEvidence::value(self : DecisionEvidence) -> String? {
  observed_value(self.source)
}

///|
pub fn Ledger::capture_decision(
  self : Ledger,
  id : String,
  key : String,
  valid_at : Int64,
  known_at : Int64,
) -> DecisionEvidence raise TemporalError {
  if id.is_empty() {
    raise InvalidDecision("decision ID must not be empty")
  }
  if key.is_empty() {
    raise EmptyKey
  }
  {
    id,
    key,
    valid_at,
    known_at,
    source: self.observe(key, valid_at, known_at),
  }
}

///|
/// Review evidence including both versions, even if neither value changed.
pub struct DecisionAudit {
  decision : DecisionEvidence
  review_known : Int64
  current : Revision?
}

///|
pub fn DecisionAudit::decision(self : DecisionAudit) -> DecisionEvidence {
  self.decision
}

///|
pub fn DecisionAudit::review_known(self : DecisionAudit) -> Int64 {
  self.review_known
}

///|
pub fn DecisionAudit::current(self : DecisionAudit) -> Revision? {
  self.current
}

///|
/// A gap and a withdrawal differ, despite both having no effective value.
pub fn DecisionAudit::needs_recompute(self : DecisionAudit) -> Bool {
  match (self.decision.source, self.current) {
    (None, None) => false
    (Some(before), Some(after)) => before.value != after.value
    _ => true
  }
}

///|
/// Identical values with a new winning claim still change provenance.
pub fn DecisionAudit::provenance_changed(self : DecisionAudit) -> Bool {
  !same_source(self.decision.source, self.current)
}

///|
fn same_decision_source(left : Revision?, right : Revision?) -> Bool {
  match (left, right) {
    (None, None) => true
    (Some(a), Some(b)) => a.sequence == b.sequence && same_revision_claim(a, b)
    _ => false
  }
}

///|
/// Preserve request order, require unique decision IDs and reject evidence
/// whose original winning claim disagrees with this ledger. Review cannot
/// precede capture. This checks queried claims, not the entire archive lineage.
pub fn Ledger::audit_decisions(
  self : Ledger,
  decisions : Array[DecisionEvidence],
  review_known : Int64,
  max_decisions~ : Int32 = 4096,
) -> Array[DecisionAudit] raise TemporalError {
  if max_decisions <= 0 || decisions.length() > max_decisions {
    raise TooManyDecisions(maximum=max_decisions)
  }
  let ids : Map[String, Bool] = Map([])
  for decision in decisions {
    if ids.contains(decision.id) {
      raise InvalidDecision("duplicate decision ID: " + decision.id)
    }
    ids[decision.id] = true
    if review_known < decision.known_at {
      raise InvalidDecision("review knowledge time precedes capture")
    }
    let original = self.observe(
      decision.key,
      decision.valid_at,
      decision.known_at,
    )
    if !same_decision_source(original, decision.source) {
      raise InvalidDecision("captured fact disagrees with this ledger")
    }
  }
  decisions.map(fn(decision) {
    {
      decision,
      review_known,
      current: self.observe(decision.key, decision.valid_at, review_known),
    }
  })
}

///|
pub fn DecisionAudit::to_json(self : DecisionAudit) -> Json {
  let fields : Map[String, Json] = Map([])
  fields["schemaVersion"] = Json::number(1.0)
  fields["decisionId"] = Json::string(self.decision.id)
  fields["key"] = Json::string(self.decision.key)
  fields["validAt"] = Json::string(format_instant(self.decision.valid_at))
  fields["capturedKnown"] = Json::string(format_instant(self.decision.known_at))
  fields["reviewKnown"] = Json::string(format_instant(self.review_known))
  fields["capturedSource"] = revision_evidence_json(self.decision.source)
  fields["currentSource"] = revision_evidence_json(self.current)
  fields["needsRecompute"] = Json(self.needs_recompute())
  fields["provenanceChanged"] = Json(self.provenance_changed())
  Json::object(fields)
}
