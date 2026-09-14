# Integration Rules

These rules govern Gosu code that handles XML, JSON, Gosu templates, and Dynamic/Expando types. Violating them produces encoding errors, runtime parse failures, or silently incorrect behavior. Full background: `/context/gosu/integrations/xml-gosu.md`, `/context/gosu/integrations/json-gosu.md`, `/context/gosu/integrations/templates.md`, `/context/gosu/integrations/dynamic-expando.md`.

## XML: Use `bytes()` in Production — Never `asUTFString()`

`asUTFString()` is a debug helper — it produces a human-readable string representation but is **not** a reliable serialization method for production use. Use `bytes()` to produce the canonical byte-array serialization for any production path (web service payloads, file writes, persistence).

```gosu
// WRONG — debug output only, not suitable for production
var payload = xmlDoc.asUTFString()

// CORRECT
var payload = xmlDoc.bytes()
```

## XML: Use the `$`-Prefixed Properties for XSD-Generated Types

When working with XSD-generated types, element and attribute access uses `$`-prefixed property names (e.g. `$Children`, `$Text`, `$Value`, `$Namespace`, `$QName`). Do not attempt to access these through unadorned property names — the `$` prefix is required and intentional.

## XML: Use `QName` When Namespace Qualification Is Required

When constructing or comparing element names that carry an XML namespace, use `QName` — do not concatenate namespace prefix strings manually.

## JSON: Non-camelCase Keys Require `@ActualName`

When deserializing JSON into a structural type, any key in the JSON that is not in camelCase must be mapped using the `@ActualName` annotation on the corresponding property in the structure. Without it, the deserializer cannot match the key to the property.

```gosu
structure MyResponse {
  @ActualName("policy_number")
  var policyNumber : String
}
```

## JSON: Always Type-Check Dynamic Values Before Use

JSON parsed with `Json.fromJson()` returns `dynamic.Dynamic`. Always use `typeis` before accessing a dynamically typed value as a specific type — untyped access can produce runtime errors or silent null results.

```gosu
var result = Json.fromJson(responseText)
if (result.status typeis String) {
  var status = result.status as String
}
```

## Templates: Declare All Parameters with `<%@ params(...) %>`

Every Gosu template (`.gst`) that accepts inputs must declare them with a `<%@ params(...) %>` directive at the top of the file. Undeclared parameters produce compilation errors when the template is rendered.

## Templates: Split Large Templates Into Sub-Templates

The JVM imposes a 65,535-byte limit per compiled method. A large Gosu template compiles to a single method — exceeding the limit causes a runtime error, not a compile-time warning. If a template is large (extensive loops, many conditionals, long static text blocks), split it into sub-templates and include them via `render()` calls.

## Dynamic/Expando: Method Values Must Be Blocks

When assigning a method to an Expando object's property for later invocation, the value must be a **block**, not a direct method reference or a plain function call.

```gosu
// WRONG — assigns the result of calling the method, not the method itself
myExpando.process = computeSomething()

// CORRECT — assigns a block that will be invoked later
myExpando.process = \ -> computeSomething()
```

Accessing an uninitialized Expando property returns `null`, not an error — always null-check dynamic property access when the value may not have been set.

## Dynamic/Expando: Avoid Raw `dynamic.Dynamic` in Production Code

Prefer structural types (`toStructure()`) over raw `dynamic.Dynamic` wherever the JSON/XML schema is known at compile time. Structural types provide compile-time checking and refactoring support; raw Dynamic provides neither. Reserve Dynamic for genuinely schema-unknown situations.
