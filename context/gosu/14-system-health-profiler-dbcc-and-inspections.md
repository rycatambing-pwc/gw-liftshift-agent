---
document: system-health-profiler-dbcc-and-inspections
purpose: Optional module for performance/static-analysis/health scan tasks
scope: Profiler, DB schema validation, DBCC, inspections
---

# System Health, Profiler, DBCC, and Inspections

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

## DBCC

Database consistency checks identify data issues after they occur. They do not automatically fix data. Results are written to the database and can often be downloaded.

Agent note: DBCC material is operational context, not primary Gosu syntax guidance.

## Inspections

Inspections perform static analysis and detect anti-patterns. They can run:

- automatically in the editor/background
- manually from Studio Analyze menu
- via build/Gradle task such as `gwb inspect`
- before pull requests/builds

Use this module only for code-quality/static-analysis tasks.
