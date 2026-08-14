---
document: bundles-and-transactions
purpose: Teach writable/read-only entity behavior and transaction context
scope: Bundle, Transaction, query result modification, commit behavior
---

# Bundles and Transactions

## Bundle mental model

A bundle is an in-memory container for entity instances that represent database rows. Guidewire applications use bundles to manage database transactions.

## Bundle types

| Bundle type | Meaning |
|---|---|
| Read-only bundle | Holds entity instances retrieved from queries/database contexts that cannot be modified directly. |
| Writable bundle | Holds entity instances being created, edited, retired, or otherwise modified. |

## Bundle contexts

| Context | Meaning |
|---|---|
| Current bundle | Automatically created/managed by Guidewire; may be read-only or writable depending on context. |
| New bundle | Explicitly created by code; writable; code determines contents. |

## Automatic bundle processing

Often handled automatically in:

- UI edit/update flows
- Gosu Rules
- workflows
- certain plugins

Do not assume every context is automatic.

## Manual bundle processing

Often required for:

- web services that make database changes
- batch processes that make database changes
- modifications to entities returned from queries
- certain plugins
- UI changes when the UI is in read-only mode

## Correct query-result modification pattern

```gosu
gw.transaction.Transaction.runWithNewBundle(\ bundle -> {
  var readOnlyEntity = query.select().FirstResult
  var writableEntity = bundle.add(readOnlyEntity)
  writableEntity.SomeField = someValue
})
```

Critical rule: modify the object returned by `bundle.add(...)`, not the original read-only query result reference.

## Rollback behavior

If one entity in a bundle fails to commit, changes in the bundle are rolled back.

## Lookup sequence

When the application calls for an existing entity, training material describes lookup as:

```text
current bundle -> application server cache -> database
```

Use this as a mental model, but verify exact behavior for version-specific performance analysis.

## Bundle size and paging

Large bundles can cause memory/performance problems. When processing large query results, consider paging and regular commits. Be careful modifying columns used for paging/query cursor positioning.

## Agent checks

When scanning modification code:

1. Is the entity from a query result?
2. Is there a writable bundle?
3. Is `bundle.add(...)` used?
4. Is the returned writable reference modified?
5. Are commits explicit or automatic in this context?
6. Could the bundle grow too large?
