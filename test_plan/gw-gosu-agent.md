# gw-gosu-agent Test Plan

## Scope

Testing is limited to `gw-gosu-agent` only. Sibling agents (`gw-pcf-agent`,
`gw-entity-agent`, `typelist-agent`, `gw-build-agent`) are out of scope —
this plan tests whether `gw-gosu-agent` correctly performs its own Gosu file
operations and correctly delegates when a change crosses into another
artifact type.

## Parameters

Before running this test plan, populate the following:

| Parameter         | Description                                     | Example              |
| ----------------- | ----------------------------------------------- | -------------------- |
| `<LOB_CODE>`      | Short code of the target LOB                    | `cu`, `pa`, `wc`     |
| `<LOB_NAME>`      | Full name of the target LOB                     | `CommercialUmbrella` |
| `<LOB_DIR>`       | LOB-owned directory under`gsrc/`                | `cust/lob/cu/`       |
| `<LOB_LINE_TYPE>` | Entity type used in`typeis` checks for this LOB | `CommercialUmbLine`  |

## Prerequisites

Before running Part B, perform a fixture scan for the chosen `<LOB_CODE>`
to identify concrete files for each test category. Run the scan prompt,
then fill in the Fixture Registry at the end of this document. Do not run
Part B tests without a completed registry — agent prompts are intentionally
underspecified and the tester needs the registry to verify the agent's work.

## Pass Criterion

`gradle build` succeeds with no errors after the agent's changes.
GUnit results are explicitly excluded as a pass/fail gate.

## Prompt Design Principle

Agent prompts give the agent a goal and a scope, not a file list. The agent
must discover which files to act on, trace references, and decide what to
delete, refactor, or delegate. The tester holds the fixture registry to
verify the agent's work. Do not paste the registry into the agent prompt.

## Delegation Definition

Tests 5, 6, 7, and 9 check that the agent correctly delegates to a sibling
agent. Correct delegation means:

1. The agent identifies the cross-artifact dependency before or during its
   changes — not after a failed build.
2. The agent invokes the sibling agent via the `Task` tool with a clear
   description of what needs to change and why.
3. The agent does not silently skip or delete without flagging the dependency.

A test fails the delegation check if the agent deletes a Gosu file without
mentioning or acting on a known non-Gosu dependency, even if `gradle build`
happens to pass.

## Sandbox Reset Procedure

1. Before each test, restore the sandbox: `git checkout .`
2. Run exactly one test per reset cycle.
3. Record the result, then reset before the next test.

## Test Types

- **CRUD Baseline** — fundamental file operations independent of LOB removal
- **Pure Removal** — delete LOB-owned artifact(s) and clean up references
- **Removal-Driven Refactor** — remove target-LOB logic from a shared file
  while preserving other LOBs' logic
- **Standalone Refactor** — modify Gosu code without a removal driving it

---

# Part A — CRUD Baseline Tests

LOB-independent. Do not require the fixture scan, though they may use
files within `<LOB_DIR>` for convenience.

---

## Test C1 — Create: New `.gs` Class

**Type:** CRUD Baseline
**What it tests:** Agent creates a new Gosu class in a customer package with
correct package declaration, imports, and naming convention.

**Agent prompt:**

```
Create a new Gosu utility class under a customer package in this project.
The class should:
- Be placed in an appropriate customer package (not gw.* or com.guidewire.*)
- Contain a static method that validates whether a given string is
  non-null and non-empty, returning a boolean
- Include proper logging setup
- Follow project naming conventions
```

**Tester checklist:**

- [ ] `gradle build` succeeds
- [ ] File placed under `gsrc/cust/` (not `gw.*` or `com.guidewire.*`)
- [ ] Package declaration matches directory path
- [ ] Uses project-standard logging pattern
- [ ] Syntactically valid Gosu

---

## Test C2 — Create: New `.gsx` Enhancement

