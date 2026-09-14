# Performance Rules

These rules prevent the most common Gosu performance anti-patterns in Guidewire. Full background: `/context/gosu/queries/07-query-performance-antipatterns.md`, `/context/gosu/ui_and_rules/08-pcf-ui-model-and-embedded-gosu.md`, `/context/gosu/cross_cutting/14-system-health-profiler-dbcc-and-inspections.md`.

## Rule: Never Filter In-Memory on DB-Backed Collections

Calling collection methods (`where`, `hasMatch`, `countWhere`, loops) on a DB-backed entity array fetches the **entire collection** before filtering. This is always wrong when the filter could have been pushed into a query predicate.

**Correct approach:** write a `Query.make(...)` with the relevant predicates and operate on the query result.

## Rule: Hoist Expensive PCF Expressions Into PCF-Level Variables

An "expensive expression" in a PCF widget property (multi-step dot path, spread over a collection, collection method, complex Gosu method call) is re-evaluated on every page refresh. Move it into a PCF-level `variable`, initialized once at page construction.

```
// WRONG — evaluated on every refresh
<Input value="someExpensiveMethod()" .../>

// CORRECT — evaluated once when the page is constructed
<Variable name="cachedValue" initialValue="someExpensiveMethod()"/>
<Input value="cachedValue" .../>
```

**Caution:** do not set `recalculateOnRefresh="true"` on variables that hold expensive values unless absolutely required — doing so defeats the caching benefit on pages with `PostOnChange` fields.

Full mechanics: `/context/gosu/ui_and_rules/08-pcf-ui-model-and-embedded-gosu.md`.

## Rule: One Shared PCF Variable for Multiple Widgets Using the Same Expensive Method

If several widgets on a page all need the result of the same expensive method (e.g. for `required`, `editable`, `available` properties), do not call the method in each widget's property separately. Create **one** page-level variable initialized with the call and reference it from all widgets.

## Rule: For ListView Cells — Hoist to Row Iterator Only When the Value Doesn't Vary Per Row

If an expensive method is called in a ListView cell's `value` and the result is **the same for every row** (e.g. a current-user-level lookup), hoist it to a variable on the Row Iterator. If the value genuinely varies per row, this technique does not apply — a row-varying computation cannot be shared across rows.

## Rule: Use Permission Typecodes — Not Role Membership Checks — for Widget Gating

Never check a user's role membership (e.g. `user.Roles.hasMatch(\ r -> r.Name == "Admin")`) to gate a widget's `Editable` / `Visible` / `Available` property. This is both a performance problem (triggers a background query and in-memory iteration) and an architectural one (it bypasses the Guidewire permission framework).

**Correct approach:**
1. Extend the `SystemPermissionType` typelist with a new typecode (e.g. `edituserdetails_Ext`).
2. Test that permission in the widget's property expression directly.

## Rule: Use `LockingLazyVar` for Thread-Safe Lazy Initialization

Do not use the null-check pattern (`if (field == null) { field = ... }`) for lazily initialized class-level values — it is not thread-safe under concurrent requests.

```gosu
// WRONG — race condition under concurrent access
private var _cache : SomeType = null
property get Cache() : SomeType {
  if (_cache == null) { _cache = buildCache() }
  return _cache
}

// CORRECT
private static final var _cache = LockingLazyVar.make(\ -> buildCache())
property get Cache() : SomeType { return _cache.get() }
```

Use `LocklessLazyVar` only when concurrent access is provably impossible for that field. Never use raw `ThreadLocal` — prefer `RequestVar` (per-HTTP-request) or `SessionVar` (per-HTTP-session) instead.

## Rule: Guard Log Statements with Level Checks

Constructing a log message string is not free — avoid it when the logger level would suppress the output anyway.

```gosu
// WRONG — string construction happens even when debug is off
logger.debug("Processing policy: " + policy.PolicyNumber)

// CORRECT
if (logger.DebugEnabled) {
  logger.debug("Processing policy: " + policy.PolicyNumber)
}
```

This matters most inside loops or frequently called methods.
