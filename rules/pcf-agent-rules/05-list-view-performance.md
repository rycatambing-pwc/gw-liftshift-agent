# List View Performance Practices

Source: Guidewire Education module (View Entities). Full conceptual background in `/context/10-view-entities-and-performance.md`.

## Rule: Don't Retrieve a Full Related Entity for One Field

If a List View cell needs a value that lives on a related entity (not the primary View Entity), **do not** wire the cell to fetch the entire related entity just to read one field.

**Do instead:** extend the View Entity with a new `viewEntityColumn` that defines a **path** to the specific value through the related entity. Reference that value directly on the View Entity in the cell — this lets the query pick up the needed join automatically rather than triggering a separate full-entity fetch per row.

## Rule: Use `DisplayName` for Non-Editable Name-Only Fields

If a column only needs to display a name/label (and is **not editable**), use the entity's `DisplayName` rather than retrieving the entire related record. Pulling a whole record just to show its name string is unnecessary overhead — this matters more as row count grows, since it multiplies per row.

## When Reviewing/Generating a Query-Backed List View

Before wiring any List View cell to a related-entity value, ask: is this value already reachable via a path on the View Entity (or extendable to be)? If not, extending the View Entity is the correct fix — not adding ad-hoc retrieval logic in the cell or row iterator.

## Rule: Filter as Early as Possible

When adding filtering to a query-backed List View:
- Define filters using **Gosu Standard Query Filters**.
- For anything beyond a trivial filter expression, put the logic in a **Gosu function** and call it from the filter property — don't inline complex logic directly.
- Use **comparison clauses in the Gosu query itself** to limit the result set at the database level, rather than fetching everything and filtering afterward.

Full mechanics in `/context/11-list-view-filtering.md`.
