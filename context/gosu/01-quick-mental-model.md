---
document: gosu-quick-mental-model
purpose: Fast Java-to-Gosu map for code scanning
scope: Always-load orientation
---

# Quick Mental Model

## Java-to-Gosu map

| Gosu | Think in Java / analysis equivalent |
|---|---|
| `uses` | `import` |
| `uses java.lang.Math#*` | `import static java.lang.Math.*` |
| `var x : T` | `T x` |
| `construct(...)` | constructor — NOT `constructor` keyword |
| `function f(...) : T` | method returning `T` |
| `for (x in list)` | enhanced for loop |
| `for (x in list index i)` | enhanced for loop with zero-based index |
| `and` / `or` / `not` | `&&` / `\|\|` / `!` — Gosu uses keywords, not symbols |
| `typeis` | `instanceof` — includes subtypes |
| `typeof` | exact runtime type — NOT `instanceof`; `typeof null` returns `void` |
| `as` | cast |
| `==` | value/structural equality (null-safe) |
| `===` | reference/identity equality |
| `?.` | null-safe property/method access — returns null instead of NPE |
| `?:` | null-coalescing / Elvis fallback |
| `\ x -> ...` | block / closure / lambda |
| `*.Property` | spread — maps property over collection, returns `List` |
| `Type#Field` | feature literal — compile-time type-safe member reference |
| `property get/set` | getter/setter property |
| `enhancement` | extension methods/properties on an existing type (static dispatch, NOT virtual) |
| `structure Foo { ... }` | structural type — capability-based, no `implements` required |
| `delegate _x : IFoo = new FooImpl()` | auto-delegates interface `IFoo` to `_x`; replaces manual forwarding methods |
| `0..5` | closed interval (integers 0,1,2,3,4,5) |
| `+=` on array | append element to array |
| `-=` on array | remove element from array |
| generics | reified at runtime (unlike Java type erasure) — `List<Integer>` stays typed |

## File type map

| Extension | Meaning |
|---|---|
| `.gs` | Gosu class |
| `.gsx` | Gosu enhancement (extension methods/properties on existing types) |
| `.gr` | Gosu rule |
| `.gst` | Gosu template — generates text output, rendered via `renderToString()` |
| `.gsp` | Gosu program — standalone CLI script, uses `Gosu.RawArgs`; no entity/PCF access |
| `.pcf` | Page Configuration Format XML with embedded Gosu expressions |
| `.eti` | Entity definition |
| `.etx` | Customer entity extension |
| `.eix` | Internal/platform entity extension |
| `.tti` | Base typelist definition |
| `.ttx` | Customer typelist extension |
| `.tix` | Internal/platform typelist extension |
| `.en` | Entity name definition used by `DisplayName` |

## Highest-risk assumptions to avoid

- **Typekeys are not strings** — compare `claim.LossCause == LossCause.TC_REAREND`, not to a string literal.
- **Entity fields may be generated from XML metadata**, not declared in `.gs` code — check `.eti`/`.etx` before assuming a field doesn't exist.
- **Methods may come from `.gsx` enhancements** — if a method isn't in the class, search enhancement files.
- **Enhancement dispatch is STATIC, not virtual** — the declared type of the variable determines which enhancement method runs, NOT the runtime type.
- **Query result filtering after `select()` is in-memory**, not database filtering — push predicates into `compare()` before `select()` where possible.
- **Query result entities may be read-only** — must call `bundle.add(entity)` and use the returned copy to modify; the original reference is NOT in the bundle.
- **`bundle.add(obj)` MUST have its return value saved** — `bundle.add(myEntity)` without saving the return value leaves `myEntity` untracked; always write `myEntity = bundle.add(myEntity)`.
- **`setFieldValue` IS FORBIDDEN in user code** — it bypasses bundle tracking and type checking, causing data corruption. Use the generated property setter instead.
- **String fields on entities are auto-trimmed on assignment** — the platform strips leading/trailing whitespace; no need to call `.trim()` before setting.
- **PCF expressions depend on PCF root objects, variables, and row iterator element names** — a symbol that looks unresolved may be a PCF-level variable.
- **Validation behavior can come from multiple places**: UI validation expressions (PCF), validation rules (`.gr`), data model delegates (`Validatable`), and `triggersValidation`.
- **`typeof null` returns `void`** — not `null` and not `Object`; guard null checks before `typeof`.
