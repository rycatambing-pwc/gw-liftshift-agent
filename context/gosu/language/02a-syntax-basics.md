# Gosu Syntax Basics

## Variables and Declarations

```gosu
var x = 10                    // inferred type
var x : int = 10              // explicit type
var x : String                // null default
```

Properties expose backing vars as get/set:
```gosu
var _name : String as Name             // read-write
var _name : String as readonly Name    // read-only
```

`as Name` makes the field publicly accessible via `Name` property. Without `as`, the field is private.

## Functions and Constructors

```gosu
function greet(name : String) : String {
  return "Hello " + name
}
```

Constructors use `construct` keyword, NOT `constructor`:
```gosu
class Foo {
  construct(x : int) { ... }
}
```

## Imports and Packages

```gosu
package com.mycompany.rules
uses gw.api.database.Query
uses gw.api.database.Relop
```

Static field/method import:
```gosu
uses java.lang.Math#*   // imports all static members of Math
```

## String Templates

Inline expressions:
```gosu
"Hello ${name}, you are ${age} years old"
```

Scriptlet (no output): `<% code %>`, expression: `${expr}` or `<%= expr %>`

## Null Safety

- `?.` safe navigation: `obj?.Address?.City`
- `?:` elvis: `name ?: "Unknown"`
- Null-safe spread: `list*.Name` — returns List, nulls become `null` entries

## Type Checking and Casting

- `typeis` — checks type and subtypes: `x typeis String` → true if x is String or subtype
- `typeof` — returns exact runtime type: `typeof x == String` (not `typeof x == Object`)
- `as` — cast: `obj as Address`
- Auto-downcast after `typeis`/`typeof` in `if`/`switch` blocks — no explicit cast needed

```gosu
var obj : Object = ...
if (obj typeis String) {
  print(obj.length)   // obj auto-downcast to String — no cast needed
}
```

`typeof` on null returns `void`. `typeof` on entity/typekey returns `Type<T>`:
```gosu
typeof Producer == Type<Producer>  // true
typeof Producer == Producer        // false — must use Type<T> syntax
```

## Equality

- `==` — structural equality (null-safe), NOT reference equality
- `===` — reference/identity equality
- `!=` and `!==` — negations

## Feature Literals

Reference properties/methods at compile time using `#`:
```gosu
var prop = Employee#Name                  // property reference
var method = Employee#update(String, int) // method reference (type list, not values)
var chained = emp#Boss#Name               // chained path
var bound = emp#Name                      // bound to instance
var block = emp#update("Ed", 34).toBlock() // convert to block
```

Used in Query API (`Query.make(Address).compare(Address#City, Relop.Equals, "NYC")`), mappings, and data-binding layers.

## Intervals

Basic closed interval:
```gosu
var r = 0..5        // integers 0,1,2,3,4,5
for (i in 0..5) { }
```

Open endpoints:
```gosu
0|..5    // excludes 0 — starts at 1
0..|5    // excludes 5 — ends at 4
0|..|5   // excludes both — 1..4
```

Reversed interval:
```gosu
5..0     // iterates 5,4,3,2,1,0
```

Advanced iteration:
```gosu
(0..10).step(2)         // 0,2,4,6,8,10
(0..10).iterateFromLeft()  // always left-to-right even if reversed
r.unit(DateUtil.WEEKS)  // date/time intervals
```

Custom interval types implement `ISequenceable` or `IterableInterval`.

## Enumerations

```gosu
enum Color { RED, GREEN, BLUE }
```

- Enum values are `public static final`-like
- Ordinal comparison with `<`/`>` is valid
- Constructors must be `private`, cannot use `new` keyword
- Nested enum is implicitly `static`
- Built-in properties: `Code`, `Name`, `Ordinal`, `Value`, `DeclaringClass`

## Operators

- `not` — boolean negation (Gosu keyword, NOT `!`)
- `and`, `or` — boolean operators
- Spread operator: `list*.PropertyName` — maps property over list
- `+=` on arrays appends; `-=` on arrays removes element

## Primitive vs. Boxed Types

Primitives (`int`, `boolean`) exist for Java compatibility; Gosu auto-coerces to boxed (`Integer`, `Boolean`) in most contexts. Collections require boxed types. Primitives cannot hold `null`.

## Generics and Type Reification

Gosu reifies generics at runtime — `ArrayList<Integer>` stays typed. This differs from Java type erasure.

```gosu
var list : List<Integer> = new ArrayList<Integer>()
// typeof list is ArrayList<Integer> at runtime
```
