---
document: query-performance-antipatterns
purpose: Help an LLM identify Query API performance risks and better patterns
scope: Guidewire Query API and database-vs-memory behavior
---

# Query Performance and Anti-patterns

## Core rule

Let the database filter, sort, and count where possible. Avoid loading broad result sets and then filtering in memory.

## Anti-pattern: filtering after select

```gosu
// Risky for large result sets
var rows = Query.make(Claim).select().where(\ c -> c.State == ClaimState.TC_OPEN)
```

Prefer:

```gosu
var query = Query.make(Claim)
query.compare(Claim#State, Equals, ClaimState.TC_OPEN)
var rows = query.select()
```

## Anti-pattern: looping to filter

```gosu
for (claim in Query.make(Claim).select()) {
  if (claim.Policy == targetPolicy) {
  }
}
```

Prefer:

```gosu
var query = Query.make(Claim)
query.compare(Claim#Policy, Equals, targetPolicy)
```

## Anti-pattern: `intersect` when one query can hold all predicates

Avoid building two entity queries and intersecting if equivalent conditions can be placed on one query.

Prefer:

```gosu
var query = Query.make(Claim)
query.compare(Claim#LossCause, Equals, LossCause.TC_VEHCOLLISION)
query.compare(Claim#State, Equals, ClaimState.TC_OPEN)
```

## Pattern: union for OR/subselect cases

If an OR with a subselect performs poorly or is difficult to reason about, separate branches and combine with `union()` when appropriate. Verify both branches return the same primary entity.

## `contains()` caution

`contains()` can be expensive. Prefer adding an initial indexed predicate before `contains()`.

```gosu
var query = Query.make(Claim)
query.compare(Claim#State, Equals, ClaimState.TC_OPEN)
query.compare(Claim#AssignedUser, Equals, aUser)
query.contains(Claim#Description, "high-risk", false)
```

## Ends-with search pattern

Ends-with searches can be inefficient. A denormalized reversed column plus starts-with search may be used in some designs. If the agent sees this pattern, verify synchronization logic keeps the denormalized column current.

## Case-insensitive search

Use `compareIgnoreCase` when appropriate. Verify whether the relevant search column supports linguistic/case-insensitive search and whether encryption prevents that configuration.

## Existence checks

If the actual entities or exact count are not needed, avoid loading results.

Prefer:

```gosu
var exists = not query.select().Empty
```

Avoid:

```gosu
query.select().Count > 0
query.select().toList().Count > 0
collection.hasMatch(\ x -> ...)
collection.countWhere(\ x -> ...) > 0
```

## Count threshold checks

If the business logic only needs to know whether count exceeds a threshold, use limited count.

```gosu
var tooMany = query.select().getCountLimitedBy(11) > 10
```

## First result

Avoid counting before retrieving first result.

```gosu
var first = query.select().FirstResult
```

## Avoid collection counting over DB-backed arrays

If a collection represents database-backed data, `countWhere` or iteration may load many entities. Prefer a targeted query.

## Dot notation and array expansion

Multi-step dot paths and spread/array expansion can load additional entities. Consider query-backed retrieval or `ArrayLoader` where applicable.

Agent warning:

- If dot notation traverses arrays or FKs in a ListView or loop, check performance implications.
- If reference is child-to-parent, ArrayLoader may not apply; verify actual direction.

## New/changed entity checks

Do not query broadly just to detect new/changed entities. Prefer entity change methods when available:

- `getChangedFields`
- `getAddedArrayElements`
- `getChangedArrayElements`
- `getRemovedArrayElements`
- `isFieldChanged`
- `isArrayElementAddedOrRemoved`
- `isArrayElementChanged`
- specialized entity methods where available

## Agent output rule

When reporting a query issue, classify it as:

```text
Issue type: database-vs-memory filtering / counting / existence / dot-path expansion / broad query / read-only result modification
Observed code:
Suggested safer pattern:
Verification needed:
```
