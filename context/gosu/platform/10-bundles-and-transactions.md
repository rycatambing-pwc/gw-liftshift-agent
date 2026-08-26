---
document: bundles-and-transactions
purpose: Teach writable/read-only entity behavior and transaction context
scope: Bundle, Transaction, query result modification, commit behavior, field change detection
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
- Workflows
- Certain plugins

Do not assume every context is automatic.

## Manual bundle processing

Often required for:
- Web services that make database changes
- Batch processes that make database changes
- Modifications to entities returned from queries
- Certain plugins
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

## bundle.add() — MUST save return value

`bundle.add(obj)` returns a NEW copy of the entity that is tracked by the bundle. The original reference is NOT modified.

```gosu
// WRONG — entity still outside bundle
bundle.add(myEntity)
myEntity.Status = "Active"   // modifying untracked original

// CORRECT — use returned copy
myEntity = bundle.add(myEntity)
myEntity.Status = "Active"   // modifying bundle-tracked copy
```

## New entity in a specific bundle

```gosu
// Create new entity in an explicit bundle
var note = new Note(myActivity)   // pass parent entity — bundle inferred
var note = new Note(bundle)       // pass bundle explicitly
```

## Explicit commit (use sparingly)

```gosu
bundle.commit()   // explicit commit — dangerous, rarely needed
```

`runWithNewBundle` auto-commits on success — prefer it over manual `bundle.commit()`.

## Delete vs remove

```gosu
bundle.delete(entity)    // marks for DB deletion
entity.remove()          // preferred — entity removes itself from parent/bundle
```

Prefer `entity.remove()` where available.

## Field change detection

```gosu
entity.isFieldChanged("FieldName")          // boolean — field changed this transaction
entity.getOriginalValue("FieldName") as Type  // value before changes
entity.Changed                              // boolean — any field changed
entity.ChangedFields                        // Set<String> — names of changed fields
```

Array relationship change detection:
```gosu
entity.getAddedArrayElements("RelationName")    // newly added items
entity.getChangedArrayElements("RelationName")  // modified items
entity.getRemovedArrayElements("RelationName")  // removed items
```

## Bundle inspection

```gosu
bundle.InsertedBeans    // all entities being inserted
bundle.ChangedBeans     // all entities with changes
bundle.RemovedBeans     // all entities being deleted
// Typed variants also available, e.g.:
bundle.InsertedBeans.whereTypeIs(Policy)
```

## Force version increment

```gosu
entity.touch()   // forces version increment even if no fields changed
```

Useful when downstream processes depend on version number changes.

## Transaction and bundle access

```gosu
Transaction.getCurrent()        // access current transaction
Bundle.loadBean(key)            // load entity into bundle by public ID / key
```

## Rollback behavior

If one entity in a bundle fails to commit, all changes in the bundle are rolled back.

## Lookup sequence

```text
current bundle -> application server cache -> database
```

Use as a mental model; verify exact behavior for version-specific performance analysis.

## Bundle size and paging

Large bundles can cause memory/performance problems. When processing large query results, consider paging and regular commits. Be careful modifying columns used for paging/query cursor positioning.

## setFieldValue IS FORBIDDEN

**NEVER use `setFieldValue` in user code.** It bypasses bundle tracking and type checking, causing data corruption.

```gosu
entity.setFieldValue("Field", value)   // FORBIDDEN
entity.Field = value                   // CORRECT
```

## Agent checks

When scanning modification code:

1. Is the entity from a query result?
2. Is there a writable bundle?
3. Is `bundle.add(...)` used AND the return value saved?
4. Is the returned writable reference (not original) modified?
5. Are commits explicit or automatic in this context?
6. Could the bundle grow too large?
7. Is `setFieldValue` used? Flag as forbidden if so.
