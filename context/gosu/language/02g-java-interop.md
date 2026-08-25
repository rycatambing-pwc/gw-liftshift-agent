# Gosu Java Interoperability

## Property Convention Mapping

Gosu automatically maps Java getters/setters to properties:

| Java method | Gosu property |
|-------------|---------------|
| `getName()` | `.Name` |
| `setName(v)` | `.Name = v` |
| `isActive()` | `.Active` (boolean) |
| `hasItems()` | `.Items` (boolean) — no `has` prefix stripping |

Rules:
- `get` prefix + capital letter → property (prefix stripped)
- `set` prefix + capital letter → setter (prefix stripped)
- `is` prefix + capital letter → boolean property (prefix stripped)

## Ambiguity: Property vs Method

When a Java class has both `getName()` and a plain `name` field (after stripping), Gosu applies a disambiguation rule:
- **Java-defined getter**: accessible as property (`.Name`)
- **Plain method** that looks like getter: accessible as method (`.getName()`)
- **Both defined**: Gosu picks the property convention — use explicit method call if needed

```gosu
// Java class has getName() and name field
obj.Name        // uses getName() getter
obj.getName()   // explicit method call — same result but verbose
```

## Static Member Imports

```gosu
uses java.lang.Math#*          // import all static members
uses java.lang.Math#PI         // import single static field
uses java.lang.Math#abs        // import single static method
```

After import, use without qualification:
```gosu
var pi = PI          // java.lang.Math.PI
var result = abs(-5) // java.lang.Math.abs(-5)
```

## Generics and Type Reification

Gosu reifies generics at runtime — unlike Java type erasure:
```gosu
var list : List<Integer> = new ArrayList<Integer>()
print(typeof list)   // java.util.ArrayList<java.lang.Integer> — full type retained
```

When calling Java generic methods from Gosu:
```gosu
// Java: <T> T getValue(Class<T> type)
var str = getValueJava(String)   // Gosu passes String.class automatically
```

Gosu wraps Java generic types to preserve parameter info. This means:
- `instanceof` checks with generic types work in Gosu (not in Java)
- Type tokens (`Class<T>`) can be passed using `Type<T>` in Gosu

## Java Checked Exceptions

Gosu does NOT require declaring or catching checked exceptions:
```gosu
// Java method throws IOException — no try/catch required in Gosu unless desired
var content = Files.readString(Path.of("file.txt"))
```

Still best practice to catch and handle when recovery is possible.

## Java Null Handling

Gosu's `?.` safe navigation works with Java objects:
```gosu
var city = javaObj?.getAddress()?.getCity()   // safe call chain
```

Java methods returning null integrate with Gosu's null-safety operators.

## Calling Gosu from Java

Gosu classes compile to JVM bytecode — callable from Java:
- Properties become getter/setter methods in bytecode
- Blocks become `gw.internal.gosu.parser.GosuCallableBlock` instances
- Gosu enums map to Java enums

## Type Tokens

Java `Class<T>` maps to Gosu `Type<T>`:
```gosu
function makeInstance<T>(t : Type<T>) : T {
  return t.TypeInfo.getConstructor(null).Constructor.newInstance(null) as T
}
makeInstance(MyClass)   // passes MyClass.Type implicitly
```

## Java Array Interop

Gosu arrays and Java arrays are interchangeable:
```gosu
var javaArr : String[] = new String[]{"a", "b"}   // Java-style array
var gosuArr = {"a", "b"}                           // Gosu List — NOT Java array
```

Pass `String[]` (not `List<String>`) when Java method signature requires array:
```gosu
javaMethod({"a", "b"} as String[])   // explicit cast to Java array
```

## Common Java Classes in Gosu Context

```gosu
uses java.util.Arrays
uses java.util.Collections
uses java.io.File
uses java.net.URL
```

`URL` has extra Gosu enhancements:
```gosu
var text = new URL("http://...").TextContent   // GET and return as String
var json = new URL("http://...").JsonContent   // GET and parse as Dynamic
```

## Overriding Java Methods

Standard override with `override` keyword:
```gosu
class GosuImpl extends JavaBase {
  override function javaMethod() : String {
    return "gosu result"
  }
}
```

`@Override` annotation is optional in Gosu (unlike Java where it's recommended).
