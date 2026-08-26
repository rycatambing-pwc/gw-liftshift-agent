# Expensive Expressions: An Anti-Pattern Catalog

Source: Guidewire Education module. Extends `/context/17-dynamic-ui-and-post-on-change.md` and `/context/18-post-on-change-implementation-and-performance.md`.

## Dynamic Properties — One Addition

Confirms `Available`, `Editable`, `Visible` (Boolean expressions) and `Label` (string expression) from earlier modules, and adds:
- **`Required`** — Boolean expression; when true, displays an asterisk next to the field to signal it's required.

## What Makes an Expression "Expensive"

Four named categories, all of which can noticeably slow page loads — especially when referenced from multiple places, or on a page with Post-on-Change fields (since those can re-trigger evaluation repeatedly as the user edits):

### 1. Complex functions involving queries
Any expression that calls a function doing significant processing, especially one that queries the database. Expensive even if the function always returns the same result, because it's re-executed every time it's referenced — the system doesn't cache the result across references (unless you make it, see Rules).

### 2. Multi-step dot notation
Dot-path statements traverse relationships (foreign keys) and trigger queries in the background as they go. **Example:** `Exposure` → `Claim` (foreign key) → `Catastrophe` (foreign key), plus an array lookup on `ClaimsHistory` — each hop is a query, so a multi-hop dot path compounds cost.

### 3. Array expansions
The expansion operator (`*.`) pulls a property from every item in an array, returning a new array of results — this runs a query and iterates over it. **Example:** `MemberGroups*.` (returning the display name of every group a user belongs to). Impact grows with array size. **Recommended refactor:** consider a `ListView` to display this kind of content instead of an inline array expansion.

### 4. Collection methods
Also run a background query and iterate the results. Commonly return a **larger set than needed**, which then gets filtered on the application server — wasted CPU/memory, with actual impact depending on collection size and filter complexity.

**Correct alternatives depending on intent:**
- **Just checking existence?** Write a query and test its **`Empty`** property — don't retrieve full results just to check if any exist.
- **Need a filtered subset?** Write a query using **join and compare methods** to filter *in the database*, returning only what's needed — don't retrieve broadly and filter after the fact on the app server.

## Compounding Cases (why this gets worse than it looks)

- **Same expensive expression referenced in multiple properties of one widget** — e.g. used in both `Editable` and `Visible` of the same widget — executes **once per property reference**, not once total.
- **Same expensive expression referenced by multiple different widgets on a page** — executes once per widget.
- **Post-on-Change fields present** — any of the above can re-run repeatedly as the user edits the page, since Post-on-Change re-posts and re-evaluates.
- **Expensive expression inside a ListView cell** — if used to compute a cell's value, it repeats **once per row** as the ListView loads.

## Real Anti-Pattern Example: Permission Checks via Collection Methods

A `PrimaryPhone` TextInput's `Editable` property used a collection method to check whether the current user's *only* role is "Claims Supervisor." This runs a background query and iterates over all the user's roles — inefficient, **and** it bypasses the application/system permission framework that already exists for exactly this purpose. See `/rules/08-performance-expensive-expressions.md` for the correct alternative (application permission keys).

## See Also

`/rules/08-performance-expensive-expressions.md` for the concrete fix patterns (PCF variables, Row Iterator variables, permission keys) and `/skills/05-optimizing-expensive-expressions.md` for the step-by-step remediation workflow.
