# Skill: typelist-find-usages

## Purpose

Find and list all usages of a Guidewire Typelist within the current PolicyCenter, BillingCenter, or ClaimCenter project. This helps developers understand the impact and dependencies of a typelist across entity definitions, Gosu source files, PCF files, display properties, and configuration files.

## When to Activate

- When the user wants to know where a specific typelist is used in the project.
- When assessing the impact of modifying, extending, or removing a typelist.
- When performing a lift-and-shift or LOB removal exercise involving typelists.
- When retiring typecodes and needing to identify all references.

---

## Inputs

- **Typelist name**: The name of the typelist to search for (e.g., `PolicyLine`, `ActivityCategory`, `Priority`). This can be provided as:
  - The typelist name directly (e.g., `PolicyLine`)
  - The `.tti` filename (e.g., `PolicyLine.tti`)
  - The `.ttx` filename (e.g., `PolicyLine.ttx`)

---

## Background: Typelist File Types

| File Type | Purpose | Location |
|-----------|---------|----------|
| `.tti` | Typelist Type Info — the typelist declaration (defines typecodes, filters, categories) | `configuration/config/extensions/typelist/` or `configuration/config/metadata/typelist/` |
| `.ttx` | Typelist Type Extension — custom extension adding typecodes to an existing typelist | `configuration/config/extensions/typelist/` |
| `.tix` | Typelist Internal Extension — Guidewire internal (not customer-modifiable) | `configuration/config/metadata/typelist/` |

### Qualified Extensions

A typelist may have multiple qualified extensions using the pattern `TypelistName.Qualifier.ttx` (e.g., `Jurisdiction.Canada.ttx`, `Jurisdiction.Australia.ttx`). Search for all qualified variants.

---

## Workflow

### Step 1 — Ask About Saving Results

Before starting the search, ask the user:

> "Would you like to save the search results to a file?"

- If **yes**: ask for the directory location where the file should be saved. The filename will be auto-generated as `search-typelist-<typelist_name>-results-<YYYYMMDD>.md` (e.g., `search-typelist-PolicyLine-results-20260820.md`).
- If **no**: proceed without saving; results will be displayed in the conversation only.

### Step 2 — Locate the Typelist Definition File

Search for the typelist `.tti` file in the typelist folders. Look in:

1. `configuration/config/extensions/typelist/` — custom typelists and extensions
2. `configuration/config/metadata/typelist/` — base platform typelists

The file will be named `<TypelistName>.tti`.

Also search for extension files:
- `<TypelistName>.ttx` — unqualified extension
- `<TypelistName>.*.ttx` — qualified extensions (e.g., `PolicyLine.BP7.ttx`)

If no `.tti` file is found, inform the user and stop.

### Step 3 — Parse the Typelist File

Read the `.tti` XML file and extract:
- The `name` attribute from the root `<typelist>` element — this is the **Typelist name** referenced throughout the codebase.
- Whether it is `final="true"` (non-extendable) or `final="false"` (extendable).
- The list of typecodes defined (code and name attributes).
- Any typefilters defined.

Example — from this XML:
```xml
<typelist xmlns="http://guidewire.com/typelists"
  desc="Line of business types"
  name="PolicyLine"
  final="false">
  <typecode code="BP7Line" name="Businessowners" priority="1"/>
  <typecode code="CPLine" name="Commercial Property" priority="2"/>
</typelist>
```

The typelist name is: `PolicyLine`

### Step 4 — Search for Usages Across the Codebase

Search for references to the typelist name in the following locations, using the patterns described for each:

#### 4a. Entity Definitions (`.eti`, `.etx`, `.eix`)

Search in:
```
configuration/config/extensions/entity/
configuration/config/metadata/entity/
```

Look for `<typekey>` elements that reference the typelist:
```
typelist="<TypelistName>"
```

For each match, record the entity name, field name, and whether a typefilter or keyfilter is applied.

#### 4b. Gosu Files (`.gs`, `.gsx`)

Search in:
```
configuration/gsrc/
```

Search for these usage patterns (case-sensitive, word-boundary aware):

| Pattern | Example |
|---------|---------|
| Typecode reference | `typekey.PolicyLine.TC_BP7Line` |
| Typelist type usage | `PolicyLine` used as a type (variable, parameter, return type) |
| `.Code` comparisons | `.Code == "BP7Line"` |
| Typekey access on entities | `entity.PolicyLine` |
| Imports/uses referencing the typelist | `uses typekey.PolicyLine` |

The recommended regex patterns:
```
typekey\.<TypelistName>\.TC_\w+
typelist\.<TypelistName>
\b<TypelistName>\b
```

#### 4c. PCF Files (`.pcf`)

Search in:
```
configuration/config/web/pcf/
```