**Type:** CRUD Baseline
**What it tests:** Agent creates a new enhancement targeting an existing
entity type, with correct `_Ext` naming and enhancement syntax.

**Agent prompt:**

```
Create a new Gosu enhancement on the Policy entity. The enhancement
should add a read-only property that checks whether the policy's
effective date is within the last 90 days. Place it in an appropriate
customer package and follow project conventions for enhancement naming.
```

**Tester checklist:**

- [ ] `gradle build` succeeds
- [ ] File is a `.gsx` with correct `enhancement ... : Policy` syntax
- [ ] Property name uses `_Ext` suffix
- [ ] Uses null-safe operators for date comparison
- [ ] Placed under a `cust/` package, not `gw.*`
- [ ] No name collision with existing base methods or enhancements

---

## Test C3 — Read: Accuracy Check

**Type:** CRUD Baseline
**What it tests:** Agent reads an existing Gosu file and accurately reports
its structure without fabrication.

**Agent prompt:**

```
Read the file at <path_to_any_gs_file_in_LOB_DIR> and report:
1. All uses/import statements
2. All public and private methods with their full signatures
3. All entity type references
4. All typekey references
Do not modify the file.
```

**Tester checklist (verify against the actual file):**

- [ ] Every reported import exists in the file
- [ ] Every reported method exists with the correct signature
- [ ] No fabricated methods, imports, or references
- [ ] Entity and typekey references are accurate

Note: no build step — correctness check on agent output only.

---

## Test C4 — Update: Method Signature Change with Caller Propagation

**Type:** CRUD Baseline
**What it tests:** Agent modifies a method signature and discovers and
updates all callers on its own.

**Agent prompt:**

```
In <path_to_gs_file_with_known_callers>, pick any public method that
is called by other files. Add a new boolean parameter called
"includeExpired" with a default value of false. Then find and update
every caller of that method across the project so the build still passes.
```

**Tester checklist:**

- [ ] `gradle build` succeeds
- [ ] Agent found the callers on its own (verify against fixture registry)
- [ ] All call sites updated to match the new signature
- [ ] No orphaned calls with the old signature remain
- [ ] Method body logic not otherwise altered

---

## Test C5 — Update: Add Method to Existing `.gsx` Enhancement

**Type:** CRUD Baseline
**What it tests:** Agent adds a new method to an existing enhancement
without disturbing existing code.

**Agent prompt:**

```
In <path_to_gsx_file_in_LOB_DIR>, add a new method that checks whether
the enhanced entity has any coverages in an active state. Follow project
conventions for naming and null safety. Do not modify any existing
methods or properties.
```

**Tester checklist:**

- [ ] `gradle build` succeeds
- [ ] New method uses `_Ext` suffix
- [ ] Existing methods and properties in the file are unchanged
- [ ] Null-safe operators used where appropriate
- [ ] Enhancement syntax remains valid

---

## Test C6 — Uses Statement: Remove Dangling Import

**Type:** CRUD Baseline
**What it tests:** When a class is deleted, the agent finds every file that
imported it via a `uses` statement and removes those now-dangling imports.

**Agent prompt:**

```
The class at <path_to_gs_file> has been deleted. Find every Gosu file
in the project that imports it via a uses statement. Remove those
dangling uses statements. Do not modify anything else in those files.
```

**Tester checklist:**

- [ ] `gradle build` succeeds
- [ ] Agent found all files containing the dangling `uses` (verify against
      fixture registry)
- [ ] All identified `uses` statements removed
- [ ] No other lines in those files modified

---

## Test C7 — Uses Statement: Add Import for a Refactor

**Type:** CRUD Baseline
**What it tests:** When a refactor introduces a dependency on a new class,
the agent adds the correct `uses` import — in the right location, without
duplicating an existing import.

**Agent prompt:**

```
Refactor <path_to_gs_file> to use <target_utility_class> for its
validation logic instead of its current inline implementation. Add
whatever uses statements are needed for the new dependency. Do not
add duplicate imports if the class is already imported.
```

