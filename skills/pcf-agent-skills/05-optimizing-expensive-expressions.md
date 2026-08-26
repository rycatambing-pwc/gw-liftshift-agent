# Skill: Identifying and Fixing Expensive Expressions

Use this when reviewing existing PCF for performance issues, or when writing new PCF that involves any non-trivial expression in a dynamic property (`value`, `valueRange`, `Editable`, `Visible`, `Available`, `Required`, `Label`) or a ListView cell.

## Step 1: Spot the Anti-Patterns

Check every non-trivial expression against these four categories (full detail: `/context/19-expensive-expressions.md`):
- Complex function calls, especially anything involving a query
- Multi-step dot notation (each hop across a foreign key is a query)
- Array expansions (`*.`)
- Collection methods (background query + iteration, often over-fetching)

Also check: is a manual role/permission check being done via a collection method instead of an application permission key?

## Step 2: Check for Repetition

For each expensive expression found, ask:
- Is it used in **more than one property** of the same widget?
- Is it used by **more than one widget** on the page?
- Is it inside a **ListView cell**, meaning it repeats per row?
- Does the page have **Post-on-Change** fields that could cause this to re-run repeatedly during editing?

Any "yes" here means the fix below isn't optional — the cost compounds.

## Step 3: Apply the Matching Fix

| Situation | Fix |
|---|---|
| Expensive expression used once, or in one widget's `value`/`valueRange` | Create a PCF-level variable initialized with the expression; reference the variable instead of the raw call. |
| Same expensive expression used by multiple widgets/properties | One shared page-level PCF variable, initialized once, referenced everywhere it's needed. |
| Expensive expression in a ListView cell, value is the **same regardless of row** | Move it to a variable on the Row Iterator (or the ListView itself) — evaluated once, not per row. |
| Expensive expression in a ListView cell, value **genuinely varies per row** | Cannot be hoisted this way — leave it row-scoped, but still check it isn't unnecessarily complex (e.g. an over-broad collection method that could be a targeted query instead). |
| Existence check only ("are there any matches") | Replace with a query + `.Empty` property test. |
| Filtered subset needed | Write the filter into the query using join/compare methods — filter in the database, not after retrieval. |
| Manual role-membership check gating a widget property | Extend `SystemPermissionType` with a new typecode (e.g. `Something_Ext`) and test that permission instead. |

## Step 4: Set `recalculateOnRefresh` Deliberately

If you introduced a PCF variable per Step 3, leave `recalculateOnRefresh` at its default (`false`) unless there's a specific reason the value must be recomputed every refresh. Setting it `true` on a page with Post-on-Change fields silently reintroduces the exact cost the variable was meant to eliminate.

## Cross-references

- Full anti-pattern catalog: `/context/19-expensive-expressions.md`
- Fix-pattern rules: `/rules/08-performance-expensive-expressions.md`
- Post-on-Change mechanics: `/context/17-dynamic-ui-and-post-on-change.md`, `/context/18-post-on-change-implementation-and-performance.md`
