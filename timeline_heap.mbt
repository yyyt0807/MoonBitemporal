///|
/// A candidate revision clipped to the requested timeline bounds.
priv struct TimelineEvent {
  start : Int64
  end : Int64?
  source : Revision
}

///|
priv struct TimelineHeapItem {
  end : Int64?
  source : Revision
}

///|
fn timeline_higher(a : TimelineHeapItem, b : TimelineHeapItem) -> Bool {
  a.source.sequence > b.source.sequence
}

///|
fn timeline_heap_push(heap : Array[TimelineHeapItem], item : TimelineHeapItem) -> Unit {
  heap.push(item)
  let mut child = heap.length() - 1
  while child > 0 {
    let parent = (child - 1) / 2
    if !timeline_higher(heap[child], heap[parent]) {
      break
    }
    let saved = heap[parent]
    heap[parent] = heap[child]
    heap[child] = saved
    child = parent
  }
}

///|
fn timeline_heap_pop(heap : Array[TimelineHeapItem]) -> Unit {
  if heap.is_empty() {
    return
  }
  let last = heap[heap.length() - 1]
  ignore(heap.pop())
  if heap.is_empty() {
    return
  }
  heap[0] = last
  let mut parent = 0
  while true {
    let left = parent * 2 + 1
    if left >= heap.length() {
      break
    }
    let right = left + 1
    let mut child = left
    if right < heap.length() && timeline_higher(heap[right], heap[left]) {
      child = right
    }
    if !timeline_higher(heap[child], heap[parent]) {
      break
    }
    let saved = heap[parent]
    heap[parent] = heap[child]
    heap[child] = saved
    parent = child
  }
}

///|
fn timeline_expired(item : TimelineHeapItem, instant : Int64) -> Bool {
  match item.end {
    Some(end) => end <= instant
    None => false
  }
}

///|
fn timeline_heap_winner(heap : Array[TimelineHeapItem], instant : Int64) -> Revision? {
  while !heap.is_empty() && timeline_expired(heap[0], instant) {
    timeline_heap_pop(heap)
  }
  if heap.is_empty() { None } else { Some(heap[0].source) }
}
