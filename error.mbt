///|
/// Errors returned before an invalid revision can enter a ledger.
pub(all) suberror TemporalError {
  InvalidSpan(String)
  EmptyKey
  EmptyBatch
  KnowledgeTimeNotIncreasing(previous~ : Int64, proposed~ : Int64)
  OverlappingBatchChanges(key~ : String, first~ : Int, second~ : Int)
  TooManyRevisions(maximum~ : Int)
  TooManySegments(maximum~ : Int)
  InvalidInstant(String)
}

///|
pub fn TemporalError::code(self : TemporalError) -> String {
  match self {
    InvalidSpan(_) => "TEMPORAL_INVALID_SPAN"
    EmptyKey => "TEMPORAL_EMPTY_KEY"
    EmptyBatch => "TEMPORAL_EMPTY_BATCH"
    KnowledgeTimeNotIncreasing(..) => "TEMPORAL_KNOWLEDGE_ORDER"
    OverlappingBatchChanges(..) => "TEMPORAL_BATCH_OVERLAP"
    TooManyRevisions(..) => "TEMPORAL_REVISION_LIMIT"
    TooManySegments(..) => "TEMPORAL_SEGMENT_LIMIT"
    InvalidInstant(_) => "TEMPORAL_INVALID_INSTANT"
  }
}
