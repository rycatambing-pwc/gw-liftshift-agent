---
name: gosu-find-usages
description: Finds where a Gosu class, enhancement, rule or template (.gs/.gsx/.gr/.gst) is referenced across Gosu, PCF, entity and product-model files. Use before modifying, renaming or deleting Gosu code, when tracing compile errors caused by a missing or renamed class, or when checking for dead code. Read-only.
---

# Skill: gosu-find-usages

Find where a given Gosu file or element is referenced across the Guidewire codebase. Use
this when you need to understand the impact of a change, locate all callers before
deletion, or trace how a class is used across Gosu source, PCF, entity definitions, and
product model layers.

## When to Activate

- Before modifying or deleting a `.gs`, `.gsx`, `.gr`, or `.gst` file
- When renaming a Gosu class or enhancement method
- When removing a LOB and verifying which shared files reference it
- When investigating compile errors caused by a missing or renamed class
- When checking if a class is dead code (no consumers outside its own directory)

---

## Search Scope

Only search the directories listed below. Do not search `bin/`, `plugins/`,
`configuration_backup/`, or any compiled output tree.

| Artifact Type                | Directory |
|---|---|
| Gosu classes                 | `modules/configuration/gsrc/**/*.gs` |
| Gosu enhancements            | `modules/configuration/gsrc/**/*.gsx` |
| Gosu rules                   | `modules/configuration/config/rules/**/*.gr` |
| Gosu templates               | `modules/configuration/gsrc/**/*.gst` |
| Gosu programs                | `modules/configuration/admin/bin/**/*.gsp` |
| PCF files                    | `modules/configuration/config/web/pcf/**/*.pcf` |
| Customer entity extensions   | `modules/configuration/config/extensions/entity/**/*.eti` `modules/configuration/config/extensions/entity/**/*.etx` |
| Base entity definitions      | `modules/configuration/config/metadata/entity/**/*.eti` |
| Customer typelist extensions | `modules/configuration/config/extensions/typelist/**/*.ttx` |
| Base typelist definitions    | `modules/configuration/config/metadata/typelist/**/*.tti` |
| Product model XML            | `modules/configuration/config/resources/productmodel/**/*.xml` |
| Display name files           | `modules/configuration/config/displaynames/**/*.en` |

### Do Not Search

- `modules/configuration/bin/` — compiled bytecode, not source
- `modules/configuration/plugins/` — IDE-generated class copies
- `modules/configuration_backup/` — backup tree
- `*.eix` — platform-owned internal entity extensions, read-only
- `*.tix` — platform-owned internal typelist extensions, read-only
- `*.gwrules` — binary ZIP packages, not plaintext-greppable

---

## Workflow

Always-run phases execute for every target. Conditional phases run only when the stated
condition is met. **Phase A must always run first.**

---

### Phase routing

Phases are listed in execution order. **Below** means the phase is written out in this file; a link means read that file first, and only when its condition applies. For a rename (Behavioral Rule 11), read all of them.

