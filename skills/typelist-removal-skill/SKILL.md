# Skill: typelist-removal

## Purpose

Safely remove a Guidewire Typelist (and all its references) from the current PolicyCenter, BillingCenter, or ClaimCenter project. This includes removing the typelist definition files, entity typekey references, Gosu usages, PCF bindings, display properties, product model references, and any other configuration that depends on the typelist.

## When to Activate

- When the user wants to completely remove a typelist from the project.
- When performing a Line of Business (LOB) removal that requires purging LOB-specific typelists.
- When retiring a typelist that is no longer needed after a product model change.
- When cleaning up unused or deprecated typelists identified during code review or compliance work.

---

## Inputs

- **Typelist name**: The name of the typelist to remove (e.g., `IMDeductibleType`, `ExampleLineTL`). This can be provided as:
  - The typelist name directly (e.g., `IMDeductibleType`)
  - The `.tti` filename (e.g., `IMDeductibleType.tti`)
  - The `.ttx` filename (e.g., `IMDeductibleType.ttx`)
- **Removal scope** (optional): Whether to remove only the extension (`.ttx`) or the full typelist (`.tti` + all extensions). Defaults to full removal.

---

## Background: Typelist File Types

| File Type | Purpose | Location |
|-----------|---------|----------|
| `.tti` | Typelist Type Info — the typelist declaration (defines typecodes, filters, categories) | `configuration/config/extensions/typelist/` or `configuration/config/metadata/typelist/` |
| `.ttx` | Typelist Type Extension — custom extension adding typecodes to an existing typelist | `configuration/config/extensions/typelist/` |
| `.tix` | Typelist Internal Extension — Guidewire internal (not customer-modifiable) | `configuration/config/metadata/typelist/` |

### Important Constraints

- **Never delete `.tti` files in `config/metadata/typelist/`** — these are platform-owned. Only customer-created `.tti` files in `config/extensions/typelist/` can be deleted.
- **Never delete `.tix` files** — these are Guidewire internal.
- Platform `.ttx` extensions (in `config/metadata/typelist/`) should not be deleted unless confirmed safe by the user.
- Customer `.ttx` extensions (in `config/extensions/typelist/`) are safe to delete.

---

## Workflow

### Step 1 — Confirm Scope and Create Backup Plan

Before starting, confirm with the user:

> "I will remove the typelist `<TypelistName>` and all its references. This will modify or delete files across entity definitions, Gosu source, PCF files, display properties, and configuration files. Would you like me to:"
>
> 1. **Proceed with removal** — I will make all changes directly.
> 2. **Dry-run first** — I will list all files that would be affected without making changes, then ask for confirmation.

Always recommend option 2 (dry-run) for safety.

Also ask:
> "Would you like to save the removal report to a file?"

- If **yes**: ask for the directory location. Filename will be auto-generated as `removal-typelist-<typelist_name>-report-<YYYYMMDD>.md`.
- If **no**: results will be displayed in the conversation only.

### Step 2 — Locate All Typelist Files

Search for the typelist definition and extension files:

1. **Definition file**: `<TypelistName>.tti` in:
   - `configuration/config/extensions/typelist/` (customer — removable)
   - `configuration/config/metadata/typelist/` (platform — NOT removable)

2. **Extension files**: `<TypelistName>.ttx` and `<TypelistName>.*.ttx` (qualified extensions) in:
   - `configuration/config/extensions/typelist/` (customer — removable)
   - `configuration/config/metadata/typelist/` (platform — NOT removable without user override)

If the `.tti` is platform-owned (in `config/metadata/`), **STOP** and inform the user:
> "This is a platform typelist. Only the customer extension `.ttx` file(s) in `config/extensions/typelist/` can be removed. The base `.tti` in `config/metadata/` must remain. Do you want to proceed with removing only the extension?"

### Step 3 — Parse the Typelist File

Read the `.tti` XML file and extract:
- The `name` attribute from the root `<typelist>` element.
- All typecodes defined (code values) — these are needed to find references throughout the codebase.
- Any typefilters defined — entities referencing these filters will need updating.

Also parse any `.ttx` extension files for additional typecodes added by extensions.

Build a complete list of:
- The typelist name (e.g., `IMDeductibleType`)
- All typecode values (e.g., `TC_Flat`, `TC_Percentage`, etc.)
- All typefilter names

### Step 4 — Find All References (Impact Analysis)

Search for all references to the typelist across the codebase. This is the same as the `typelist-find-usages` skill but organized for removal:

