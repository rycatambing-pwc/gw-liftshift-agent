# Gosu Collections

## Collection Creation

Gosu initializer syntax:
```gosu
var list = {1, 2, 3}                          // List<Integer>
var set = new HashSet<String>() {add("a"); add("b")}  // inline init
var map = {"key1" -> "val1", "key2" -> "val2"}  // Map<String,String>
var arr = new int[]{1, 2, 3}                  // primitive array
```

Array literal (creates Java array):
```gosu
var arr = new String[]{"a", "b", "c"}
```

Empty collection:
```gosu
var list : List<String> = {}
var map : Map<String, Integer> = {}
```

## Core Iterable Operations

All Gosu collections and arrays share these block-based operations:

### Filtering
```gosu
collection.where(\item -> condition)      // returns same collection type
collection.whereTypeIs(SubType)           // filter + auto-cast to SubType
```

### Mapping / Transformation
```gosu
collection.map(\item -> item.Property)    // List<T> — all results, including nulls
collection.flatMap(\item -> item.List)    // flattens nested lists
collection.mapToKeyAndValue(\item -> ...)  // transforms to Map
```

### Reduction
```gosu
collection.sum(\item -> item.NumericProp)  // numeric sum
collection.min(\item -> item.NumericProp)  // minimum
collection.max(\item -> item.NumericProp)  // maximum
collection.average(\item -> item.NumericProp)  // average
collection.fold(\acc, item -> combine(acc, item))  // fold/reduce
```

### Searching
```gosu
collection.firstWhere(\item -> condition)     // first match or null
collection.lastWhere(\item -> condition)      // last match or null
collection.hasMatch(\item -> condition)       // boolean — any match
collection.allMatch(\item -> condition)       // boolean — all match
collection.noneMatch(\item -> condition)      // boolean — none match
collection.countWhere(\item -> condition)     // int — count of matches
```

### Sorting
```gosu
collection.sortBy(\item -> item.SortKey)      // ascending
collection.sortByDescending(\item -> item.SortKey)  // descending
collection.orderBy(\item -> key).thenBy(\item -> key2)  // chained sort
```

### Grouping and Partitioning
```gosu
collection.groupBy(\item -> item.Key)          // Map<K, List<T>>
collection.partition(\item -> predicate)       // splits to {true: [...], false: [...]}
```

### Conversion
```gosu
collection.toList()   // converts to List<T>
collection.toSet()    // converts to Set<T>
collection.toTypedArray()  // Java array
collection.join(", ")  // concatenates with separator (String collections)
```

### Array Operators

Gosu arrays support `+=` and `-=`:
```gosu
var arr : String[] = {}
arr += "hello"           // append
arr -= "hello"           // remove first occurrence
```

Spread on arrays:
```gosu
var names = employees*.DisplayName   // List<String> of all display names
```

## Null Handling in Collections

- `where` — nulls filtered out if predicate returns false for null
- `map` — nulls preserved in output if block returns null
- `*.property` spread — null elements become null entries in output

## Maps

```gosu
var map : Map<String, List<Integer>> = {}
map["key"] = {1, 2, 3}               // bracket assignment
map.get("key")                        // safe get (null if missing)
map.getOrDefault("key", {})           // with default
for (entry in map.entrySet()) {
  var key = entry.Key
  var value = entry.Value
}
map.eachKeyAndValue(\k, v -> print("${k}: ${v}"))
```

## Iterator Pattern

Standard for-in loop:
```gosu
for (item in collection) {
  // ...
}
for (item in collection index i) {
  // i = current index
}
```

## Common Pitfalls

- `list.Count` (Gosu) vs `list.size()` (Java) — both work; prefer `Count` in Gosu
- `list.Empty` vs `list.size() == 0` — prefer `Empty` (more readable)
- Arrays returned from entity relationships are typed arrays (`Activity[]`) — same operations apply
- Do not modify a collection while iterating — use `where`/`map` to produce new collections