| Phase | Run when | Where |
|---|---|---|
| A — Entity registration scan | Always, and first | below |
| 1 — Uses / import consumers | Always | below |
| 2 — Type reference consumers | Always | below |
| B — Enhancement method-name scan | The target includes a `.gsx` enhancement file | [enhancement-method-scan.md](references/enhancement-method-scan.md) |
| 3 — Enhancement consumers of this class | The target is a Gosu class or entity type | [class-relationship-phases.md](references/class-relationship-phases.md) |
| 4 — Subclass / interface / delegate consumers | The target is an interface or abstract base class | [class-relationship-phases.md](references/class-relationship-phases.md) |
| 5 — PCF embedded Gosu references | Always | below |
| C — Product model XML script references | `config/resources/productmodel/` exists in the project | [config-string-constant-phases.md](references/config-string-constant-phases.md) |
| D — String literal and pattern code references | The target is a LOB line entity, or a class is renamed or its package moved | [config-string-constant-phases.md](references/config-string-constant-phases.md) |
| E — Shared constant ripple scan | A shared constants class holds a named constant for the target LOB code or class name | [config-string-constant-phases.md](references/config-string-constant-phases.md) |
| 6 — Rule file consumers | Always; report zero results explicitly | below |
| 7 — Template render callers | The target is a `.gst` file | [template-callers.md](references/template-callers.md) |
| F — Typelist orphan check | The target LOB owns typelists | [lob-removal-sweeps.md](references/lob-removal-sweeps.md) |
| G — Display name orphan check | The target LOB owns entity types | [lob-removal-sweeps.md](references/lob-removal-sweeps.md) |
| H — REST API schema references | The target is a LOB entity, typelist, or type used in REST APIs | [lob-removal-sweeps.md](references/lob-removal-sweeps.md) |
| I — Locale properties sweep | The target is a LOB entity, typelist, or class with display keys | [lob-removal-sweeps.md](references/lob-removal-sweeps.md) |
| J — Smoketests and config XML | The target is a LOB entity or typelist | [lob-removal-sweeps.md](references/lob-removal-sweeps.md) |

Each reference file keeps the full steps for its phases, including their own **Run:** condition.

---

### Phase A — Entity Registration Scan

**Run: Always — run this first**

Find `.eti` and `.etx` files that register the target class via `implementsInterface`.

The `impl=` and `iface=` values are plain strings. The Gosu compiler never reads them.
Deleting the `.gs` file produces no compile error — the failure only surfaces at server
startup when the entity framework tries to instantiate the missing class, causing the
entity to fail registration and the server to not boot.

```xml
<implementsInterface
  iface="gw.api.domain.CoverageAdapter"
  impl="ext.lob.<lob>.<TargetClass>"/>
```

- `impl=` — always customer-owned; always check
- `iface=` — usually platform-owned (`gw.*`, `com.guidewire.*`, `java.*`); check only
  when the value is in a customer namespace (`cust.*`, `ext.*`)

```
Search pattern: impl="<TargetClassName>"
               impl="<fully.qualified.ClassName>"
               iface="<cust.*|ext.*ClassName>"
Search scope:   config/extensions/entity/**/*.eti
               config/extensions/entity/**/*.etx
               config/metadata/entity/**/*.eti
```

**What to look for:**

- `impl="<pkg>.<TargetClass>"` in any `<implementsInterface>` element
- `iface="cust.*"` or `iface="ext.*"` pointing to a customer-owned interface

**Example commands:**

```bash
grep -rn 'impl=".*<TargetClass>"' modules/configuration/config/extensions/entity/
grep -rn 'impl="<fully.qualified.package>\.' modules/configuration/config/extensions/entity/
grep -rn 'iface="cust\.' modules/configuration/config/extensions/entity/
grep -rn 'iface="ext\.' modules/configuration/config/extensions/entity/
grep -rn 'iface="cust\.' modules/configuration/config/metadata/entity/
grep -rn 'iface="ext\.' modules/configuration/config/metadata/entity/
```

---

### Phase 1 — Uses / Import Consumers

**Run: Always**

Find all files that import the target class via a `uses` statement.

```
Search pattern: uses <fully.qualified.ClassName>
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
               modules/configuration/gsrc/**/*.gst
               modules/configuration/config/rules/**/*.gr
               modules/configuration/admin/bin/**/*.gsp
```

**What to look for:**

- `uses <pkg>.<TargetClass>` — direct import
- `uses <pkg>.*` — wildcard import that covers the target (flag for manual review)

**Example commands:**

```bash
grep -rn 'uses <fully.qualified.package>\.<TargetClass>' modules/configuration/gsrc/
grep -rn 'uses <fully.qualified.package>\.<TargetClass>' modules/configuration/config/rules/
grep -rn 'uses <fully.qualified.package>\.' modules/configuration/admin/bin/
```

---

### Phase 2 — Type Reference Consumers

**Run: Always**