#### 4a. Entity Definitions (`.eti`, `.etx`, `.eix`)

Search in:
```
configuration/config/extensions/entity/
configuration/config/metadata/entity/
```

Find `<typekey>` elements referencing `typelist="<TypelistName>"`.

**Removal action**: Remove the `<typekey>` element from the entity file. If the entity file becomes empty of custom content after removal, delete the file.

**CRITICAL**: If the typekey is in a `.eti` file under `config/metadata/entity/`, this is a platform entity — do NOT remove it. Warn the user that this typelist is referenced by a platform entity and removal may break the application.

#### 4b. Gosu Files (`.gs`, `.gsx`)

Search in:
```
configuration/gsrc/
```

Find all usages matching:
- `typekey.<TypelistName>.TC_*` — typecode references
- `typelist.<TypelistName>` — typelist type references
- `uses typekey.<TypelistName>` — import statements
- Variables/parameters/return types using `<TypelistName>` as a type
- `.Code == "<typecode>"` comparisons for any typecode in the list

**Removal action**:
- Remove `uses typekey.<TypelistName>` import lines.
- For typecode references and type usages: these lines need manual review. Flag them for the user with context. If the entire file exists solely to support this typelist (e.g., a helper class), the file can be deleted.
- For files in `gsrc/gw/` (platform base classes): **NEVER modify**. Flag as a blocker.

#### 4c. PCF Files (`.pcf`)

Search in:
```
configuration/config/web/pcf/
```

Find:
- `valueType="typekey.<TypelistName>"` — input widgets
- `typelist="<TypelistName>"` — range inputs
- `valueRange="typekey.<TypelistName>"` — value ranges
- Widget elements bound to entity fields that reference this typelist

**Removal action**: Remove the widget/input element that references the typelist. If removing the widget leaves an empty panel or detail view, flag for the user to decide whether to remove the parent container.

#### 4d. Display Properties

Search in:
```
configuration/config/locale/
configuration/config/displaynames/
```

Find properties with keys matching:
- `typekey.<TypelistName>.*`
- `typelist.<TypelistName>.*`
- Any display name entries for typecodes belonging to this typelist

**Removal action**: Remove the matching property lines from display property files.

#### 4e. Product Model / APD Configuration

Search in:
```
configuration/config/resources/
configuration/config/content/
configuration/config/apd/
```

Find references to the typelist name or its typecodes in product model XML files.

**Removal action**: Remove the referencing elements. If the typelist is used as a CovTerm type or schedule item type, warn the user — this impacts rating and product definition.

#### 4f. Rate Books / Rating

Search in:
```
configuration/config/content/cust-ratebooks/
configuration/gsrc/cust/lob/*/rating/
configuration/gsrc/cust/sbt/rating/
```

Find references to the typelist or its typecodes in rate tables and rating engine code.

**Removal action**: Flag for user review — rate book changes require careful validation. Do not auto-delete rate book entries without explicit confirmation.

#### 4g. Typelist Mapping

Search in:
```
configuration/config/extensions/typelist/
```

Look for mapping files or `typecodemapping.xml` entries referencing the typelist.

**Removal action**: Remove the mapping entries.

#### 4h. BizRules (`.gwrules`, import XMLs)

Search in:
```
configuration/config/rules/
configuration/config/import/bizrules/
```

Find references to typecodes from this typelist in business rules.

**Removal action**: Flag for user review — business rule changes can affect underwriting flow. Do not auto-delete rule conditions without explicit confirmation.

#### 4i. Plugin Registrations (`.gwp`)

Search in:
```
configuration/config/plugin/registry/
```

Find any plugin registrations that reference the typelist.

**Removal action**: Remove the plugin registration entry if it solely serves this typelist.

#### 4j. Tests

Search in:
```
configuration/gtest/
```

Find test files referencing the typelist or its typecodes.

**Removal action**: Delete test files that exist solely to test functionality of the removed typelist. For shared test files, remove only the relevant test methods/assertions.

### Step 5 — Execute Removal (or Report Dry-Run)

If **dry-run mode**: Present the full list of affected files organized by action type:

