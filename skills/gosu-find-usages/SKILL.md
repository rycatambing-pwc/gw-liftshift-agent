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

| Artifact Type | Directory |
|---|---|
| Gosu classes | `modules/configuration/gsrc/**/*.gs` |
| Gosu enhancements | `modules/configuration/gsrc/**/*.gsx` |
| Gosu rules | `modules/configuration/config/rules/**/*.gr` |
| Gosu templates | `modules/configuration/gsrc/**/*.gst` |
| Gosu programs | `modules/configuration/admin/bin/**/*.gsp` |
| PCF files | `modules/configuration/config/web/pcf/**/*.pcf` |
| Customer entity extensions | `modules/configuration/config/extensions/entity/**/*.eti` `modules/configuration/config/extensions/entity/**/*.etx` |
| Base entity definitions | `modules/configuration/config/metadata/entity/**/*.eti` |
| Customer typelist extensions | `modules/configuration/config/extensions/typelist/**/*.ttx` |
| Base typelist definitions | `modules/configuration/config/metadata/typelist/**/*.tti` |
| Product model XML | `modules/configuration/config/resources/productmodel/**/*.xml` |
| Display name files | `modules/configuration/config/displaynames/**/*.en` |

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
condition is met.

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
grep -rn 'iface="cust\.' modules/configuration/config/metadata/entity/
```

---

### Phase 1 — Uses / Import Consumers

**Run: Always**

Find all files that import the target class via a `uses` statement.

```
Search pattern: uses <fully.qualified.ClassName>
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
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
grep -rn '\b<TargetEntity>Exists\b' modules/configuration/gsrc/
grep -rn 'typeis.*<TargetEntity>' modules/configuration/gsrc/
```

---

### Phase B — Enhancement Method-Name Scan

**Run: When target includes a `.gsx` enhancement file**

Enhancement methods and properties are called directly on entity variables. Callers never
import or reference the enhancement class by name — searching for the class name finds
nothing. Every `function` and `property get`/`set` in the `.gsx` must be grepped
individually.

```
Search pattern: \b<methodOrPropertyName>\b  (one grep per member)
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
               modules/configuration/gsrc/**/*.gst
               modules/configuration/config/web/pcf/**/*.pcf
               modules/configuration/config/rules/**/*.gr
```

**Steps:**
1. Open the target `.gsx` and list every `function` and `property get`/`set` name.
2. Grep each name individually across all scope directories above.
3. Exclude the `.gsx` file itself — its own declaration is not a caller.

**What to look for:**
- `entity.<enhancedPropertyName>` — PCF or Gosu accessing an enhancement property
- `variable.<enhancedMethodName>()` — Gosu calling an enhancement method
- Any hit outside the owning file's directory

**Example commands:**
```bash
grep -rn '\b<enhancedPropertyName>\b' modules/configuration/gsrc/
grep -rn '\b<enhancedPropertyName>\b' modules/configuration/config/web/pcf/
grep -rn '\b<enhancedPropertyName>\b' modules/configuration/config/rules/
grep -rn '\b<enhancedMethodName>\b' modules/configuration/gsrc/
```

**Note:** Enhancement dispatch is static — the declared type of the variable determines
which enhancement fires, not the runtime type. Flag any caller where the variable is
declared at a base type rather than the exact enhanced type.

---

### Phase 3 — Enhancement Consumers of This Class

**Run: When target is a Gosu class or entity type**

Find `.gsx` files that enhance the target type. If the target is removed, these
enhancement headers fail to compile.

```
Search pattern: enhancement \w+ : (entity\.)?<ClassName>
Search scope:   modules/configuration/gsrc/**/*.gsx
```

**What to look for:**
- `enhancement MyEnhancement_Ext : entity.TargetEntity`
- `enhancement MyEnhancement : pkg.TargetClass`

**Example commands:**
```bash
grep -rn 'enhancement.*:\s*entity\.<TargetEntity>' modules/configuration/gsrc/
grep -rn 'enhancement.*:\s*<pkg>\.<TargetClass>' modules/configuration/gsrc/
```

---

### Phase 4 — Subclass / Interface / Delegate Consumers

**Run: When target is an interface or abstract base class**

Find classes that extend, implement, or delegate to the target.

```
Search pattern: extends <ClassName>
               implements <ClassName>
               delegate \w+ : <ClassName>
Search scope:   modules/configuration/gsrc/**/*.gs
```

**What to look for:**
- `class MyImpl extends TargetBase`
- `class MyImpl implements TargetInterface`
- `delegate _impl : TargetInterface = new TargetImpl()`

**Example commands:**
```bash
grep -rn 'extends\s\+<TargetBaseClass>' modules/configuration/gsrc/
grep -rn 'implements.*<TargetInterface>' modules/configuration/gsrc/
grep -rn 'delegate.*:\s*<TargetInterface>' modules/configuration/gsrc/
```

---

### Phase 5 — PCF Embedded Gosu References

**Run: Always**

Find PCF files that call the target class inside Gosu attribute expressions.

```
Search pattern: <ClassName>
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
grep -rn '<TargetClass>' modules/configuration/config/web/pcf/
grep -rn '<fully.qualified.package>\.' modules/configuration/config/web/pcf/
```

---

### Phase C — Product Model XML Script References

**Run: When `config/resources/productmodel/` exists in the project**

Find coverage pattern XML files that call the target class in `<InitializeScript>` or
`<AvailabilityScript>` elements. These scripts are not build-validated — a missing class
only fails at runtime when the product model engine loads the coverage pattern.

```
Search pattern: <TargetClassName>  inside InitializeScript or AvailabilityScript
Search scope:   modules/configuration/config/resources/productmodel/**/*.xml
```

**What to look for:**
- `<InitializeScript>TargetClass.method(coverable)</InitializeScript>`
- `<AvailabilityScript>TargetClass.isAvailable(line)</AvailabilityScript>`

**Example commands:**
```bash
grep -rn '<TargetClass>' modules/configuration/config/resources/productmodel/
grep -rn 'InitializeScript\|AvailabilityScript' \
  modules/configuration/config/resources/productmodel/policylinepatterns/
