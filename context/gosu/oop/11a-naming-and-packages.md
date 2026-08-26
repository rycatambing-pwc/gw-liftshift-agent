---
document: gosu-naming-and-packages
purpose: Naming conventions, package rules, _Ext guidance, GosuDoc
scope: naming, packages, _Ext, GosuDoc, deprecated APIs
---

# Gosu Naming Conventions and Package Rules

## Package Rules

- Add new implementation classes to customer package spaces
- Avoid adding new classes to Guidewire package spaces
- Avoid using internal `com.guidewire.*` classes unless no supported alternative exists
- Create subpackages by feature, not by generic function

## Naming Conventions

| Item | Convention |
|------|-----------|
| Classes | UpperCamelCase, singular noun/adjective |
| Methods/functions | lowerCamelCase, verb phrase |
| Properties | UpperCamelCase, noun/adjective; booleans often read as `isX` |
| Constants | ALL_CAPS_WITH_UNDERSCORES |
| Interfaces | UpperCamelCase; do NOT prefix with `I` |
| Implementations | Descriptive name; avoid `Impl`; use `DefaultX` only if no better name |
| Abstract classes | UpperCamelCase, often `AbstractX` |

## `_Ext` Guidance

Use project standards as source of truth, but common training guidance says:

- New fields added to existing entities: `_Ext`
- New custom PCF files: `_Ext`
- Custom elements/variables added to base PCFs: `_Ext`
- New display keys: `_Ext`
- New script parameter values: `_Ext`
- Enhancements on Guidewire entities/classes: `_Ext` for added methods/properties
- New classes in customer package spaces: usually no `_Ext`

## GosuDoc

- Document public/protected classes and functions with GosuDoc/Javadoc-style comments
- Private functions usually do not require GosuDoc
- Generate with:

```text
gwb gosudoc
```

## Deprecated / Internal APIs

If code uses deprecated classes/methods or internal packages, flag for review and verify whether a supported replacement exists.

## Coding Style

- `not`/`and`/`or` keywords preferred over `!`/`&&`/`||`
- `typeis` preferred over `instanceof`
- `?.` safe navigation over explicit null checks
- `?:` elvis over ternary for null defaults
- Named initializers: `new Foo() { :Bar = value }` preferred over chained setters
- Prefer `Count` over `size()`, `Empty` over `isEmpty()`
- Use enhancement methods before creating utility classes
- Avoid raw `dynamic.Dynamic` except for JSON/XML parsing — type everything statically
- Use feature literals (`Entity#Property`) for query comparisons, not string literals
