---
document: system-health-profiler-dbcc-and-inspections
purpose: Optional module for performance/static-analysis/health scan tasks
scope: Profiler, DB schema validation, DBCC, inspections, concurrency, lazy vars, caches
---

# System Health, Profiler, DBCC, Inspections, and Concurrency

## Guidewire Profiler

Use for investigating performance issues and outages.

Key concepts:

- Web profiler captures current user session and may need download to persist.
- Entry point profiler captures components being measured and may persist to DB.
- Only instrumented code surrounded by profiler tags is profiled.
- A stack is a collection of frames.
- Profiler tags block out meaningful sections of code.

```gosu
var frame = Profiler.push(myTag)
try {
  // profiled work
} finally {
  Profiler.pop(frame)
}
```

Verify exact API syntax in target version.

## DB schema validation

Schema validation detects differences between database configuration and actual schema. Run before/after database upgrades and during development when metadata changes.

- [ ] Inspections

Inspections perform static analysis and detect anti-patterns. They can run:

- automatically in the editor/background
- manually from Studio Analyze menu
- via build/Gradle task such as `gwb inspect`
- before pull requests/builds

Use this module only for code-quality/static-analysis tasks.

## Concurrency and Thread Safety

### LockingLazyVar — Thread-Safe Lazy Initialization

```gosu
private static var _instance = LockingLazyVar.make(\-> new MyExpensiveObject())

// Access triggers initialization on first call, thread-safe
var obj = _instance.get()
```

- Thread-safe — uses a lock to ensure only one thread initializes
- Use for shared class-level objects that are expensive to create
- Prefer over `static var _obj : Type` with null check (not thread-safe)

### LocklessLazyVar — Non-Thread-Safe Lazy Initialization

```gosu
private var _cache = LocklessLazyVar.make(\-> computeExpensiveValue())
```

- NOT thread-safe — use only for single-threaded contexts or when initialization is idempotent
- Faster than `LockingLazyVar` (no lock overhead)

### Cache — Concurrent LRU Cache

```gosu
private static var _rateCache = new Cache<String, BigDecimal>("RateCache", 500, \key -> computeRate(key))
```

Constructor: `new Cache<KeyType, ValueType>("cacheName", maxSize, \key -> computeValue(key))`

- Thread-safe concurrent LRU cache
- Value is computed via the block on first access for each key
- Bounded size (evicts LRU entries)
- Use for expensive computations keyed on stable inputs

### RequestVar — Per-HTTP-Request Scoped Variable

```gosu
uses gw.api.web.RequestVar

private static var _currentContext = new RequestVar<MyContext>(\-> new MyContext())

// Inside request handling:
if (RequestVar.RequestAvailable) {
  var ctx = _currentContext.get()
}
```

- Scoped to current HTTP request — cleared automatically after request ends
- Check `RequestVar.RequestAvailable` before accessing outside request scope
- Use for caching per-request computed values

### SessionVar — Per-HTTP-Session Scoped Variable

```gosu
uses gw.api.web.SessionVar

private static var _userPrefs = new SessionVar<UserPreferences>(\-> new UserPreferences())

if (SessionVar.RequestAvailable) {
  var prefs = _userPrefs.get()
}
```

- Scoped to current HTTP session (survives multiple requests)
- Check `RequestAvailable` before accessing outside session scope
- Use for user-level session state

### ThreadLocal — DISCOURAGED

`java.lang.ThreadLocal` is discouraged in Guidewire context — Guidewire may reuse threads in ways that cause ThreadLocal values to leak across requests, causing hard-to-debug state contamination.

Prefer `RequestVar` or `SessionVar` for per-request/session state.

### Explicit Locking

```gosu
uses java.util.concurrent.locks.ReentrantLock

private var _lock = new ReentrantLock()

using (_lock) {
  // thread-safe critical section
}

// Equivalent to Java synchronized(this):
using (this as IMonitorLock) {
  // synchronized block
}
```
