---
document: gosu-core-deltas
purpose: Explain Gosu syntax as deltas from Java
scope: Syntax and language-level comprehension
---

# Core Gosu Deltas

## Variables

```gosu
var name : String = "Alice"
var count = 0
```

Rule: `var` introduces a local variable. Type annotation appears after a colon and is often inferred.

## Functions

```gosu
function getFullName(first : String, last : String) : String {
  return first + " " + last
}
```

Rule: return type comes after the parameter list. Access is public by default unless restricted.

## Constructors

```gosu
class PolicyHelper {
  construct(period : PolicyPeriod) {
  }
}
```

Rule: Gosu uses `construct`, not the class name.

## Imports

```gosu
uses gw.api.database.Query
```

Rule: `uses` is import.

## Blocks and closures

```gosu
var active = policies.where(\ p -> p.Active)
var first = policies.firstWhere(\ p -> p.Status == typekey.PolicyStatus.TC_BOUND)
```

Rule: a block begins with backslash. Blocks are heavily used in collection methods, queries, rules, and UI expressions.

## Collection methods

Common collection methods:

- `hasMatch(\ x -> condition)` — true if any element matches.
- `countWhere(\ x -> condition)` — count matching elements in memory/collection context.
- `firstWhere(\ x -> condition)` — first matching element.
- `where(\ x -> condition)` — collection of matching elements.

Caution: these may operate in memory. For database-backed data, prefer Query API filtering before retrieval.

## Equality

```gosu
a == b   // value equality
a === b  // reference equality
```

Gotcha: do not import Java's `==` mental model.

## Type checking and casting

```gosu
if (obj typeis PolicyPeriod) {
  var period = obj as PolicyPeriod
}
var maybePeriod = obj as? PolicyPeriod
```

## Feature/member literals

```gosu
PolicyPeriod#Status
Address#State
```

Rule: `Type#Member` is a type-safe reference to a property/member. It is common in Query API and reflection-like contexts.

## Enhancements

```gosu
enhancement PolicyPeriodEnhancement_Ext : PolicyPeriod {
  property get IsLargePolicy_Ext() : boolean {
    return this.TotalPremiumRPT > 100000bd
  }
}
```

Rule: enhancements can add methods and properties to existing types. They are defined in `.gsx` files.

Gotcha: when a method cannot be found on the visible class, search `.gsx` files.

## Properties

```gosu
property get DisplayLabel() : String {
  return this.Name ?: "UNKNOWN"
}
```

Getter rule: a getter should calculate and return a value; it should not mutate data.

Setter rule: a setter takes one input and modifies the associated object. Use a method when multiple parameters, multiple objects, or substantial business work are involved.

## Null safety

Use `?.` when a receiver may be null, especially before method calls. Do not assume Java's exact null behavior for every property access. Prefer explicit null-safe chains in analysis examples:

```gosu
var code = period?.Policy?.Product?.Code ?: "UNKNOWN"
```

## Spread operator

```gosu
var policyNumbers = periods*.PolicyNumber
```

Rule: apply property/method access to each element and return a collection of results.

## Text logical operators

Gosu supports both symbol and text forms, but Guidewire style often prefers:

```gosu
if (x != null and not x.Retired) {
}
```