```markdown
## Dry-Run Summary

### Files to DELETE (<count>)
| # | File | Reason |
|---|------|--------|
| 1 | <path> | Typelist definition file |

### Files to MODIFY (<count>)
| # | File | Lines Affected | Change Description |
|---|------|---------------|-------------------|
| 1 | <path> | <line numbers> | Remove <typekey/widget/import/etc.> |

### Files FLAGGED for Manual Review (<count>)
| # | File | Reason |
|---|------|--------|
| 1 | <path> | Platform entity reference — cannot auto-remove |

### BLOCKERS (<count>)
| # | File | Reason |
|---|------|--------|
| 1 | <path> | Platform base class in gsrc/gw/ — must not modify |
```

Wait for user confirmation before proceeding to actual removal.

If **proceed mode**: Execute changes in this order:

1. **Delete typelist files** (`.tti`, `.ttx`) in `config/extensions/typelist/`
2. **Modify entity extensions** (`.etx`) — remove `<typekey>` elements
3. **Modify Gosu files** — remove imports, typecode references, type usages
4. **Modify PCF files** — remove widgets/inputs referencing the typelist
5. **Remove display properties** — delete matching lines
6. **Modify configuration XMLs** — remove referencing elements
7. **Delete orphaned files** — files that exist solely for this typelist
8. **Clean up tests** — remove test references

### Step 6 — Post-Removal Validation

After removal, perform these checks:

1. **Grep for residual references**: Search the entire codebase for any remaining mentions of `<TypelistName>` or any of its typecodes. Report any found.
2. **Check for empty files**: If any modified files are now empty or contain only boilerplate, flag them for deletion.
3. **Check for broken imports**: Look for Gosu files that import entities/types that were modified and may now have missing fields.

### Step 7 — Save Report

If the user opted to save results:

1. Generate filename: `removal-typelist-<typelist_name>-report-<YYYYMMDD>.md`
2. Write the report in this format:

```markdown
# Typelist Removal Report: <TypelistName>

> Generated: <YYYY-MM-DD HH:MM>
> Typelist File: <path to .tti file>
> Typecodes Removed: <count>
> Extensions Removed: <list of .ttx files>

## Summary

| Action | Count |
|--------|-------|
| Files deleted | <count> |
| Files modified | <count> |
| Files flagged for manual review | <count> |
| Blockers (not removed) | <count> |
| Residual references found | <count> |

## Typecodes That Were Defined

| Code | Name |
|------|------|
| <code> | <name> |

## Files Deleted

| # | File | Reason |
|---|------|--------|
| 1 | <relative_path> | <reason> |

## Files Modified

| # | File | Changes Made |
|---|------|-------------|
| 1 | <relative_path> | <description of changes> |

## Flagged for Manual Review

| # | File | Reason | Line(s) |
|---|------|--------|---------|
| 1 | <relative_path> | <reason> | <line numbers> |

## Blockers (Not Removed)

| # | File | Reason |
|---|------|--------|
| 1 | <relative_path> | <reason> |

## Residual References (Post-Removal Check)

| # | File | Line | Content |
|---|------|------|---------|
| 1 | <relative_path> | <line> | `<content>` |

---

*Removal completed: <YYYY-MM-DD HH:MM>*
*Recommend running `gwb compile` to verify no compilation errors.*
```

---

## Behavioral Rules

1. **NEVER modify files in `config/metadata/`** — these are platform-owned. Only flag them as blockers or manual review items.
2. **NEVER modify files in `gsrc/gw/`** — these are auto-generated platform base classes.
3. **Always dry-run first** unless the user explicitly says to proceed without it.
4. **Case-sensitive matching.** The typelist name must be matched exactly as declared in the `.tti` file.
5. **Word-boundary matching.** Use `\b` regex boundaries to avoid partial matches.
6. **Include qualified extensions.** Always search for `<TypelistName>.*.ttx` qualified extensions.
7. **Relative paths.** Display file paths relative to the project root (`modules/configuration/`).
8. **Order of operations matters.** Delete typelist files last (after all references are removed) to avoid breaking the codebase during incremental removal.
9. **Compilation check.** After removal, recommend the user run `gwb compile` to verify no compilation errors were introduced.
10. **Rating impact warning.** If the typelist is referenced in rate books or rating engine code, always warn the user explicitly — rate changes can affect premium calculations.
11. **Entity field removal cascade.** When removing a `<typekey>` from an entity, check if any Gosu code accesses that field (e.g., `entity.FieldName`). These references must also be removed or the build will fail.
12. **Do not remove typelists used by other typelists.** Check if the typelist is used as a `<typefilter>` source or `<category>` in other typelists before removing.
13. **Batch removal support.** If the user provides a list of typelists to remove, process them one at a time in sequence, as removing one may affect the reference count of others.
