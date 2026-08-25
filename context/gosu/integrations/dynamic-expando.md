---
document: gosu-dynamic-expando
purpose: Dynamic typing, Expando objects, and dynamic dispatch in Gosu
scope: dynamic.Dynamic, gw.lang.reflect.Expando, $getProperty, $invokeMethod
---

# Dynamic Types and Expando Objects

## Overview

`dynamic.Dynamic` is a special Gosu type that defers type checking to runtime. Any value can be assigned to a `Dynamic` variable, and property/method access on it is resolved at runtime.

## Dynamic Variable Declaration

```gosu
var obj : dynamic.Dynamic = getSomeValue()
obj.AnyProperty   // no compile-time check — resolved at runtime
obj.anyMethod()   // no compile-time check
```

## Expando Objects

`gw.lang.reflect.Expando` is a built-in `Dynamic` implementation backed by a `HashMap`:

```gosu
var villain : dynamic.Dynamic = new Expando()
villain.Health = 10
villain.Name = "Darth"
villain.punch = \-> {
  if (villain.Health > 0) villain.Health--
}
villain.isDead = \-> villain.Health <= 0

// Access
print(villain.Name)        // "Darth"
villain.punch()            // decrements Health
print(villain.isDead())    // false (Health still > 0)
```

- **Property values**: any type
- **Method values**: must be blocks (closures)
- **Uninitialized property**: returns `null`

## Path Assignment Auto-Creation

Assigning a value to a multi-step path on an Expando auto-creates intermediate objects:

```gosu
var obj : dynamic.Dynamic = new Expando()
obj.address.city = "Chicago"   // auto-creates obj.address as new Expando
```

`setDefaultFieldValue` hook is called when auto-creating intermediate objects.

## Dynamic Dispatch Hooks

Implement these on a class (or its enhancement) to control dynamic behavior:

| Method | When called |
|--------|------------|
| `$getProperty(name : String)` | Property get — first attempt |
| `$getMissingProperty(name : String)` | Property get — when property not found normally |
| `$setProperty(name : String, value : Object)` | Property set — first attempt |
| `$setMissingProperty(name : String, value : Object)` | Property set — when not found |
| `$invokeMethod(name : String, args : Object[])` | Method invoke — first attempt |
| `$invokeMissingMethod(name : String, args : Object[])` | Method invoke — when not found |

Return `IPlaceholder.UNHANDLED` to fall through to the next handler (missing variant).

```gosu
class MyDynamic implements dynamic.IDynamic {
  override function $getProperty(name : String) : Object {
    if (name == "SpecialProp") return computeSpecial()
    return IPlaceholder.UNHANDLED  // fall through to $getMissingProperty
  }

  override function $getMissingProperty(name : String) : Object {
    return null  // default: return null for unknown properties
  }
}
```

## Concise Dynamic Creation Syntax

```gosu
var person : dynamic.Dynamic = new() {
  :Name = "John Smith",
  :Age = 39,
  :Address = new() {
    :City = "Foster City",
    :State = "CA"
  }
}
```

Named initializer syntax works for any dynamic/Expando object.

## Serialization

```gosu
var json = obj.toJson()     // JSON string
var xml = obj.toXml()       // XML string
var gosuCode = obj.toGosu() // Gosu initializer code

// Deserialize from Gosu code
var clone = eval(obj.toGosu())
```

## Type Checking Dynamic Values

Since dynamic values lose compile-time type info, check type before using:

```gosu
var val : dynamic.Dynamic = getApiResponse()
if (val typeis String) {
  var s = val as String
  // use as string
} else if (val typeis List) {
  var list = val as List<dynamic.Dynamic>
  // use as list
}
```

## When to Use Dynamic Types

**Use dynamic.Dynamic for:**
- Parsing JSON/XML with unknown schema
- Interoperating with scripting engines
- Prototype/experimental code

**Avoid dynamic.Dynamic when:**
- The type is known — use static types for compile-time safety
- In entity/business logic — types should be known and verified
- In performance-critical code — dynamic dispatch has overhead

## Agent checks

When reviewing dynamic type usage:

1. Is `dynamic.Dynamic` necessary or can a static type be used?
2. Are dynamic property accesses null-checked?
3. Is the dynamic object typed as `dynamic.Dynamic` rather than raw `Object`?
4. Are method values (on Expando) confirmed to be blocks, not plain values?
