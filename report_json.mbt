///|
fn optional_text_json(value : String?) -> Json {
  match value {
    Some(text) => Json::string(text)
    None => Json::null()
  }
}

///|
fn optional_instant_json(value : Int64?) -> Json {
  match value {
    Some(instant) => Json::string(format_instant(instant))
    None => Json::null()
  }
}

///|
fn span_json(span : Span) -> Json {
  let fields : Map[String, Json] = Map([])
  fields["from"] = Json::string(format_instant(span.start))
  fields["to"] = optional_instant_json(span.end)
  Json::object(fields)
}

///|
pub fn WindowChange::to_json(self : WindowChange) -> Json {
  let fields : Map[String, Json] = Map([])
  fields["valid"] = span_json(self.valid)
  fields["before"] = optional_text_json(self.before)
  fields["after"] = optional_text_json(self.after)
  Json::object(fields)
}

///|
pub fn KeyChangeReport::to_json(self : KeyChangeReport) -> Json {
  let fragments : Array[Json] = []
  for change in self.fragments {
    fragments.push(change.to_json())
  }
  let fields : Map[String, Json] = Map([])
  fields["key"] = Json::string(self.key)
  fields["fragments"] = Json::array(fragments)
  Json::object(fields)
}

///|
/// Versioned JSON evidence for downstream dashboards or review workflows.
/// All 64-bit instants are encoded as decimal strings so JavaScript consumers
/// cannot silently round them. A `null` value denotes absence or withdrawal
/// according to the corresponding before/after side of the change.
pub fn ChangeReport::to_json(self : ChangeReport) -> Json {
  let entries : Array[Json] = []
  for entry in self.entries {
    entries.push(entry.to_json())
  }
  let fields : Map[String, Json] = Map([])
  fields["schemaVersion"] = Json::number(1.0)
  fields["validWindow"] = span_json(self.bounds)
  fields["beforeKnown"] = Json::string(format_instant(self.before_known))
  fields["afterKnown"] = Json::string(format_instant(self.after_known))
  fields["keysExamined"] = self.keys_examined.to_json()
  fields["keysChanged"] = self.entries.length().to_json()
  fields["fragmentCount"] = self.fragments.to_json()
  fields["entries"] = Json::array(entries)
  Json::object(fields)
}

///|
pub fn ChangeReport::to_json_string(self : ChangeReport) -> String {
  self.to_json().stringify()
}

///|
pub fn MatrixCell::to_json(self : MatrixCell) -> Json {
  let fields : Map[String, Json] = Map([])
  fields["validAt"] = Json::string(format_instant(self.valid_at))
  fields["knownAt"] = Json::string(format_instant(self.known_at))
  fields["state"] = Json::string(match self.source {
    None => "unclaimed"
    Some(revision) => if revision.value is None { "withdrawn" } else { "assigned" }
  })
  fields["value"] = optional_text_json(self.value())
  fields["sourceSequence"] = match self.source {
    Some(revision) => revision.sequence.to_json()
    None => Json::null()
  }
  Json::object(fields)
}

///|
/// Export a sampled matrix in the same row-major order as `cell` access.
pub fn TemporalMatrix::to_json(self : TemporalMatrix) -> Json {
  let valid_samples : Array[Json] = []
  for instant in self.valid_samples {
    valid_samples.push(Json::string(format_instant(instant)))
  }
  let knowledge_samples : Array[Json] = []
  for instant in self.knowledge_samples {
    knowledge_samples.push(Json::string(format_instant(instant)))
  }
  let cells : Array[Json] = []
  for cell in self.cells {
    cells.push(cell.to_json())
  }
  let fields : Map[String, Json] = Map([])
  fields["schemaVersion"] = Json::number(1.0)
  fields["key"] = Json::string(self.key)
  fields["validSamples"] = Json::array(valid_samples)
  fields["knowledgeSamples"] = Json::array(knowledge_samples)
  fields["cells"] = Json::array(cells)
  Json::object(fields)
}

///|
pub fn TemporalMatrix::to_json_string(self : TemporalMatrix) -> String {
  self.to_json().stringify()
}