```

---

### Phase D — String Literal and Pattern Code References

**Run: When target is a LOB line entity, or when a class is being renamed or its package moved**

Find references to the target as a string literal. These produce no compile error when
stale.

```
Search pattern: "<LineName>"
               "<ProductCode>"
               PatternCode == "<CoveragePatternCode>"
               \.Code == "<TypecodeString>"
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
```

**What to look for:**
- `Set.of("<OtherLine>", "<TargetLineName>")` — set literal
- `"<TargetLineName>" -> "<lobCode>"` — map entry
- `.compare(Policy#ProductCode, Equals, "<TargetProductCode>")` — query filter
- `PolicyLinePattern.PublicID == "<TargetLineName>"` — string comparison
- `elt.PatternCode == "<TargetCoveragePatternCode>"` — coverage pattern code
- `term.PatternCode == "<TargetCostLayerPatternCode>"` — cost layer pattern code

**Example commands:**
```bash
grep -rn '"<TargetLineName>"' modules/configuration/gsrc/
grep -rn '"<TargetProductCode>"' modules/configuration/gsrc/
grep -rn 'PatternCode.*==.*"<TargetPatternPrefix>' modules/configuration/gsrc/
grep -rn '\.Code\s*==\s*"' modules/configuration/gsrc/
```

---

### Phase E — Shared Constant Ripple Scan

**Run: When a shared constants class holds a named constant for the target LOB code or class name**

Every caller of a named constant produces a compile error if that constant is removed.

```
Search pattern: <ConstantsClass>\.<CONSTANT_NAME>
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
```

**Steps:**
1. Grep the shared constants class for constants whose value contains the target line name
   or product code.
2. For each constant found, grep all callers by that constant's field name.
3. List every caller as a file requiring a companion edit.

**Example commands:**
```bash
grep -n '"<TargetLineName>\|<TargetProductCode>"' modules/configuration/gsrc/<path/to/SharedConstants>.gs
grep -rn '<SharedConstantsClass>\.<TARGET_CONSTANT_NAME>' modules/configuration/gsrc/
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
- Direct type references or method calls on the target class

**Example commands:**
```bash
grep -rn 'uses <fully.qualified.package>\.' modules/configuration/config/rules/
grep -rn '\b<TargetClass>\b' modules/configuration/config/rules/
```

---

### Phase 7 — Template Render Callers

**Run: When target is a `.gst` file**

Find callers of `renderToString()` or `render()` on the target template.

```
Search pattern: <TemplateName>\.renderToString(
               <TemplateName>\.render(
Search scope:   modules/configuration/gsrc/**/*.gs
               modules/configuration/gsrc/**/*.gsx
```

**Example commands:**
```bash
grep -rn '\b<TargetTemplateName>\.renderToString(' modules/configuration/gsrc/
grep -rn '\b<TargetTemplateName>\.render(' modules/configuration/gsrc/
```

---

### Phase F — Typelist Orphan Check

**Run: When the target LOB owns typelists with no consumers outside its own files**

Verify no consumers exist outside the LOB-owned directories.

```
Pattern:       typekey\.<TypelistName>\.TC_\w+
               \b<TypelistName>\b
Search scope:  modules/configuration/gsrc/**  (outside lob-owned path)
               modules/configuration/config/web/pcf/**/*.pcf
```

**Example commands:**
```bash
grep -rn 'typekey\.<TargetTypelist>\.TC_' modules/configuration/gsrc/
grep -rn '\b<TargetTypelist>\b' modules/configuration/config/web/pcf/
grep -rn '\b<TargetTypelist>\b' modules/configuration/gsrc/
```

---

### Phase G — Display Name Orphan Check

**Run: When the target LOB owns entity types**

List `.en` files whose entity type no longer exists after LOB-owned `.eti` files are
removed.

```
Search scope:  modules/configuration/config/displaynames/*.en
Pattern:       filename starts with the target LOB prefix
```

**Example commands:**
```bash
ls modules/configuration/config/displaynames/<LOBPrefix>*.en
```

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
- <File.gs> line <N> — var x : TargetClass
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

### Impact Summary
- Total consumers: <count>
- Safe to modify: Yes / No  (No if consumers exist outside current change scope)
- Requires coordination: <list of files needing companion changes>
```

---

## Behavioral Rules

1. **Always run Phases A, 1, 2, 5, and 6** for every target type.

2. **Run Phase A first** — a missing `impl=` class causes server startup failure with no
   compile error. Check both `config/extensions/entity/` and `config/metadata/entity/`.
   Check `iface=` for any value outside `gw.*`, `com.guidewire.*`, and `java.*`.

3. **Run Phase B when any `.gsx` is in scope** — callers never reference the enhancement
   class by name. Grep every method and property name individually across `.gs`, `.gsx`,
   `.pcf`, `.gr`, and `.gst`.

4. **Phase 6 must always report its result** — "No `.gr` consumers found" is required
   output. Never omit it.

5. **Use case-sensitive, word-boundary search** — Gosu class names are PascalCase.
   `\bClassName\b` prevents false positives (e.g., `Claim` matching `ClaimContact`).

6. **Check both `gsrc/` and `config/rules/`** — Phase 1 and 2 cover `gsrc/`; Phase 6
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
