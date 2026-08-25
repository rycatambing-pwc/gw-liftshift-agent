# Gosu Blocks and Closures

## Block Syntax

A block (lambda/closure) in Gosu:
```gosu
var add = \x : int, y : int -> x + y
add(2, 3)   // 5

// No params
var greet = \-> print("Hello")

// Multi-statement (curly braces required)
var process = \x : int -> {
  var result = x * 2
  print(result)
  return result
}
```

Block type declarations:
```gosu
var b : block(int, int) : int = \x, y -> x + y
var action : block() = \-> print("hi")
var transform : block(String) : String = \s -> s.toUpperCase()
```

## Blocks as Function Parameters

Blocks are first-class — pass them directly:
```gosu
function applyTwice(f : block(int) : int, x : int) : int {
  return f(f(x))
}
applyTwice(\x -> x + 1, 5)  // 7
```

Common use — filtering and transforming:
```gosu
var evens = numbers.where(\n -> n % 2 == 0)
var names = employees.map(\e -> e.DisplayName)
var total = orders.sum(\o -> o.Amount)
```

## Closures

Blocks close over outer variables — captured by reference:
```gosu
var counter = 0
var increment = \-> { counter++ }
increment()
print(counter)   // 1
```

Outer `var` must be effectively-final to close over (Gosu allows mutation through the closure).

## Reifying Feature Literals as Blocks

Feature literal `.toBlock()` converts a member reference to a block:
```gosu
var nameBlock = emp#Name.toBlock()          // () : String
var updateBlock = emp#update("Ed", 34).toBlock()  // block()
```

Useful for passing property accessors as block arguments to collection methods.

## Exception Handling

```gosu
try {
  riskyOperation()
} catch (e : IllegalArgumentException) {
  handleIllegalArg(e)
} catch (e : Exception) {
  handleGeneral(e)
} finally {
  cleanup()
}
```

- `finally` always executes
- Gosu can catch checked exceptions without declaring them (unlike Java)
- `throw new MyException("message")` to throw

## Using Blocks for Resource Cleanup

`using` block closes `Closeable` automatically (equivalent to Java try-with-resources):
```gosu
using (var stream = new FileInputStream("file.txt")) {
  // stream auto-closed on exit
}

// Multiple resources
using (var a = new ResourceA(), var b = new ResourceB()) {
  // both auto-closed
}
```

`using` with a lock (thread-safe critical section):
```gosu
using (_lock) {
  // synchronized block
}
using (this as IMonitorLock) {
  // equivalent to Java synchronized(this)
}
```

## Anonymous Classes in Blocks

Blocks can implement interfaces with single abstract methods:
```gosu
var comparator = new Comparator<String>() {
  override function compare(a : String, b : String) : int {
    return a.compareTo(b)
  }
}
```

Prefer block syntax over anonymous classes when the interface is a SAM:
```gosu
var comparator : Comparator<String> = \a, b -> a.compareTo(b)
```

## Block Return Types

Block with explicit return type in multi-statement form:
```gosu
var classify : block(int) : String = \n -> {
  if (n < 0) return "negative"
  if (n == 0) return "zero"
  return "positive"
}
```

Last expression is the implicit return in single-expression form.
