///|
fn archive_fields(value : Json, location : String) -> Map[String, Json] raise TemporalError {
  match value {
    Object(fields) => fields
    _ => raise InvalidArchive(location + " must be an object")
  }
}

///|
fn archive_string(
  fields : Map[String, Json],
  name : String,
  location : String,
) -> String raise TemporalError {
  match fields.get(name) {
    Some(String(value)) => value
    _ => raise InvalidArchive(location + "." + name + " must be a string")
  }
}

///|
fn archive_optional_string(
  fields : Map[String, Json],
  name : String,
  location : String,
) -> String? raise TemporalError {
  match fields.get(name) {
    Some(String(value)) => Some(value)
    Some(Null) => None
    _ => raise InvalidArchive(location + "." + name + " must be string or null")
  }
}

///|
fn check_archive_fields(
  fields : Map[String, Json],
  allowed : Array[String],
  location : String,
) -> Unit raise TemporalError {
  for field, _ in fields {
    let mut found = false
    for name in allowed {
      if field == name {
        found = true
      }
    }
    if !found {
      raise InvalidArchive(location + " has unknown field " + field)
    }
  }
}

///|
fn archive_revision(value : Json, index : Int) -> (Int64, Change) raise TemporalError {
  let location = "revisions[" + index.to_string() + "]"
  let fields = archive_fields(value, location)
  check_archive_fields(
    fields,
    ["knownAt", "key", "validFrom", "validTo", "value"],
    location,
  )
  let known_at = parse_instant(archive_string(fields, "knownAt", location))
  let key = archive_string(fields, "key", location)
  let start = parse_instant(archive_string(fields, "validFrom", location))
  let end = match archive_optional_string(fields, "validTo", location) {
    Some(text) => Some(parse_instant(text))
    None => None
  }
  let valid = match end {
    Some(finish) => Span::new(start, finish)
    None => Span::open(start)
  }
  let value = archive_optional_string(fields, "value", location)
  (known_at, { key, valid, value })
}

///|
/// Import a schema-v1 archive by replaying validated atomic batches.
pub fn Ledger::from_json(
  value : Json,
  maximum? : Int = 1000000,
) -> Ledger raise TemporalError {
  let fields = archive_fields(value, "root")
  check_archive_fields(fields, ["schemaVersion", "revisions"], "root")
  match fields.get("schemaVersion") {
    Some(Number(version, ..)) if version == 1.0 => ()
    _ => raise InvalidArchive("unsupported schemaVersion")
  }
  let items = match fields.get("revisions") {
    Some(Array(items)) => items
    _ => raise InvalidArchive("revisions must be an array")
  }
  let mut ledger = Ledger::new(maximum~)
  let mut pending : Array[Change] = []
  let mut pending_time : Int64? = None
  for index, item in items {
    let (known_at, change) = archive_revision(item, index)
    match pending_time {
      Some(at) if at != known_at => {
        ledger = ledger.commit(at, pending)
        pending = []
        pending_time = Some(known_at)
      }
      None => pending_time = Some(known_at)
      _ => ()
    }
    pending.push(change)
  }
  match pending_time {
    Some(at) => ledger.commit(at, pending)
    None => ledger
  }
}

///|
/// Parse a bounded JSON archive before replaying its revisions.
pub fn Ledger::from_json_string(
  text : String,
  maximum? : Int = 1000000,
  max_chars? : Int = 16 * 1024 * 1024,
) -> Ledger raise TemporalError {
  if max_chars <= 0 || text.length() > max_chars {
    raise InvalidArchive("archive exceeds character limit")
  }
  let value = @json.parse(text) catch {
    _ => raise InvalidArchive("invalid JSON syntax")
  }
  Ledger::from_json(value, maximum~)
}
