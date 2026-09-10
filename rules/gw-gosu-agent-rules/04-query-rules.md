# Query Rules

These rules enforce correct and performant use of the Guidewire Query API. Violating them causes excessive database load, connection pool exhaustion, or incorrect results. Full background: `/context/gosu/queries/06-query-pattern-cards.md`, `/context/gosu/queries/07-query-performance-antipatterns.md`, `/context/gosu/queries/30-db-connection-pool.md`.

## Rule: Never Filter After `select()` — Push Predicates Into the Query

Filtering a query's result set in Gosu (using `where`, `hasMatch`, or a loop) after calling `select()` fetches **every matching row** and filters in memory. This multiplies database load with row count and bypasses the database's ability to use indexes.

```gosu
// WRONG — fetches all policies, filters in memory
var openPolicies = Query.make(Policy).select().where(\ p -> p.Status == PolicyStatus.TC_OPEN)

// CORRECT — filters at the database level
var q = Query.make(Policy)
q.compare("Status", Equals, PolicyStatus.TC_OPEN)
var openPolicies = q.select()
```

## Rule: Use `.Empty` for Existence Checks

Never use `Count > 0`, `hasMatch()`, or `countWhere()` to check whether any record exists. Use the `.Empty` property on the query result — it issues an existence check, not a full count.

```gosu
// WRONG — counts all rows just to check for existence
if (q.select().Count > 0) { ... }

// CORRECT
if (not q.select().Empty) { ... }
```

## Rule: Use `getCountLimitedBy()` for Threshold Checks

When you need to check "are there at least N records?" do not retrieve the full count. Use `getCountLimitedBy(n)` — it stops counting at the threshold.

```gosu
// WRONG — counts all rows when you only need to know if there are 5+
if (q.select().Count >= 5) { ... }

// CORRECT
if (q.select().getCountLimitedBy(5) >= 5) { ... }
```

## Rule: Never Use INTERSECT — Combine Predicates or Use Union

`INTERSECT` in a Gosu query is an antipattern. Use combined predicates on a single query for AND logic, or `union()` for OR logic across distinct sub-queries.

## Rule: Use `.FirstResult` to Retrieve a Single Row

When you only need the first (or only) result, use `.FirstResult` rather than converting to a list and taking index 0. This avoids fetching more rows than needed.

```gosu
// WRONG
var policy = q.select().toList().get(0)

// CORRECT
var policy = q.select().FirstResult
```

## Rule: Multi-Query Web Services Must Use `ConnectionUtil.executeTransactionsWithReservedConnection`

A web service method that issues multiple sequential queries can exhaust the connection pool — each query acquires and releases a connection independently. Wrap multi-query web service methods in `ConnectionUtil.executeTransactionsWithReservedConnection` to reuse a single reserved connection for the duration of the call.

**Do not** use this pattern for single-query operations or inside long-running processes — it holds a connection open for the entire block duration.

Full mechanics: `/context/gosu/queries/30-db-connection-pool.md`.

## Rule: Do Not Use `contains()` as a Case-Insensitive Substring Check

`contains()` on a DB-backed collection performs a case-sensitive in-memory check, not a database LIKE query. For database-level substring search, use the appropriate `compareIgnoreCase` or `startsWith`/`contains` query comparison method, not the Gosu collection operator.

## Rule: Avoid Collection Counting on DB-Backed Arrays

Calling `.Count` directly on an entity's array relationship (e.g. `claim.Exposures.Count`) triggers a full fetch of the related collection. Use a query with `getCountLimitedBy()` or `.Empty` instead.