**Tester checklist:**

- [ ] `gradle build` succeeds
- [ ] Correct `uses` statement added for the new dependency
- [ ] Import placed with existing imports, not inline
- [ ] No duplicate imports introduced
- [ ] Refactored logic correctly delegates to the target utility class

---

## Test C8 — Uses + Variables: Remove Import and Dependent Declarations

**Type:** CRUD Baseline
**What it tests:** When a class is removed, the agent cleans up both the
`uses` import and every variable declaration in the file that depended on
that type — the chain: remove import → remove variable declarations.

**Agent prompt:**

```
The class <deleted_class_name> has been removed from the project.
In <path_to_affected_file>, remove the uses statement for that class
and remove any variable declarations whose type was that class. Leave
all other code untouched.
```

**Tester checklist:**

- [ ] `gradle build` succeeds
- [ ] `uses` import for the deleted class removed
- [ ] All variable declarations of that type removed
- [ ] No other code modified beyond import and variable declarations
- [ ] If a removed variable was used further in the method, agent flags
      those usages rather than leaving broken references

---

## Test C9 — Uses + Variables: Full Chain Including All Downstream Usages

**Type:** CRUD Baseline
**What it tests:** The full cleanup chain — the agent removes the import,
variable declarations, and all downstream usages of those variables
(expressions, method calls, return statements).

**Agent prompt:**

```
The class <deleted_class_name> has been removed from the project.
In <path_to_affected_file>, remove the uses statement for that class,
all variable declarations of that type, and all lines that reference
those variables. The file must compile cleanly when you are done.
```

**Tester checklist:**

- [ ] `gradle build` succeeds
- [ ] `uses` import removed
- [ ] Variable declarations of the deleted type removed
- [ ] All expressions, method calls, and return statements that
      referenced those variables removed or refactored
- [ ] No dangling references remain
- [ ] No unrelated code modified

---

## Test C10 — Method Removal: Find All Call Sites and Refactor Dependents

**Type:** CRUD Baseline
**What it tests:** Agent removes a method definition, discovers every call
site across the project, removes those calls, and refactors surrounding
code that depended on the method's return value or side effect.

**Agent prompt:**

```
Remove the method <method_name> from <path_to_gs_file>. Find every
place in the project that calls this method. For each call site, remove
the call and refactor the surrounding code so it still compiles and
behaves correctly without that method. Do not leave any call sites that
reference the removed method.
```

**Tester checklist:**

- [ ] `gradle build` succeeds
- [ ] Method definition removed from the source file
- [ ] Agent discovered all call sites on its own (verify against fixture
      registry)
- [ ] All call sites removed
- [ ] Surrounding code at each call site refactored — return value
      consumers, conditional branches, and assignment targets adjusted
- [ ] No unrelated code modified

---

# Part B — LOB Removal Tests

Requires a completed fixture registry. The agent receives only the LOB
identity and task description — it must discover files and references
independently.

---

## Test 1 — Pure Removal: Owned `.gs` Class

**Type:** Pure Removal
**What it tests:** Given a LOB scope, the agent discovers LOB-owned `.gs`
classes, traces all references across the project, and cleans up everything.

**Agent prompt:**

```
We are removing the <LOB_NAME> (<LOB_CODE>) LOB from this project.
Find and remove <LOB_CODE>-owned helper/utility .gs classes under
<LOB_DIR>. Make sure no references to them remain anywhere in the
project.
```

**Tester checklist:**

- [ ] Agent discovered the correct file(s) (verify against fixture registry)
- [ ] Agent searched for references beyond just `<LOB_DIR>`
- [ ] All `uses` imports and method calls to the deleted class(es) removed
- [ ] `gradle build` succeeds

---

## Test 2 — Pure Removal: Owned `.gr` Rule

**Type:** Pure Removal
**What it tests:** Agent discovers and deletes `.gr` rule files exclusively
owned by the target LOB and updates any rule set registrations.

**Agent prompt:**