Find all Gosu files that reference the target as a type.

```
Search pattern: \b<ClassName>\b  (case-sensitive, word-boundary)
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
               modules/configuration/gsrc/**/*.gst
               modules/configuration/admin/bin/**/*.gsp
```

**What to look for:**

- `var x : TargetClass` — variable declaration
- `function foo(param : TargetClass)` — method parameter
- `function bar() : TargetClass` — return type
- `typeis TargetClass` — type guard
- `as TargetClass` — cast
- `List<TargetClass>` — generic type parameter
- `new TargetClass(bundle)` — instantiation
- `TargetClass.staticMethod()` — static call
- `<TargetEntity>Exists` — generated existence check on `PolicyPeriod` for LOB entity types

**Example commands:**

```bash
grep -rn '\b<TargetClass>\b' modules/configuration/gsrc/
grep -rn '\b<TargetClass>\b' modules/configuration/admin/bin/
grep -rn '\b<TargetEntity>Exists\b' modules/configuration/gsrc/
grep -rn 'typeis.*<TargetEntity>' modules/configuration/gsrc/
```

---

### Phase 5 — PCF Embedded Gosu References

**Run: Always**

Find PCF files that call the target class inside Gosu attribute expressions.

```
Search pattern: TargetClass  (bare class name, not XML-escaped)
Search scope:   modules/configuration/config/web/pcf/**/*.pcf
```

**What to look for:**

- `action="<pkg>.<TargetClass>.method(arg)"` — action attribute
- `toRemove="...<TargetClass>.removeItem(entity)"` — toRemove attribute
- `beforeSave="<TargetClass>.validate(period)"` — lifecycle hook
- `beforeCommit="<TargetClass>.validateItem(item)"` — lifecycle hook
- `value="<TargetClass>.computeValue()"` — value expression

**Example commands:**

```bash
grep -rn 'TargetClass' modules/configuration/config/web/pcf/
grep -rn '<fully.qualified.package>\.' modules/configuration/config/web/pcf/
```

---

### Phase 6 — Rule File Consumers

**Run: Always — report zero results explicitly**

Find `.gr` rule files that import or reference the target class. `config/rules/` is a
separate source tree from `gsrc/` and must be checked independently.

```
Search pattern: uses <fully.qualified.ClassName>
               \b<ClassName>\b
Search scope:   modules/configuration/config/rules/**/*.gr
```

**What to look for:**

- `uses <pkg>.<TargetClass>` — import in rule body
- `var x : TargetClass` — variable declaration
- `typeis TargetClass` — type guard
- `as TargetClass` — cast
- `TargetClass.staticMethod()` — static call
- Direct method calls on the target class

**Example commands:**

```bash
grep -rn 'uses <fully.qualified.package>\.' modules/configuration/config/rules/
grep -rn '\b<TargetClass>\b' modules/configuration/config/rules/
```

---

---

## Output Format

