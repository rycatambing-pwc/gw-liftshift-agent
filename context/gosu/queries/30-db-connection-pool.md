---
document: gosu-db-connection-pool
purpose: Teach DB connection reservation patterns for high-throughput scenarios
scope: ConnectionUtil, @WsiReduceDBConnections, reserved connections
---

# DB Connection Pool Management

## Problem: Multiple Queries, Multiple Connections

By default, each query in Guidewire opens its own database connection from the pool. In web services or batch operations that execute many queries in sequence, this can exhaust the connection pool.

## Solution: Reserve a Single Connection

`gw.transaction.ConnectionUtil.executeTransactionsWithReservedConnection(runnable)` reserves one connection for all queries inside the runnable:

```gosu
uses gw.transaction.ConnectionUtil

ConnectionUtil.executeTransactionsWithReservedConnection(\-> {
  // All queries inside here reuse the same DB connection
  var policies = Query.make(Policy).select()
  for (policy in policies) {
    var activities = Query.make(Activity)
      .compare(Activity#Policy, Relop.Equals, policy)
      .select()
    // process activities...
  }
})
```

- All queries within the block share one connection
- Connection is released when the block exits
- Reduces connection pool pressure for multi-query operations

## Web Service Annotation: @WsiReduceDBConnections

Apply to web service methods that execute many queries:

```gosu
@WsiWebService
class MyWebService {

  @WsiReduceDBConnections
  function getPolicySummary(policyNumber : String) : PolicySummaryDTO {
    // All DB operations within this method use one reserved connection
    var policy = Query.make(Policy)
      .compare(Policy#PolicyNumber, Relop.Equals, policyNumber)
      .select().FirstResult
    var activities = policy.Activities
    // ...
  }
}
```

The annotation is equivalent to wrapping the method body in `executeTransactionsWithReservedConnection`.

## Getting the Active Connection Inside a Block

```gosu
uses gw.transaction.ConnectionHandlerFactory

ConnectionUtil.executeTransactionsWithReservedConnection(\-> {
  var conn = ConnectionHandlerFactory.getActiveConnection()
  // Use conn for raw JDBC operations if needed (rare)
})
```

Only valid inside the reserved connection block — returns null otherwise.

## When to Use

- Web service endpoints that run multiple queries per request
- Batch processing with sequential queries in a loop
- Any operation where `executeTransactionsWithReservedConnection` vs multiple connections is a measurable bottleneck

## When NOT to Use

- Simple single-query operations — no benefit
- Long-running operations that hold the connection open for extended time — can itself cause pool exhaustion
- Inside an existing reserved connection block — nesting is not supported

## Agent checks

When reviewing code with multiple sequential queries in a web service:
1. Is `@WsiReduceDBConnections` present on the web service method?
2. If not, is `executeTransactionsWithReservedConnection` used?
3. Is the connection held for longer than the multi-query operation requires?
