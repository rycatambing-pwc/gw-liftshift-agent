# Skill: entity-find-usages

## Purpose

Find and list all usages of a Guidewire Entity within the current PolicyCenter, BillingCenter, or ClaimCenter project. This helps developers understand the impact and dependencies of an entity across Gosu source files.

## When to Activate

- When the user wants to know where a specific entity is used in the project.
- When assessing the impact of modifying an entity.
- When performing a lift-and-shift or refactoring exercise involving entities.

---

## Inputs

- **Entity name**: The name of the entity to search for (e.g., `Activity`, `Claim`, `Policy`). This can be provided as:
  - The entity name directly (e.g., `Activity`)
  - The `.eti` filename (e.g., `Activity.eti`)

---

## Workflow

### Step 1 — Ask About Saving Results

Before starting the search, ask the user:

> "Would you like to save the search results to a file?"

- If **yes**: ask for the directory location where the file should be saved. The filename will be auto-generated as `search-<entity_name>-results-<YYYYMMDD>.md` (e.g., `search-Activity-results-20260819.md`).
- If **no**: proceed without saving; results will be displayed in the conversation only.

### Step 2 — Locate the Entity XML File

Search for the entity `.eti` file in the entity folders. Look in:

1. `configuration/config/extensions/entity/` — custom/extended entities
2. `configuration/config/metadata/entity/` — base platform entities (if accessible)

The file will be named `<EntityName>.eti`.

If the file is not found, inform the user and stop.

### Step 3 — Parse the Entity File

Read the `.eti` XML file and extract the `entity` attribute from the root `<entity>` element. This attribute value is the **Entity class name** that will be generated and referenced throughout the codebase.

Example — from this XML:
```xml
<entity xmlns="http://guidewire.com/datamodel"
  entity="Activity"
  table="activity"
  type="retireable">
```

The entity class name is: `Activity`

### Step 4 — Search for Usages in Gosu Files

Search for references to the entity class name in all Gosu files (`.gs` and `.gsx` extensions) located under:

```
configuration/gsrc/
```

The search must be **case-sensitive** and match the exact entity name as it appears in the `entity` attribute. Search for occurrences where the entity name is used as:

- Type declarations (e.g., `var claim : Activity`)
- Method parameters (e.g., `function process(activity : Activity)`)
- Return types (e.g., `function getActivity() : Activity`)
- Property access (e.g., `entity.Activity`)
- Class references (e.g., `Activity.finder`)
- Imports or uses statements
- Generic type parameters (e.g., `List<Activity>`)
- Casts (e.g., `as Activity`)

Use a word-boundary-aware search pattern to avoid false positives (e.g., searching for `Claim` should not match `ClaimContact` unless it is followed by a non-word character). The recommended pattern is:

```
\bEntityName\b
```

For each match found, record:
- The file path (relative to the project root)
- The line number
- The matching line content (trimmed)

### Step 5 — Save Results (Conditional)

If the user opted to save results in Step 1:

1. Generate the filename: `search-<entity_name>-results-<YYYYMMDD>.md`
   - `<entity_name>` is the entity class name from Step 3 (case-preserved)
   - `<YYYYMMDD>` is today's date (e.g., `20260819`)
2. Write the results file in Markdown format at the user-specified location.

Use the following output format:

```markdown
# Entity Usage Report: <EntityName>

> Generated: <YYYY-MM-DD HH:MM>
> Entity File: <path to .eti file>
> Entity Attribute: <entity attribute value>

## Summary

| Metric | Value |
|--------|-------|
| Total files with usages | <count> |
| Total usage occurrences | <count> |

## Usages in Gosu Files (`configuration/gsrc/`)

| # | File | Line | Code |
|---|------|------|------|
| 1 | <relative_path> | <line_number> | `<trimmed line content>` |
| 2 | ... | ... | ... |

---

*Search pattern: `\b<EntityName>\b` (case-sensitive)*
```

---

## Behavioral Rules

1. **Case-sensitive matching.** The entity name must be matched exactly as declared in the `entity` attribute.
2. **Word-boundary matching.** Use `\b` regex boundaries to avoid partial matches (e.g., `Claim` should not match inside `ClaimContact`).
3. **Relative paths.** Always display file paths relative to the project root.
4. **No modifications.** This skill is read-only — never modify any project files.
5. **Handle missing entity gracefully.** If the `.eti` file cannot be found, inform the user with the paths that were searched and stop.
6. **Large result sets.** If more than 200 matches are found, group by file and show a count per file rather than listing every line individually. Still include the full details in the saved file if saving is enabled.
