# LOB Removal Work Log Format Specification

## Overview

The work log serves two purposes:

1. **Execution log** — chronological record of every action taken during LOB removal, with timestamps and outcomes.
2. **Fallout log** — categorized inventory of what was removed, added, and modified so a developer can audit the full impact of the removal and roll back selectively if needed.

## File Location and Naming

```
.pwc/agent/work-logs/lob-removal-<LOB_CODE>-<YYYYMMDD>-<HHmmss>.md
```

Example: `.pwc/agent/work-logs/lob-removal-BP7-20260908-143022.md`

If the same LOB removal is resumed after a failure, the agent appends to the existing log file rather than creating a new one. A `[RESUMED]` marker is inserted at the resumption point.

---

## Log Structure

The log file is divided into four sections:

| Section | Purpose |
|---------|---------|
| **Header** | Run metadata — LOB code, alternate names, project root, start time, agent versions |
| **Phase Log** | Chronological entries grouped by phase, each action tagged by category |
| **Fallout Summary** | Aggregated lists of all removed, added, and modified files |
| **Run Result** | Final status, total counts, duration, and unresolved issues |

---

## Section 1: Header

```markdown
# LOB Removal Work Log

| Field            | Value                                      |
|------------------|--------------------------------------------|
| LOB Code         | BP7                                        |
| Alternate Names  | Business Owners Policy                     |
| Project Root     | C:\dev\policycenter                        |
| Run Started      | 2026-09-08T14:30:22Z                       |
| Run Completed    | 2026-09-08T16:45:10Z                       |
| Run Status       | COMPLETED | FAILED | PARTIAL | IN_PROGRESS  |
| Plan File        | .pwc/agent/plans/lob-removal-BP7.md        |
| Initiated By     | user                                       |
```

---

## Section 2: Phase Log

Each phase is a second-level heading. Within a phase, each action is a table row tagged with an **action category** and an **outcome**.

### Action Categories

| Tag        | Meaning |
|------------|---------|
| `REMOVED`  | A file, folder, property, entity entry, or code block was deleted |
| `ADDED`    | A new file was created (e.g., a plan file, a patched config) |
| `MODIFIED` | An existing file was edited (e.g., removing LOB references from a shared file) |
| `EXECUTED` | A build tool command was run (e.g., `gwb compile`) |
| `VERIFIED` | An exit criterion was checked |
| `SKIPPED`  | An expected artifact was not found — nothing to act on |
| `QUERY`    | A question was asked to the user |
| `ERROR`    | An action failed; includes error detail |

### Outcome Values

| Outcome     | Meaning |
|-------------|---------|
| `OK`        | Action completed successfully |
| `FAIL`      | Action failed — see the detail column |
| `WARN`      | Action completed with a non-blocking warning |
| `PENDING`   | Action awaiting user confirmation or deferred |
| `N/A`       | Not applicable (used for `QUERY` entries) |

### Phase Entry Format

```markdown
## Phase <N>: <Phase Title>

| # | Timestamp            | Category   | Outcome | Target                                                        | Detail                                          | Agent            |
|---|----------------------|------------|---------|---------------------------------------------------------------|--------------------------------------------------|------------------|
| 1 | 2026-09-08T14:31:05Z | EXECUTED   | OK      | `gwb clean`                                                   | Exit code 0, 12s                                 | main             |
| 2 | 2026-09-08T14:31:18Z | EXECUTED   | OK      | `gwb compile`                                                 | Exit code 0, 48s                                 | main             |
| 3 | 2026-09-08T14:32:06Z | EXECUTED   | OK      | `gwb runServer`                                               | Server started on port 8180, 38s                 | main             |
| 4 | 2026-09-08T14:32:44Z | VERIFIED   | OK      | Exit criteria: baseline established                           | All 3 build commands succeeded                   | main             |
| 5 | 2026-09-08T14:32:45Z | QUERY      | N/A     | User confirmation to proceed                                  | User approved                                    | main             |

### Exit Criteria Results
- [x] `gwb clean` completed successfully
- [x] `gwb compile` completed successfully
- [x] `gwb runServer` completed successfully
```

### Examples by Category

**REMOVED — file deletion:**
```
| 12 | 2026-09-08T14:35:22Z | REMOVED | OK | `configuration/config/web/pcf/line/BP7/` | Folder deleted, 47 files | gw-pcf-agent |
```

**REMOVED — property removal from a shared file:**
```
| 18 | 2026-09-08T15:10:03Z | MODIFIED | OK | `configuration/config/locale/display.properties` | Removed 214 properties matching `*.BP7.*` | main |
```

**ADDED — generated plan or patch file:**
```
| 6 | 2026-09-08T15:22:01Z | ADDED | OK | `.pwc/agent/plans/compile-fix-BP7-phase12.md` | Fix plan for 3 compile errors | gw-gosu-agent |
```

**SKIPPED — artifact not found:**
```
| 9 | 2026-09-08T14:55:11Z | SKIPPED | OK | `configuration/gsrc/gw/webservice/pc/pc910/ccintegration/lob/CCBP7*` | No matching file found | gw-gosu-agent |
```

**ERROR — build failure:**
```
| 22 | 2026-09-08T15:30:45Z | EXECUTED | FAIL | `gwb compile` | Exit code 1, 3 errors — see detail below | gw-gosu-agent |
```

