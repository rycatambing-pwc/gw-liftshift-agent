---
document: validation-checklist
purpose: Pre-output gate for the gw-gosu-agent before returning code or findings
scope: Gosu code correctness, InsuranceSuite conventions, common error prevention
---

# Gosu Agent Validation Checklist

- [ ]

## File and context identification

- [ ] Identified file type: `.gs`, `.gsx`, `.gr`, `.gst`, `.gsp`, `.pcf`, `.eti`, `.etx`, `.tti`, `.ttx`, etc.?
- [ ] Identified execution context: UI, rule, plugin, batch, web service, query, test, CLI?
- [ ] If `.gsx` — enhancement on which type? Dispatch is **static**, not virtual.
- [ ] If `.gr` — which rule category (Preupdate, Validation, EventMessage)? Which root entity?
- [ ] If `.gst` — is template large enough to risk the JVM 65535-byte method limit?
- [ ] If `.gsp` — does code avoid entity/PCF types (not available in CLI context)?

## Symbol resolution

- [ ] Checked `.gsx` for unresolved methods/properties before reporting them as missing?
- [ ] Checked `.eti`/`.etx`/`.eix` for entity fields before assuming they don't exist?
- [ ] Checked `.tti`/`.ttx`/`.tix` for typekey constants — compared as typekeys, not strings?
- [ ] Checked PCF root variables or row iterator `elementName` if inside `.pcf`?

## Critical Gosu correctness rules

- [ ] **`setFieldValue` NOT used** — if present, flag as FORBIDDEN and replace with property setter.
- [ ] **`bundle.add()` return value saved** — `myEntity = bundle.add(myEntity)`, never `bundle.add(myEntity)` alone.
- [ ] **`==` vs `===`** — `==` is structural/value equality; `===` is reference equality. Used correctly?
- [ ] **`not`/`and`/`or`** used instead of `!`/`&&`/`||`? (Gosu convention)
- [ ] **`construct` keyword** used for constructors, NOT `constructor`?
- [ ] **Entity string fields** — no need to call `.trim()` before assignment; platform auto-trims.
- [ ] **Array mutation** — `addToX()`/`removeFromX()` used for entity array relationships, not direct array assignment?

## Query semantics

- [ ] Identified the primary entity type returned?
- [ ] All predicates pushed into `compare()`/`compareIn()`/`join()` before `.select()`?
- [ ] No in-memory filtering (`.where()`, `.firstWhere()`) used as substitute for database predicates on large result sets?
- [ ] Typekey comparisons use `typekey.TypeList.TC_Code` constants, not strings?
- [ ] Existence check uses `result.Empty` (faster), not `result.Count == 0`?
- [ ] INTERSECT not used — combined predicates on single query instead?
- [ ] For multi-query web services: `@WsiReduceDBConnections` or `ConnectionUtil.executeTransactionsWithReservedConnection` considered?

## Bundle and transaction

- [ ] Is code running in automatic bundle context (UI, rules, workflows) or does it need explicit `Transaction.runWithNewBundle`?
- [ ] All query result entities that need modification passed through `bundle.add()` with return value saved?
- [ ] `setFieldValue` absent (FORBIDDEN)?
- [ ] Bundle size bounded — paging and periodic commits for large batch operations?
- [ ] `entity.remove()` preferred over `bundle.delete(entity)` where available?

## Written code conventions

- [ ] New methods/properties added to base GW entities have `_Ext` suffix?
- [ ] New classes in customer package spaces (not `gw.*` or `com.guidewire.*`)?
- [ ] Feature literals (`Entity#Property`) used for Query API comparisons, not string field names?
- [ ] `LockingLazyVar.make(\-> ...)` used for thread-safe lazy class-level initialization (not raw null-check pattern)?
- [ ] `ThreadLocal` NOT used — `RequestVar` or `SessionVar` preferred for request/session-scoped state?
- [ ] Debug/trace logging guarded with `_logger.DebugEnabled`?
- [ ] No `print(...)` statements in production code?

## Integration-specific

- [ ] XML: `element.bytes()` used (preferred); `element.asUTFString()` only for debugging?
- [ ] JSON: `dynamic.Dynamic` typed properly; `@ActualName` added for non-camelCase keys?
- [ ] Dynamic/Expando method values are blocks, not plain values?

## PCF and rules

- [ ] Root object, PCF variables, and row iterator `elementName` identified in scope?
- [ ] UI `validationExpression` distinguished from validation rules (`.gr`)?
- [ ] `Validatable`, `implementsEntity`, and `triggersValidation` checked where validation behavior is unclear?

## Final answer discipline

- [ ] Verified facts separated from inferred facts.
- [ ] Any entity field, typelist, typecode, or LOB-specific reference that was NOT verified in project files is labeled as "needs project verification."
- [ ] Compile correctness NOT claimed unless validated against target project/version.
- [ ] If Gosu change requires companion changes (entity files, typelists, PCFs, display keys) — called out explicitly and delegated to the responsible agent.