```
We are removing the <LOB_NAME> (<LOB_CODE>) LOB from this project.
Find and remove all Gosu rule files (.gr) that belong exclusively to
<LOB_CODE>. For each one, check whether it is registered in a rule set
and clean up the registration.
```

**Tester checklist:**

- [ ] Agent correctly identifies LOB-owned `.gr` files (or reports none
      found — verify against fixture registry)
- [ ] Rule set registrations updated for any deleted rules
- [ ] `gradle build` succeeds

Note: if the fixture registry shows none, this test validates that the
agent correctly reports "no owned .gr files found" rather than fabricating.

---

## Test 2b — Removal-Driven Refactor: Shared `.gr` Rule

**Type:** Removal-Driven Refactor
**What it tests:** Agent discovers shared `.gr` rule files containing
LOB-specific conditional branches, removes only those branches, and
preserves other LOBs' logic.

**Agent prompt:**

```
We are removing the <LOB_NAME> (<LOB_CODE>) LOB from this project.
Check all shared Gosu rule files (.gr) for any conditional logic
specific to <LOB_CODE> — entity type checks, typekey comparisons,
references to <LOB_CODE>-specific classes. Remove the <LOB_CODE>
branches while preserving all other LOBs' logic. Clean up any imports
or helper calls that become unused.
```

**Tester checklist:**

- [ ] Agent correctly identifies shared `.gr` files with LOB branches
      (or reports none found — verify against fixture registry)
- [ ] Target-LOB branches removed; retained-LOB branches unchanged
- [ ] `gradle build` succeeds

---

## Test 3 — Pure Removal: Owned `.gsx` Enhancement

**Type:** Pure Removal
**What it tests:** Agent discovers LOB-owned `.gsx` enhancements, verifies
no external code depends on them, and deletes them. Pre-deletion
verification is the key behavior — the agent must confirm isolation
before deleting, not delete blindly.

**Agent prompt:**

```
We are removing the <LOB_NAME> (<LOB_CODE>) LOB from this project.
Find all .gsx enhancement files owned by <LOB_CODE> under <LOB_DIR>.
For each one, verify whether any code outside <LOB_DIR> calls methods
or properties defined in that enhancement. If no external callers exist,
delete it. If external callers exist, report them instead of deleting.
```

**Tester checklist:**

- [ ] Agent found the correct `.gsx` file(s) on its own (verify against
      fixture registry)
- [ ] Agent verified no external callers before deleting
- [ ] File(s) deleted (only if isolated)
- [ ] `gradle build` succeeds

---

## Test 4 — Removal-Driven Refactor: Shared Mixed-LOB File

**Type:** Removal-Driven Refactor
**What it tests:** Agent discovers shared files referencing the target LOB,
surgically removes only the target-LOB branches, and preserves other LOBs'
logic. Three sub-scenarios to verify:

| Sub | What to verify                                                 |
| --- | -------------------------------------------------------------- |
| 4a  | All`typeis <LOB_LINE_TYPE>` / existence-check blocks removed   |
| 4b  | Any`<LOB_CODE>`-specific typekey comparisons removed           |
| 4c  | Calls to`<LOB_CODE>` helpers removed; orphaned methods flagged |

**Agent prompt:**

```
We are removing the <LOB_NAME> (<LOB_CODE>) LOB from this project.
Search the project for shared Gosu files (outside <LOB_DIR>) that
contain references to <LOB_NAME> — including typeis checks, typekey
comparisons, imports of <LOB_CODE>-specific classes, and method calls
to <LOB_CODE> helpers. For each shared file found, remove all
<LOB_CODE>-specific logic while preserving logic for all other LOBs.
Clean up any imports that become unused after the removal.
```

**Tester checklist:**

- [ ] Agent found the shared file(s) on its own (verify against fixture
      registry)
- [ ] All target-LOB-guarded blocks removed
- [ ] Retained-LOB blocks functionally identical to baseline
- [ ] Target-LOB imports removed; retained-LOB imports present
- [ ] Sub 4c: methods with empty bodies after removal are removed or flagged
- [ ] `gradle build` succeeds