When an `ERROR` entry needs extended detail (stack traces, multi-line output), append a fenced block immediately after the phase table:

```markdown
<details>
<summary>Error detail for entry #22</summary>

` ` `
gsrc/gw/lob/common/LobPropertyServices.gs:42: error: cannot resolve symbol 'BP7Line'
gsrc/cust/lob/common/validation/PolicyPeriodValidation_Ext.gs:18: error: unknown type 'BP7Jurisdiction'
` ` `
</details>
```

### Resumed Run Marker

When a log is reopened after a prior failure:

```markdown
---
### [RESUMED] 2026-09-08T16:00:00Z — Resuming from Phase 4 after compile failure fix
---
```

---

## Section 3: Fallout Summary

This section aggregates all impacted files across every phase, grouped by action category. It is the developer's audit trail.

```markdown
# Fallout Summary

## Files Removed

| # | File / Folder                                                              | Phase | Detail                        |
|---|----------------------------------------------------------------------------|-------|-------------------------------|
| 1 | `configuration/config/web/pcf/line/BP7/`                                  | 2     | Folder, 47 files              |
| 2 | `configuration/config/productmodel/policylinepatterns/BP7Line/`            | 2     | Folder, 12 files              |
| 3 | `configuration/config/web/pcf/line/BP7ManuscriptEndorsementPopup.pcf`      | 2     | PCF file                      |
| 4 | `configuration/gsrc/gw/lob/bp7/`                                          | 3     | Folder, 23 files              |
| … | …                                                                         | …     | …                             |

**Total removed: 38 files/folders**

## Files Modified

| # | File                                                                       | Phase | What Changed                                |
|---|----------------------------------------------------------------------------|-------|---------------------------------------------|
| 1 | `configuration/config/locale/display.properties`                           | 6     | Removed 214 properties matching `*.BP7.*`   |
| 2 | `gsrc/cust/lob/common/LobCommonAdditionalInsuredHelperFactory.gs`          | 4     | Removed BP7 uses, variables, and references  |
| 3 | `configuration/config/extensions/typelist/PolicyLine.ttx`                  | 10    | Removed BP7 typecode entry                  |
| … | …                                                                         | …     | …                                           |

**Total modified: 12 files**

## Files Added

| # | File                                                                       | Phase | Purpose                                     |
|---|----------------------------------------------------------------------------|-------|---------------------------------------------|
| 1 | `.pwc/agent/plans/lob-removal-BP7.md`                                      | 0     | Removal plan                                |
| 2 | `.pwc/agent/plans/compile-fix-BP7-phase12.md`                              | 12    | Compile error fix plan                      |

**Total added: 2 files**

## Errors Encountered

| # | Phase | Target                           | Error Summary                             | Resolution            | Status               |
|---|-------|----------------------------------|-------------------------------------------|-----------------------|----------------------|
| 1 | 12    | `gwb compile`                    | 3 compile errors — unresolved BP7 symbols | Fixed by gosu-agent   | RESOLVED 2026-09-08  |

**Total errors: 1 (1 resolved, 0 open)**
```

**Fallout ledger rules**
- Rows are never deleted or rewritten. When an error is fixed, change its Status from `OPEN` to `RESOLVED <date>` and keep the row, so the history stays readable.
- Status is `OPEN` or `RESOLVED <date>`. Any row still `OPEN` at the end of the run must be explained in the Run Result.

---

## Section 4: Run Result

```markdown
# Run Result

| Metric               | Value                      |
|----------------------|----------------------------|
| Status               | COMPLETED                  |
| Duration             | 2h 14m 48s                 |
| Phases Completed     | 13 / 13                    |
| Files Removed        | 38                         |
| Files Modified       | 12                         |
| Files Added          | 2                          |
| Errors Encountered   | 1                          |
| Errors Resolved      | 1                          |
| Errors Unresolved    | 0                          |
| User Queries         | 5                          |
| Lessons Referenced   | 0                          |

**Accepted leftovers:** none
<!-- or one line per item: `path` — what still matches a removal code — why the user agreed to keep it -->
```

`Errors Unresolved` must equal the number of `OPEN` rows in the fallout ledger. Anything that still matches a removal code at the end of the run, and that the user agreed to keep, is listed under **Accepted leftovers**; nothing else may remain. The evaluation (`evaluation.md`) reads this list.

---

## Agent Logging Rules

1. **Every action gets a row.** No silent deletions or edits. If a file is touched, it appears in the phase log.
2. **Timestamps are UTC ISO 8601.** Example: `2026-09-08T14:30:22Z`.
3. **Fallout summary is built incrementally.** Each agent appends to the summary tables as it completes actions. The summary is not reconstructed at the end — it grows with the log.
4. **Errors include enough context to reproduce.** At minimum: the command or file, the error message, and the exit code if applicable.
5. **SKIPPED entries are mandatory.** If an expected file or folder does not exist, log it as `SKIPPED` rather than silently moving on. This lets the developer verify that nothing was missed due to a naming mismatch.
6. **User queries and responses are logged.** When a `QUERY` entry is recorded, the `Detail` column captures the user's response.
7. **Phase boundaries are explicit.** Each phase heading includes the start timestamp. The exit criteria checklist closes the phase.
8. **One log per LOB removal run.** Resumed runs append to the same file with a `[RESUMED]` marker.
