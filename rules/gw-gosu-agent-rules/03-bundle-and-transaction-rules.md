# Bundle and Transaction Rules

These are correctness rules — violating them produces silent data loss, entity state detachment, or incorrect persistence behavior. Full background: `/context/gosu/platform/10-bundles-and-transactions.md`.

## Rule: Save the Return Value of `bundle.add()`

`bundle.add()` does **not** mutate the passed object in place — it returns the bundle-enrolled copy. Discarding the return value means you are still holding a reference to the original, non-enrolled entity and any changes on it will be lost silently.

```gosu
// WRONG — changes to myEntity are silently dropped
bundle.add(myEntity)
myEntity.SomeField = "value"

// CORRECT — work with the enrolled copy
var enrolled = bundle.add(myEntity)
enrolled.SomeField = "value"
```

This is the single most common bundle correctness bug.

## Rule: Prefer Automatic Bundle Processing Contexts

Guidewire provides automatic bundle management for web requests, rule executions, and batch processes. Use these automatic contexts wherever possible.

**Do not** call `bundle.commit()` explicitly unless you are in a context that genuinely has no automatic bundle lifecycle (e.g. a standalone CLI program or a tightly controlled batch operation). Explicit commits in automatic contexts double-commit and can cause integrity errors.

## Rule: Use `entity.remove()` — Not `delete`

To delete a persistent entity, call `entity.remove()`. The `delete` keyword removes the local variable reference but does **not** mark the entity for deletion in the database.

```gosu
// WRONG — does not delete from DB
delete myRecord

// CORRECT
myRecord.remove()
```

## Rule: Never Instantiate a Persistent Entity Outside a Bundle Context

Calling `new SomeEntity()` outside an active bundle context produces a detached entity that cannot be persisted. Always instantiate persistent entities inside a bundle context (web request, batch process, or explicit `gw.transaction.Transaction.runWithNewBundle` block).

## Rule: Use Change-Detection Methods Instead of Re-Querying

To check whether a field or array changed within the current bundle, use the platform-provided change-detection methods — do not re-query the database to compare.

| Need | Correct approach |
|---|---|
| Was a scalar field changed? | `entity.isFieldChanged("FieldName")` |
| Original value before change | `entity.getOriginalValue("FieldName")` |
| Which fields changed? | `entity.ChangedFields` |
| Was an array element added? | `entity.getAddedArrayElements("RelName")` |
| Was an array element removed? | `entity.getRemovedArrayElements("RelName")` |

## Rule: Use `entity.touch()` When a Version Increment Is Needed Without a Data Change

If you need to force an optimistic-lock version bump on an entity without changing any data fields, call `entity.touch()` — do not assign a field to its current value as a workaround.
