# Bitemporal revisions

This library records how an application's belief about time-bounded facts changes over time.

## Language

**Valid time**:
The time during which a fact applies in the modeled world.
_Avoid_: transaction time, entry time

**Knowledge time**:
The time at which the application accepted a claim about a fact. Earlier knowledge remains queryable after a correction.
_Avoid_: effective time, current time

**Revision**:
One accepted claim that assigns or withdraws a value for one key over a valid-time span.
_Avoid_: row, mutable record

**Correction**:
A later revision that changes what is believed about an earlier valid-time span.
_Avoid_: overwrite

**As-of view**:
The set of facts applicable at a valid-time point according to revisions accepted by a chosen knowledge-time point.

**Tombstone**:
A revision that withdraws a value over a valid-time span while preserving the earlier claims.
