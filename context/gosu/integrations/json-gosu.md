---
document: gosu-json-integration
purpose: JSON parsing, creation, and structural typing in Gosu
scope: Json class, dynamic.Dynamic, structural types from JSON, @ActualName
---

# JSON Integration in Gosu

## Parsing JSON

```gosu
uses gw.lang.reflect.json.Json

var json = """{"name": "John", "age": 30, "city": "Chicago"}"""
var obj : dynamic.Dynamic = Json.fromJson(json)

print(obj.name)   // "John"
print(obj.age)    // 30
```

## Fetching JSON from URL

```gosu
var url = new java.net.URL("https://api.example.com/data")
var data : dynamic.Dynamic = Json.fromJsonUrl(url)
// or
var data2 : dynamic.Dynamic = url.JsonContent
```

`URL.JsonContent` is a Gosu enhancement shortcut for `Json.fromJsonUrl(url)`.

## Serializing to JSON

```gosu
var obj : dynamic.Dynamic = new gw.lang.reflect.Expando()
obj.Name = "John"
obj.Age = 30

var jsonStr = obj.toJson()    // serialize to JSON string
var xmlStr = obj.toXml()      // serialize to XML string
var gosuStr = obj.toGosu()    // serialize to Gosu initializer code
```

## Structural Types from JSON

Convert JSON schema to a Gosu structural type for compile-time type checking:

```gosu
var json = """{"name": "John", "age": 30}"""
var obj = Json.fromJson(json)
obj.toStructure("PersonType", false)    // false = immutable (read-only)
obj.toStructure("PersonType", true)     // true = mutable (read-write)
```

This generates a `structure PersonType` with typed properties. Use when the JSON shape is known and stable.

## @ActualName Annotation

When JSON property names don't follow Gosu naming conventions (e.g., kebab-case, dots, reserved words):

```gosu
structure PersonType {
  @ActualName("first-name")
  property get FirstName() : String

  @ActualName("$type")
  property get TypeField() : String
}
```

`@ActualName` maps the Gosu property name to the actual JSON key name.

## Dynamic Object Creation

Create JSON-compatible objects with concise named initializer syntax:

```gosu
var person : dynamic.Dynamic = new() {
  :Name = "John Smith",
  :Age = 39,
  :Address = new() {
    :City = "Foster City",
    :State = "CA"
  }
}
var json = person.toJson()
```

## Nested Array Access

```gosu
var data = Json.fromJson("""{"items": [1, 2, 3]}""")
var items = data.items as List<Integer>
for (item in items) {
  print(item)
}
```

## Dynamic Property Dispatch Rules

`dynamic.Dynamic` dispatches property access via:
- `$getProperty(name)` — called for any property get
- `$getMissingProperty(name)` — called when property not found normally
- `$setProperty(name, value)` — property set
- `$setMissingProperty(name, value)` — property set when not found

Return `IPlaceholder.UNHANDLED` to fall through to missing handler.

## Agent checks

When reviewing JSON code:

1. Is `dynamic.Dynamic` typed properly or used raw/untyped throughout?
2. Is `@ActualName` needed for non-camelCase JSON keys?
3. Are null checks needed before accessing dynamic properties?
4. Is `toStructure()` an option for frequently-used stable JSON shapes?
