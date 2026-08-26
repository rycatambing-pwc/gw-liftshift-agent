# Gosu Operators and Advanced Types

## Comparison and Spread Operators

- `==` structural equality (null-safe)
- `===` identity/reference equality
- `typeis` — type check including subtypes
- `typeof` — exact runtime type
- `?.` safe navigation — returns null instead of NPE
- `?:` elvis — returns right side if left is null
- `not` — boolean NOT (keyword, not `!`)
- `and`, `or` — boolean operators
- Spread: `list*.Name` — maps property over collection, result is `List`
- Feature literal: `Entity#property` — compile-time member reference

## Type Coercion

Coercions API:
```gosu
Coercions.makeBooleanFrom(5 * 4)  // true
Coercions.makeStringFrom(5 * 4)   // "20"
```

Array cast (subtype):
```gosu
var strArray = objArray.cast(String)   // OK — cast to subtype
var strArray = objArray as String[]    // Runtime error if objArray is Object[]
```

Auto-downcast after `typeis`/`typeof` in `if`/`switch` — no explicit `as` needed.

## Structural Types

```gosu
structure Coordinate {
  property get X() : double
  property get Y() : double
}
```

- `structure` keyword (not `interface`) — capability-based assignability
- Objects satisfy structural type without declaring it — works with third-party types
- `var` in a structure = implicitly static constant, NOT instance data; must initialize; NOT part of assignability check
- Method variance: param types contravariant, return type covariant
- Enhancement methods satisfy structural type requirements
- Extends interface = structural assignability rules apply (not interface rules)

```gosu
// var in structure = static constant only
structure DemoStructure2 {
  property get Name() : String
  public var AGE : Integer = 18   // static constant, not instance data
}
```

## Compound Types

When Gosu infers a type from a list of mixed objects, it finds the least upper bound:
```gosu
var list = { new TestA(), new TestB() }
// compile type: TestParent & HasHello (compound type)
```

Compound type syntax: `TypeA & TypeB`. Appears with `delegate` multi-interface and inferred generics.

## Dynamic Types and Expando Objects

`dynamic.Dynamic` allows any reference assignment and dynamic property/method dispatch:
```gosu
var obj : dynamic.Dynamic = new DynamicGetter()
obj.StreetAddress     // dynamic property lookup
```

Dynamic dispatch handler methods (implement on class or enhancement):
- `$getProperty(name)` / `$getMissingProperty(name)` — get
- `$setProperty(name, value)` / `$setMissingProperty(name, value)` — set
- `$invokeMethod(name, args[])` / `$invokeMissingMethod(name, args[])` — invoke
- Return `IPlaceholder.UNHANDLED` to fall through to missing handlers

`gw.lang.reflect.Expando` — built-in `dynamic.Dynamic` object backed by `HashMap`:
```gosu
var villain : Dynamic = new Expando()
villain.Health = 10
villain.punch = \-> { if (villain.Health > 0) villain.Health-- }
villain.isDead = \-> villain.Health <= 0
```

Method values must be blocks. Getting uninitialized property returns `null`.
`setDefaultFieldValue` called when auto-creating intermediate objects in path assignment (`dyn.abc.def = "hi"`).

Dynamic object serialization:
```gosu
obj.toJson()   // serialize to JSON
obj.toXml()    // serialize to XML
obj.toGosu()   // serialize to Gosu initializer code
var clone = eval(obj.toGosu())  // deserialize
```

JSON-like concise creation:
```gosu
var person : dynamic.Dynamic = new() {
  :Name = "John Smith",
  :Age = 39,
  :Address = new() { :City = "Foster City" }
}
```

## Type Metadata and Reflection

Every type has metadata accessible via `.Type`:
```gosu
var t = typeof myVar   // or MyClass.Type
t.DisplayName          // human-readable name
t.Supertype            // supertype
t.Interface            // boolean
t.Abstract             // boolean
t.GenericType          // raw generic type (ArrayList<String> → java.util.ArrayList)
t.TypeInfo.Properties  // list of property infos
t.TypeInfo.Methods     // list of method infos
t.isAssignableFrom(OtherType)  // inheritance check (not coercion)
```

Reflective property access (use sparingly — hides compile-time errors):
```gosu
obj["PropertyName"]   // equivalent to reflective getter
(typeof obj).TypeInfo.getProperty("MyProp").Accessor.getValue(obj)
```

TypeSystem for dynamic type lookup:
```gosu
var type = TypeSystem.getByFullName("com.mycompany.MyType")
var instance = type.TypeInfo.getConstructor(null).Constructor.newInstance(null)
```

Prefer static typing; use reflection only when no static alternative exists.

## Gosu Dimensions

`IDimension<CLASSNAME, UNITTYPE>` — interface for physical quantities:

Required methods: `add`, `subtract`, `multiply`, `division`, `modulo`, `negate`, `toNumber`, `fromNumber`, `numberType`; `compareTo` for ordering.

Built-in dimension types:
```gosu
new gw.pl.currency.MonetaryAmount(100.00bd, Currency.TC_USD)
new gw.api.financials.CurrencyAmount(100.00bd, Currency.TC_USD)
```

Dimensions support arithmetic operators when properly implemented.

## Generics

Gosu generics work like Java generics but are reified — type info is retained at runtime:
```gosu
var list : List<Integer> = new ArrayList<Integer>()
// typeof list element access returns Integer, not Object
```

Wildcards use `?` (upper bound: `? extends Type`, lower bound: `? super Type`).

## Annotations

Built-in annotations:
- `@AutoCreate` — auto-creates entity on LHS assignment if null
- `@AutoInsert` — auto-inserts item into list array
- `@ShortCircuitingProperty` — null object returns 0/false instead of NPE
- `@SuppressWarnings("arg")` — suppresses warnings; `LOCAL_VARIABLE` NOT supported

Custom annotation definition:
```gosu
annotation MyAnnotation {
  function purpose() : String
  function importance() : int = 0   // default value
}
```

Meta-annotations: `@Target`, `@Retention`, `@Inherited`, `@Documented`

Runtime annotation access:
```gosu
var ann = (typeof obj).TypeInfo.getAnnotation(MyAnnotation).Instance as MyAnnotation
ann.purpose()
ann.importance()
```