---

## Test 5 — Cross-Artifact Delegation: Gosu-to-PCF Dependency

**Type:** Pure Removal + delegation check
**What it tests:** Agent discovers that a Gosu file it needs to delete has
a PCF dependency and delegates to `gw-pcf-agent` via the `Task` tool —
without being told the PCF dependency exists.

**Agent prompt:**

```
We are removing the <LOB_NAME> (<LOB_CODE>) LOB from this project.
Find and remove all <LOB_CODE>-owned Gosu files under <LOB_DIR> that
serve as helpers or utility classes for the LOB. Before deleting any
file, scan the entire project for references — including PCF files,
entity files, typelists, and build configuration. Handle Gosu references
yourself; delegate non-Gosu references to the appropriate sibling agent.
```

**Tester checklist:**

- [ ] Agent identified the PCF dependency before or during deletion
      (verify against fixture registry)
- [ ] Agent invoked `gw-pcf-agent` via the `Task` tool
- [ ] Agent did NOT silently delete without mentioning the PCF
- [ ] `gradle build` succeeds

**Delegation failure indicators (test FAILS if any occur):**

- Agent deletes the `.gs` file without mentioning the PCF dependency
- Agent mentions the PCF only in text but does not invoke `gw-pcf-agent`
  via `Task`
- Agent tells the tester to manually fix the PCF

---

## Test 6 — Cross-Artifact Delegation: Gosu-to-Typelist Dependency

**Type:** Pure Removal + delegation check
**What it tests:** Agent discovers that removing Gosu files will orphan
typelist typecodes and delegates to `typelist-agent` — without being told
which typekeys are affected.

**Agent prompt:**

```
We are removing the <LOB_NAME> (<LOB_CODE>) LOB from this project.
Find and remove all <LOB_CODE>-owned Gosu files under <LOB_DIR> that
contain typekey references. Before deleting, identify every typekey
used in these files. For each typekey, determine whether it is used
anywhere outside of <LOB_DIR>. If a typekey becomes orphaned after
your deletion, delegate its cleanup to the appropriate sibling agent.
```

**Tester checklist:**

- [ ] Files deleted (verify against fixture registry)
- [ ] Agent identified LOB-exclusive typekeys as orphaned
- [ ] Agent searched outside `<LOB_DIR>` to confirm exclusivity
- [ ] Agent invoked `typelist-agent` via `Task` tool
- [ ] `gradle build` succeeds

**Delegation failure indicators (test FAILS if any occur):**

- Agent deletes files without mentioning typekey orphaning
- Agent mentions orphaned typekeys only in text without invoking
  `typelist-agent` via `Task`
- Agent assumes exclusivity without searching

---

## Test 7 — Cross-Artifact Delegation: Gosu-to-Build/Config Dependency

**Type:** Pure Removal + delegation check
**What it tests:** Agent discovers that a Gosu class is referenced in build
configuration or a plugin registry and delegates to `gw-build-agent`.

**Agent prompt:**

```
We are removing the <LOB_NAME> (<LOB_CODE>) LOB from this project.
Find and remove all <LOB_CODE>-owned Gosu files that are registered as
plugins or referenced in build configuration. Before deleting, scan
build scripts and plugin registries for references. Handle Gosu cleanup
yourself; delegate build/config cleanup to gw-build-agent.
```

**Tester checklist:**

- [ ] Agent identified the build/config reference before deletion
      (verify against fixture registry)
- [ ] Agent invoked `gw-build-agent` via `Task` tool
- [ ] `gradle build` succeeds

Note: if the fixture registry shows none, this test validates that the
agent correctly reports "no build/config references found."

---

## Test 8 — Standalone Refactor: Non-Removal-Driven Change

