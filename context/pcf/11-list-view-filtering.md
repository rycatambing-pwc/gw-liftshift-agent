# List View Filtering

Source: Guidewire Education module (highest confidence). Complements `/context/10-view-entities-and-performance.md` — filtering is another lever for List View performance, alongside View Entity column extension.

## Why Filter

Filtering limits the data set a query returns, letting users focus on what they need and improving both perceived and actual application performance (less data fetched/rendered). All Guidewire core applications ship List Views with filters already (e.g. the Desktop Activities list in ClaimCenter), and these can be extended — or entirely new filters created for custom List Views.

## Mechanism: Gosu Standard Query Filters

If a List View is **query-backed** (see `/context/10-view-entities-and-performance.md`), filters can be created using **Gosu Standard Query Filters**.

## The Toolbar Filter Widget

The Toolbar Filter widget has a **Filter Options** tab supporting two filter types:

| Type | Expression resolves to |
|---|---|
| **ToolbarFilterOption** | A **single** filter object |
| **ToolbarFilterOptionsGroup** | An **array** of filter objects |

- Simple filters can be constructed directly inline in the filter property.
- **For complex filters, build the logic in a Gosu function and call that function from the filter property** — this is a performance recommendation, not just a style preference (see Rules).

Reference for more detail: "Filtering Results with Standard Query Filters" in the Gosu Reference Guide (not yet retrieved directly).

## Performance Guidance

- Define filters as **Gosu functions** called from the filter property, rather than inlining complex logic, for better performance.
- Use **comparison clauses in the Gosu query itself** to limit the result set returned from the database — filter as early as possible (at the query/DB level), not after the full set is already fetched.

## Pattern: A Hidden Default Filter

A Toolbar Filter can silently restrict a query-backed List View's results **without showing any filter UI to the user** — e.g. always scoping results to "records belonging to the current user."

**Recipe:**
1. Construct the filter expression to restrict the result set as needed (e.g. scoped to the current user).
2. In the Filter Options tab's **Advanced Properties**, set `selectOnEnter` to `true`.
3. In the same Advanced Properties, set `visible` to `false`.

Result: the filter is applied automatically on load, with no visible filter control shown to the user.

(This is a strong candidate for its own `/skills/` entry — see skills file.)