```
## Usages of: <TargetClassName>

### Phase A — Entity Registration (.eti/.etx)
- <EntityFile.eti> line <N> — impl="<FQN>"
- <EntityFile.etx> line <N> — iface="<cust.CustomerInterface>"
(or: No .eti registrations found)

### Phase 1 — Uses / Import Consumers
- <File.gs> line <N> — uses <pkg>.<TargetClass>
- <File.gsp> line <N> — uses <pkg>.<TargetClass>
(or: No uses consumers found)

### Phase 2 — Type References
- <File.gs> line <N> — typeis TargetClass
- <File.gst> line <N> — var x : TargetClass
(or: No type references found)

### Phase B — Enhancement Method-Name Callers
- <File.pcf> line <N> — <entity>.<methodName>
- <File.gs> line <N> — <var>.<methodName>()
- <File.gr> line <N> — <entity>.<methodName>()
(or: No enhancement callers found — or: N/A, target has no .gsx)

### Phase 3 — Enhancement Consumers
- <Enhancement.gsx> line <N> — enhancement <Name> : entity.TargetClass
(or: No .gsx consumers found — or: N/A, not a class or entity type)

### Phase 4 — Subclass / Interface / Delegate
- <File.gs> line <N> — extends TargetClass
(or: No subclasses found — or: N/A, not an interface or abstract class)

### Phase 5 — PCF Inline Expressions
- <File.pcf> line <N> — action="...TargetClass.method(...)"
(or: No PCF consumers found)

### Phase C — Product Model XML
- <CoveragePattern.xml> line <N> — InitializeScript referencing TargetClass
(or: No product model references found — or: N/A, productmodel directory not present)

### Phase D — String Literal and Pattern Code References
- <File.gs> line <N> — "<TargetLineName>" in set literal
- <File.gs> line <N> — PatternCode == "<TargetPatternCode>"
(or: No string literal references found — or: N/A, not a LOB line entity or rename)

### Phase E — Shared Constant Ripple
- Constant: <SharedConstantsClass>.<TARGET_CONSTANT_NAME>
  Callers: <File1.gs> line <N>, <File2.gs> line <N>
(or: No named constants found for this target)

### Phase 6 — Rule File Consumers
- No .gr consumers found
(always state result — never skip)

### Phase 7 — Template Render Callers
- N/A — target is not a .gst file
(or: <File.gs> line <N> — TargetTemplate.renderToString(...))

### Phase F — Typelist Orphans
- <TargetTypelist>.tti — no consumers outside <lob-owned-path>/
(or: N/A — or: consumers exist outside LOB; retain typelist)

### Phase G — Display Name Orphans
- <LOBPrefix><EntityName>.en
(or: N/A — or: No .en files found for this LOB prefix)

### Phase H — REST API Schema References
- <schema.json> line <N> — TargetTypeName in schema property
(or: N/A — or: No REST API schema references found)

### Phase I — Locale Properties Sweep
- <properties file> — <N> matching keys found
(or: N/A — or: No locale property references found)

### Phase J — Smoketests and Config XML
- <file> line <N> — <match context>
(or: No smoketest/config references found)

### Impact Summary
- Total consumers: <count>
- Safe to modify: Yes / No  (No if consumers exist outside current change scope)
- Requires coordination: <list of files needing companion changes>
```

---

## Behavioral Rules

1. **Always run Phases A, 1, 2, 5, and 6 — in that order, Phase A first.** Phase A
   catches silent runtime failures that no other phase covers.

2. **Phase A: check both entity source trees and both namespaces** — search
   `config/extensions/entity/` and `config/metadata/entity/`. Check `iface=` for any
   value in `cust.*` or `ext.*` namespaces, not just `gw.*`.

3. **Run Phase B when any `.gsx` is in scope** — callers never reference the enhancement
   class by name. Grep every method and property name individually across `.gs`, `.gsx`,
   `.gst`, `.pcf`, and `.gr`.

4. **Phase 6 must always report its result** — "No `.gr` consumers found" is required
   output. Never omit it.

5. **Use case-sensitive, word-boundary search** — Gosu class names are PascalCase.
   `\bClassName\b` prevents false positives (e.g., `Claim` matching `ClaimContact`).

6. **Check both `gsrc/` and `config/rules/`** — Phases 1 and 2 cover `gsrc/`; Phase 6
   covers `config/rules/` separately.

7. **Do not search `bin/`, `plugins/`, or `configuration_backup/`** — not source.

8. **Do not modify `.eix` or `.tix` files** — platform-owned and read-only.

9. **For Phase B, grep by method name not class name** — the class name never appears at
   call sites.

10. **Document skipped conditional phases** — state why (e.g., "Phase C — N/A: no
    `productmodel/` directory found").

11. **For rename operations, run all phases** — partial coverage leaves broken references.

12. **Read-only** — this skill never modifies any project file.

13. **Large result sets** — if a phase returns more than 200 matches, group by file with
    per-file counts. Show full detail in any saved output file.