Look for:
- `valueType="typekey.<TypelistName>"` — input widgets bound to a typekey
- `typelist="<TypelistName>"` — typelist range inputs
- `valueRange="typekey.<TypelistName>"` — value range specifications
- References to entity fields that are typekeys of this typelist (found in Step 4a)

#### 4d. Display Properties

Search in:
```
configuration/config/locale/
configuration/config/displaynames/
```

Look for:
- Properties with keys matching the pattern `*.<TypelistName>.*` in `display.properties`
- Display name files (`.en`) referencing typecodes from this typelist

#### 4e. Product Model / Configuration XML

Search in:
```
configuration/config/resources/
configuration/config/content/
configuration/config/import/
```

Look for references to the typelist name or its typecodes in XML configuration files.

#### 4f. Typelist Mapping

Search in:
```
configuration/config/typelists.mapping/
```

Look for `<typelist name="<TypelistName>">` entries in `typecodemapping.xml`.

#### 4g. BizRules (`.gwrules`)

Search in:
```
configuration/config/import/bizrules/
```

Look for references to typecodes from this typelist.

### Step 5 — Save Results (Conditional)

If the user opted to save results in Step 1:

1. Generate the filename: `search-typelist-<typelist_name>-results-<YYYYMMDD>.md`
   - `<typelist_name>` is the typelist name from Step 3 (case-preserved)
   - `<YYYYMMDD>` is today's date
2. Write the results file in Markdown format at the user-specified location.

Use the following output format:

```markdown
# Typelist Usage Report: <TypelistName>

> Generated: <YYYY-MM-DD HH:MM>
> Typelist File: <path to .tti file>
> Final: <true/false>
> Typecodes: <count>
> Extensions Found: <list of .ttx files>

## Summary

| Metric | Value |
|--------|-------|
| Entity typekey references | <count> |
| Gosu file usages | <count> |
| PCF file usages | <count> |
| Display property references | <count> |
| Configuration/XML references | <count> |
| BizRules references | <count> |
| Typelist mapping entries | <count> |
| **Total usages** | **<count>** |

## Typecodes Defined

| Code | Name | Priority | Retired |
|------|------|----------|---------|
| <code> | <name> | <priority> | <retired> |

## Usages in Entity Definitions

| # | Entity File | Entity Name | Field Name | Typefilter | Keyfilter |
|---|-------------|-------------|------------|------------|-----------|
| 1 | <relative_path> | <entity> | <field> | <filter or —> | <keyfilter or —> |

## Usages in Gosu Files (`configuration/gsrc/`)

| # | File | Line | Code |
|---|------|------|------|
| 1 | <relative_path> | <line_number> | `<trimmed line content>` |

## Usages in PCF Files (`configuration/config/web/pcf/`)

| # | File | Line | Code |
|---|------|------|------|
| 1 | <relative_path> | <line_number> | `<trimmed line content>` |

## Usages in Display Properties

| # | File | Property Key |
|---|------|-------------|
| 1 | <relative_path> | <property_key> |

## Usages in Configuration/XML Files

| # | File | Line | Context |
|---|------|------|---------|
| 1 | <relative_path> | <line_number> | `<trimmed line content>` |

## Usages in BizRules

| # | File | Line | Context |
|---|------|------|---------|
| 1 | <relative_path> | <line_number> | `<trimmed line content>` |

## Typelist Mapping

| Typecode | Namespace | Alias |
|----------|-----------|-------|
| <typecode> | <namespace> | <alias> |

---

*Search patterns: `typelist="<TypelistName>"`, `typekey\.<TypelistName>\.TC_\w+`, `\b<TypelistName>\b` (case-sensitive)*
```

---

## Behavioral Rules

1. **Case-sensitive matching.** The typelist name must be matched exactly as declared in the `name` attribute of the `.tti` file.
2. **Word-boundary matching.** Use `\b` regex boundaries to avoid partial matches (e.g., `Priority` should not match inside `PriorityQueue` unless it is a genuine typelist reference in context).
3. **Include qualified extensions.** Always search for `<TypelistName>.*.ttx` qualified extensions in addition to the main `.tti` and unqualified `.ttx`.
4. **Relative paths.** Always display file paths relative to the project root.
5. **No modifications.** This skill is read-only — never modify any project files.
6. **Handle missing typelist gracefully.** If the `.tti` file cannot be found, inform the user with the paths that were searched and stop.
7. **Large result sets.** If more than 200 matches are found in any single category, group by file and show a count per file rather than listing every line individually. Still include the full details in the saved file if saving is enabled.
8. **Distinguish context.** When reporting Gosu usages, differentiate between typecode references (`typekey.X.TC_Y`) and type-level references (using the typelist as a type) where possible.
