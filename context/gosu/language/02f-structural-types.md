# Gosu Structural Types

## Overview

Structural typing allows objects to satisfy a type contract without explicit inheritance — objects are compatible based on what they *can do* (capabilities), not what they *are declared as* (name-based). This is duck typing with compile-time checking.

## Structure Declaration

```gosu
structure Coordinate {
  property get X() : double
  property get Y() : double
}
```

An object satisfies `Coordinate` if it has `X` and `Y` getters returning `double` — no `implements` declaration needed.

## Assignability Rules

```gosu
class Point {
  property get X() : double { return _x }
  property get Y() : double { return _y }
}

var p = new Point()
var c : Coordinate = p   // OK — Point structurally satisfies Coordinate
```

Works with:
- Plain classes (no `implements`)
- Third-party / Java types (retrofit without modifying source)
- Types defined in libraries the code cannot modify

## Method Variance

- Parameter types: **contravariant** — structure method params can be *broader* than required
- Return types: **covariant** — satisfying method can return a *narrower* type

```gosu
structure Processor {
  function process(input : Object) : String
}

class MyProcessor {
  function process(input : Object) : String { ... }  // satisfies Processor
}
```

## Static Members in Structures

`var` in a structure is a **static constant**, NOT instance data:
```gosu
structure DemoStructure {
  property get Name() : String          // instance — part of structural contract
  public var MAX : Integer = 100        // static constant — NOT part of assignability check
}
```

`var` in structure:
- Must be initialized
- Implicitly static
- NOT included in the structural assignability check

## Enhancements Satisfy Structures

Enhancement methods count toward structural compatibility:
```gosu
// MyClass doesn't have a getName() method itself
// But if an enhancement adds getName() to MyClass,
// MyClass can satisfy a structure requiring getName()
enhancement MyClassEnhancement : MyClass {
  function getName() : String { return "enhanced" }
}
```

## Structures Extending Interfaces

When a structure extends an interface, **structural** (not interface) assignability rules apply:
```gosu
structure HasName extends gw.api.util.Named {
  property get Name() : String
}
// An object satisfies HasName structurally — no need to implement Named
```

## Compound Types

When Gosu infers a type from a heterogeneous list, it creates a compound type:
```gosu
var list = { new TestA(), new TestB() }
// Inferred as: TestParent & HasHello
// TestParent = common supertype, HasHello = common interface/structure
```

Explicit compound types: `TypeA & TypeB`
- All properties/methods from both types available
- Object must satisfy both contracts

Used with `delegate` multi-interface delegation:
```gosu
class Impl delegates ISomething, IOther {
  delegate _s : ISomething = new SomeImpl()
  delegate _o : IOther = new OtherImpl()
}
// Impl type satisfies ISomething & IOther
```

## Structural Types vs Interfaces

| Aspect | Interface | Structure |
|--------|-----------|-----------|
| Declaration | `implements Interface` required | No declaration needed |
| Compile-time check | Yes | Yes |
| Runtime overhead | None | Thin proxy at call site |
| Third-party types | Cannot retrofit | Can retrofit |
| Static members | No | Yes (but not structural) |

## Practical Use Cases

1. **Retrofit Java types** — make existing Java types satisfy a Gosu structure without modifying Java source
2. **Cross-module compatibility** — two modules define similar types; use structure to write generic code
3. **Test doubles** — create mock objects that satisfy structures without inheritance chains
4. **Plugin/extension points** — define capability contracts that any type can satisfy dynamically

## Limitations

- Runtime cost: structural dispatch involves a thin proxy
- Does not work across ClassLoader boundaries
- Cannot require constructors via structure
- Cannot require static methods via structure (instance methods only)
