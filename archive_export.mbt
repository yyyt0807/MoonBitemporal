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
  archive_json(self.revisions)
}

///|
fn archive_json(source : Array[Revision]) -> Json {
  let revisions : Array[Json] = []
  for revision in source {
    revisions.push(revision_to_json(revision))
  }
  let fields : Map[String, Json] = Map([])
  fields["schemaVersion"] = Json::number(1.0)
  fields["revisions"] = Json::array(revisions)
  Json::object(fields)
}

///|
/// Export only revisions accepted strictly after `cutoff`. The receiver must
/// already contain all earlier revisions or understand it is receiving a tail.
pub fn Ledger::to_json_since(self : Ledger, cutoff : Int64) -> Json {
  let tail : Array[Revision] = []
  for revision in self.revisions {
    if revision.known_at > cutoff {
      tail.push(revision)
    }
  }
  archive_json(tail)
}

///|
pub fn Ledger::to_json_string(self : Ledger) -> String {
  self.to_json().stringify()
}
