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
| `var x : T` | `T x` |
| `construct(...)` | constructor |
| `function f(...) : T` | method returning `T` |
| `for (x in list)` | enhanced for loop |
| `for (x in list index i)` | enhanced for loop with zero-based index |
| `and` / `or` / `not` | `&&` / `||` / `!`; Guidewire style often prefers text form |
| `typeis` | `instanceof` |
| `as` / `as?` | cast / safe cast |
| `==` | value equality |
| `===` | reference equality |
| `?.` | explicit null-safe access, especially important for method calls |
| `?:` | null-coalescing / Elvis fallback |
| `\ x -> ...` | block / closure |
| `*.Property` | spread operation over a collection |
| `Type#Field` | type-safe feature/property reference |
| `property get/set` | getter/setter property |
| `enhancement` | extension methods/properties on an existing type |

## File type map

| Extension | Meaning |
|---|---|
| `.gs` | Gosu class |
| `.gsx` | Gosu enhancement |
| `.gr` | Gosu rule |
| `.pcf` | Page Configuration Format XML with embedded Gosu expressions |
| `.eti` | Entity definition |
| `.etx` | Customer entity extension |
| `.eix` | Internal/platform entity extension |
| `.tti` | Base typelist definition |
| `.ttx` | Customer typelist extension |
| `.tix` | Internal/platform typelist extension |
| `.en` | Entity name definition used by `DisplayName` |

## Highest-risk assumptions to avoid

- Typekeys are not strings.
- Entity fields may be generated from XML metadata, not declared in `.gs` code.
- Methods may come from `.gsx` enhancements.
- Query result filtering after `select()` may be in-memory, not database filtering.
- Query result entities may be read-only until copied into a writable bundle.
- PCF expressions depend on PCF root objects, variables, and row iterator element names.
- Validation behavior can come from UI validation expressions, validation rules, data model delegates, and `triggersValidation`.
