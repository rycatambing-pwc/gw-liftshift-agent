---
name: typelist-find-usages
description: Finds every usage of a Guidewire typelist across entity definitions, Gosu, PCF, display properties and configuration files. Use before extending, retiring or removing a typelist or typecode, or when asked where a typelist is used. Read-only.
---

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
configuration/config/bizrules/
configuration/config/gwrules/
```

Look for references to typecodes from this typelist.

#### 4h. Locale Variant Properties Files (CRITICAL — frequently missed during LOB removal)

These files were missed in past LOB removals, leaving thousands of orphaned keys:

Search in:
```
configuration/config/locale/typelist.properties
configuration/config/locale/typelist_en_US.properties
configuration/config/locale/typelist_yy.properties
configuration/config/locale/typelist_es.properties
configuration/config/locale/typelist_es_ES.properties
configuration/config/locale/productmodel.display.properties
configuration/config/locale/schema.display.properties
configuration/config/locale/schema.display_en_US_EDG.properties
configuration/config/locale/schema.display_en_US_EDG_PH.properties
configuration/config/locale/display_en_US.properties
configuration/config/locale/display_yy.properties
```

Look for keys containing the typelist name or its typecodes.

#### 4i. Smoketests (frequently missed)

Search in:
```
configuration/config/smoketests/typelists.properties
configuration/config/smoketests/
```

This directory is NOT in typical search paths and was missed in every past LOB removal.

#### 4j. REST API Schemas

Search in:
```
configuration/integration/**/*.schema.json
configuration/config/integration/**
```

Look for references to the typelist name. `CUPolicyType` was missed in `policyperiod_ext-1.0.schema.json` during CU removal.

#### 4k. Gosu Templates (.gst)

Search in:
```
configuration/gsrc/**/*.gst
```

Templates reference typelist values at render time. They do NOT cause compile errors but CRASH at runtime.

#### 4l. Config XML

Search in:
```
configuration/config/xml/config.xml
```

Look for LOB-specific parameters referencing this typelist.

#### 4m. Tests

Search in:
```
configuration/gtest/**/*.gs
configuration/gtest/**/*.gsx
```

Look for test files referencing the typelist or its typecodes.

### Step 5 — Save Results (Conditional)

If the user opted to save results in Step 1:

1. Generate the filename: `search-typelist-<typelist_name>-results-<YYYYMMDD>.md`
   - `<typelist_name>` is the typelist name from Step 3 (case-preserved)
   - `<YYYYMMDD>` is today's date
2. Write the results file in Markdown format at the user-specified location.

Use the following output format:

Report template: [references/report-format.md](references/report-format.md). Read it only when the user chose to save the results.


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
