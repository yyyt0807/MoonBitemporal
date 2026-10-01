///|
fn revision_to_json(revision : Revision) -> Json {
  let fields : Map[String, Json] = Map([])
  fields["knownAt"] = Json::string(format_instant(revision.known_at))
  fields["key"] = Json::string(revision.key)
  fields["validFrom"] = Json::string(format_instant(revision.valid.start))
  fields["validTo"] = match revision.valid.end {
    Some(end) => Json::string(format_instant(end))
    None => Json::null()
  }
  fields["value"] = match revision.value {
    Some(value) => Json::string(value)
    None => Json::null()
  }
  Json::object(fields)
}

///|
/// Export versioned data using decimal strings for all Int64 instants.
pub fn Ledger::to_json(self : Ledger) -> Json {
  let revisions : Array[Json] = []
  for revision in self.revisions {
    revisions.push(revision_to_json(revision))
  }
  let fields : Map[String, Json] = Map([])
  fields["schemaVersion"] = Json::number(1.0)
  fields["revisions"] = Json::array(revisions)
  Json::object(fields)
}

///|
pub fn Ledger::to_json_string(self : Ledger) -> String {
  self.to_json().stringify()
}
