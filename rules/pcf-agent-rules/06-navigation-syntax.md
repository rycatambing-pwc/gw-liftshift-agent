# Navigation Action Syntax Rules

Full conceptual background: `/context/13-navigating-to-locations.md`, `/context/14-location-groups.md`.

## The General Syntax

Any navigation-triggering `action` attribute follows:

```
LocationEntryPoint.method(objectList)
```

- `LocationEntryPoint` must be a real entry point defined on the destination Location's Entry Points tab — don't invent one.
- `objectList` must match, in count and type, exactly what that entry point declares it expects. Zero arguments is valid if the entry point takes none (e.g. `Admin()`).

## Method Selection Rule

| Target Location type | Method to use |
|---|---|
| Popup | `.push(...)` |
| Location Group | `.go(...)` — **always**, regardless of product |
| Wizard | Product-dependent: `.go(...)` typically for ClaimCenter/PolicyCenter; `.push(...)` typically for BillingCenter — verify against the target product if unsure |

**Do not default to one method universally.** Check which Location type is being navigated to (and, for Wizards, which product) before choosing `push` vs `go`.

## Location Group Nesting Rule

Avoid creating multiple nested levels of Location Groups, even though BillingCenter technically supports it. Prefer a flat first-level/second-level structure (per `/context/14-location-groups.md`) unless there's a specific, documented reason to go deeper.

## Naming Rule

Location Group PCF files don't require a specific extension, but should use the **`Group`** suffix as good practice (e.g. `AccountGroup`, `DesktopGroup`). Combine with the `_Ext` convention for custom groups — exact ordering/interaction not yet confirmed; see `/unresolved/01-open-questions.md`.
