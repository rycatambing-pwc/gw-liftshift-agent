---
document: gosu-enhancements
purpose: Enhancement syntax, dispatch rules, use cases, and best practices
scope: .gsx files, static dispatch, entity enhancements
---

# Gosu Enhancements

## What Enhancements Are

Enhancements add methods and properties to existing types — including Guidewire-generated entity types, Java types, and types from other modules — without subclassing or modifying the original.

File extension: `.gsx`

```gosu
// File: PolicyEnhancement.gsx
enhancement PolicyEnhancement : entity.Policy {
  property get TotalPremium() : BigDecimal {
    return this.PolicyLines*.TotalPremium.sum()
  }

  function isHighRisk() : boolean {
    return this.TotalPremium > 10000.bd
  }
}
```

## Dispatch Rules

**Enhancements use STATIC dispatch** — the method resolved at compile time based on the declared type, NOT runtime type.

```gosu
// TestA extends PolicyBase; enhancement defined on PolicyBase
var p : PolicyBase = new TestA()
p.enhancementMethod()   // calls PolicyBase enhancement — NOT TestA override
```

This is different from regular method override (virtual dispatch). Always declare the variable at the most specific type when enhancement dispatch matters.

## Enhancement Applicability

- Enhancements apply to all subtypes/subclasses of the enhanced type
- A `Policy` enhancement applies to `BusinessOwnersPolicyLine`, `CommercialPropertyLine`, etc.
- Enhancements can satisfy structural type requirements

## Common Use Cases

1. **Computed properties on entities**: Derive values from entity fields
2. **Aggregation helpers**: Sum, filter, or transform array relationships
3. **Type-safe convenience methods**: Wrap repeated patterns into named operations
4. **Cross-cutting entity behavior**: Add methods to entities without changing their declaration

## Enhancement Lookup Rule

When a method is not found directly on a class, check `.gsx` enhancement files:
- Search for `enhancement SomeTypeEnhancement : TheType` pattern
- Enhancement files often in same package or `extensions/` package
- Entity enhancements frequently in `extensions/entity/`

## Best Practices

- Do NOT place narrow UI-only behavior in entity enhancements
- Enhancement methods should be domain-level behavior, not screen-specific logic
- For PCF/screen support, create a dedicated UI helper class instead
- `_Ext` suffix convention for enhancement-added methods/properties on GW entities:
  ```gosu
  enhancement PolicyEnhancement_Ext : entity.Policy {
    function myCustomMethod_Ext() : String { ... }
  }
  ```

## Enhancement Limitations

- No state (no instance fields) — only methods and properties
- No constructors
- Static dispatch only — cannot override via subtype polymorphism
- Cannot add to `final` types
- Cannot call `super` in enhancements

## Enhancement on Generic Types

```gosu
enhancement ListEnhancement<T> : List<T> {
  function secondElement() : T {
    return this.Count > 1 ? this[1] : null
  }
}
```

Generic parameter `<T>` must be declared before the colon.

## Static Enhancement Methods

```gosu
enhancement PolicyEnhancement : entity.Policy {
  static function createDefault(bundle : Bundle) : Policy {
    var p = new Policy(bundle)
    p.Status = PolicyStatus.TC_DRAFT
    return p
  }
}
```

Static enhancement methods are called as `PolicyEnhancement.createDefault(bundle)` — NOT on an instance.