**Type:** Standalone Refactor
**What it tests:** Agent applies its own Gosu best-practices knowledge to
find and fix an anti-pattern without being told which lines to change.
LOB-independent — select any `.gs` file exhibiting one of these:

- `.where()` / `.firstWhere()` after `.select()` on a large result set
- Unguarded debug logging (missing `DebugEnabled` check)
- Missing null-safe operators on entity relationship chains
- String comparison against a typekey value

**Agent prompt:**

```
Review the file <path_to_file.gs> for Gosu performance anti-patterns
and best-practice violations per Guidewire standards. Fix any issues
you find. Make the minimum changes needed — do not refactor unrelated
code.
```

**Tester checklist:**

- [ ] Agent identified the correct anti-pattern(s) without being told
- [ ] `gradle build` succeeds
- [ ] Targeted anti-pattern corrected
- [ ] No unrelated code modified
- [ ] No new anti-patterns introduced

---

## Test 9 — Removal-Driven Refactor: Method Removal with Call Site Refactor

**Type:** Removal-Driven Refactor
**What it tests:** When a LOB-specific method is removed from a shared file
as part of LOB removal, the agent finds every call site, removes the calls,
and refactors surrounding code that depended on that method's return value
or side effect.

**Agent prompt:**

```
We are removing the <LOB_NAME> (<LOB_CODE>) LOB from this project.
As part of this removal, <LOB_CODE>-specific methods in shared Gosu
files need to be removed. Find any methods in shared files (outside
<LOB_DIR>) that exist solely to serve <LOB_CODE> logic. Remove those
methods and find every call site for each one across the project.
For each call site, remove the call and refactor the surrounding code
so it compiles and behaves correctly without that method.
```

**Tester checklist:**

- [ ] Agent identified the LOB-specific methods in shared files on its
      own (verify against fixture registry)
- [ ] Method definitions removed from shared file(s)
- [ ] Agent discovered all call sites without being told (verify against
      fixture registry)
- [ ] All call sites removed
- [ ] Surrounding code at each call site refactored — return value
      consumers, conditional branches, and assignment targets adjusted
- [ ] `gradle build` succeeds

---

# Summary Tables

## Part A — CRUD Baseline

| #   | Test                                             | What it validates                                           |
| --- | ------------------------------------------------ | ----------------------------------------------------------- |
| C1  | Create`.gs` class                                | Package, naming, imports, syntax                            |
| C2  | Create`.gsx` enhancement                         | Enhancement syntax,`_Ext` naming, entity targeting          |
| C3  | Read accuracy                                    | Correct structure reporting without fabrication             |
| C4  | Update method signature                          | Caller discovery + signature propagation                    |
| C5  | Add method to`.gsx`                              | New method without disturbing existing code                 |
| C6  | Remove dangling`uses` import                     | Finds and removes all`uses` for a deleted class             |
| C7  | Add`uses` import for refactor                    | Adds correct import when refactor introduces new dependency |
| C8  | Remove`uses` + dependent variable declarations   | Import removal + variable declaration cleanup               |
| C9  | Remove`uses` + variables + all downstream usages | Full chain: import + declarations + all references          |
| C10 | Method removal + call site refactor              | Removes method, discovers call sites, refactors dependents  |

## Part B — LOB Removal

| #   | Test                                | What it validates                                     | Discovery required                                          |
| --- | ----------------------------------- | ----------------------------------------------------- | ----------------------------------------------------------- |
| 1   | Owned`.gs` removal                  | File discovery + reference tracing + deletion         | Find owned files, trace all callers                         |
| 2   | Owned`.gr` removal                  | Rule file discovery + rule set cleanup                | Find owned rules (or confirm none)                          |
| 2b  | Shared`.gr` refactor                | LOB branch discovery in shared rules                  | Find shared rules with LOB logic (or confirm none)          |
| 3   | Owned`.gsx` removal                 | External caller verification + deletion               | Find owned enhancements, verify isolation                   |
| 4   | Shared mixed-LOB refactor           | Shared file discovery + surgical branch removal       | Find shared files, identify LOB vs retained branches        |
| 5   | Gosu→PCF delegation                 | PCF dependency discovery +`Task` delegation           | Trace refs into PCF files                                   |
| 6   | Gosu→Typelist delegation            | Orphan typekey discovery +`Task` delegation           | Trace typekeys, verify exclusivity                          |
| 7   | Gosu→Build/Config delegation        | Build-ref discovery +`Task` delegation                | Trace refs into build/config files                          |
| 8   | Standalone Refactor                 | Anti-pattern discovery + targeted correction          | Identify violations in file                                 |
| 9   | Method removal + call site refactor | LOB method removal + downstream call site refactoring | Find LOB-specific methods in shared files, trace call sites |

