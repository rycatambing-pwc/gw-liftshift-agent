---
document: gosu-annotations
purpose: Built-in and custom annotations, meta-annotations, runtime access
scope: @AutoCreate, @AutoInsert, @ShortCircuitingProperty, @SuppressWarnings, custom annotations
---

# Gosu Annotations

## Built-in Guidewire Annotations

### @AutoCreate

Auto-creates the entity on LHS assignment if null — writes through null intermediaries:
```gosu
@AutoCreate
property get Address() : Address { ... }

// Usage: if address is null, auto-created on assignment
policy.Address.City = "Chicago"   // Address auto-created if null
```

Use with caution — creates entities without explicit bundle management.

### @AutoInsert

Auto-inserts an item into an array relationship when assigned:
```gosu
@AutoInsert
property get LineItems() : LineItem[] { ... }

// Any item set through this property auto-added to array
```

### @ShortCircuitingProperty

Property returns `0` or `false` instead of throwing NPE when the object is null:
```gosu
@ShortCircuitingProperty
property get Amount() : BigDecimal { ... }

// null.Amount returns 0.bd instead of NPE
```

Useful for safe arithmetic in contexts where null owner is a valid state.

### @SuppressWarnings

Suppresses specific compiler warnings:
```gosu
@SuppressWarnings("unchecked")
function getList() : List { ... }

@SuppressWarnings("deprecated")
function useLegacyApi() { ... }
```

**NOT supported**: `LOCAL_VARIABLE` target — cannot suppress warnings on local variables.

## Custom Annotation Definition

```gosu
annotation MyAnnotation {
  function purpose() : String           // required element
  function importance() : int = 0       // optional element with default
  function tags() : String[] = {}       // array element with default
}
```

Apply to classes, methods, properties:
```gosu
@MyAnnotation(:purpose = "validation", :importance = 2)
class MyValidator { ... }
```

## Meta-Annotations

Annotations on annotations:

| Meta-annotation | Purpose |
|----------------|---------|
| `@Target` | Restricts where annotation can appear (`TYPE`, `METHOD`, `PROPERTY`, `FIELD`, `PARAMETER`, `ANNOTATION_TYPE`) |
| `@Retention` | Controls visibility: `SOURCE` (discarded), `CLASS` (bytecode), `RUNTIME` (reflection) |
| `@Inherited` | Annotation on class is inherited by subclasses |
| `@Documented` | Include annotation in GosuDoc output |

Example with meta-annotations:
```gosu
@Target({AnnotationUsageType.TYPE, AnnotationUsageType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
annotation MyAnnotation {
  function purpose() : String
}
```

## Runtime Annotation Access

Read annotations via TypeInfo reflection:
```gosu
// On a type
var typeInfo = (typeof obj).TypeInfo
var ann = typeInfo.getAnnotation(MyAnnotation)
if (ann != null) {
  var instance = ann.Instance as MyAnnotation
  print(instance.purpose())
  print(instance.importance())
}

// On a method
var methodInfo = typeInfo.getMethod("myMethod", {})
var methodAnn = methodInfo.getAnnotation(MyAnnotation)

// On a property
var propInfo = typeInfo.getProperty("MyProp")
var propAnn = propInfo.getAnnotation(MyAnnotation)
```

## Annotation Arrays

When annotation has an array element:
```gosu
@MyAnnotation(:purpose = "x", :tags = {"a", "b", "c"})
class Foo { }

// Access:
var ann = (typeof Foo).TypeInfo.getAnnotation(MyAnnotation).Instance as MyAnnotation
for (tag in ann.tags()) {
  print(tag)
}
```

## Common Gosu/Java Annotations in GW Context

```gosu
@Deprecated                 // marks API as deprecated
@Override                   // verifies method overrides a parent method (optional in Gosu)
@Throws(Exception)          // documents thrown exceptions (informational)
@GWPlugin                   // marks a plugin class (GW-specific)
@WsiWebService              // marks a class as a web service endpoint
@WsiReduceDBConnections     // reduces DB connection usage in web services
```