---

# Fixture Registry

Fill this in after running the fixture scan for the chosen `<LOB_CODE>`.
The tester uses this as the expected-result checklist during test execution.

```
LOB_CODE:       _______________
LOB_NAME:       _______________
LOB_DIR:        _______________
LOB_LINE_TYPE:  _______________
Scan date:      _______________

## Test 1 — Owned .gs class
File:     [path or "none found"]
Callers:  [list of files that reference it, with paths]

## Test 2 — Owned .gr rule
File:     [path or "none found"]
Rule set: [rule set registration path, if applicable]
Reason if none: [why no .gr fixture exists for this LOB]

## Test 2b — Shared .gr with LOB branches
File:     [path or "none found"]
LOB branches (remove):    [pattern descriptions]
Retained branches (keep): [pattern descriptions]
Reason if none: [why no shared .gr fixture exists]

## Test 3 — Owned .gsx enhancement
File:     [path or "none found"]
External callers: [list, or "none — self-declaration only"]

## Test 4 — Shared mixed-LOB file
File:     [path]
LOB patterns to remove:
  - [pattern, e.g. "typeis <LOB_LINE_TYPE>"]
  - [pattern, e.g. "calls to <LOB_CODE>-specific helper"]
Retained-LOB patterns to preserve:
  - [pattern, e.g. "typeis <other_LOB_line_type>"]
Imports to remove: [list]
Imports to retain: [list]

## Test 5 — Gosu-to-PCF dependency
Gosu file: [path]
PCF file:  [path]
Reference: [what the PCF calls/references]

## Test 6 — Gosu-to-Typelist dependency
Gosu file(s): [path(s)]
Typekeys orphaned:
  - [typekey name — confirmed exclusive to <LOB_DIR>]

## Test 7 — Gosu-to-Build/Config dependency
Gosu file: [path or "none found"]
Build ref: [build.gradle line / plugin registry entry]
Reason if none: [why no build/config fixture exists]

## Test C3 — Read accuracy target
File: [path to .gs file]

## Test C4 — Update signature target
File:    [path to .gs file with known callers]
Callers: [list]

## Test C5 — Update enhancement target
File: [path to .gsx file]

## Test C6 — Dangling uses removal target
Deleted class:   [class name]
Files with uses: [list of files that import it]

## Test C7 — Add uses for refactor target
File to refactor: [path]
New dependency:   [class to introduce]
Existing imports: [list — confirm no duplicate added]

## Test C8 — Uses + variable declarations target
Deleted class:         [class name]
Affected file:         [path]
Variable declarations: [names and types to be removed]

## Test C9 — Uses + variables + all usages target
Deleted class:         [class name]
Affected file:         [path]
Variable declarations: [names and types]
Downstream usages:     [expressions, method calls, return statements]

## Test C10 — Method removal + call site refactor target
Source file:            [path to file containing method]
Method:                 [method name + signature]
Call sites:             [list of files + locations]
Return value consumers: [how each call site uses the return value]

## Test 9 — LOB method removal + call site refactor target
Shared file(s):         [path(s) to shared file containing LOB-specific method]
LOB-specific method(s): [method names to remove]
Call sites:             [list of files + locations]
Return value consumers: [how each call site uses the return value]
```
