# Skill: Setting a Hidden Default Filter on a List View

Use this when a query-backed List View needs to always be scoped to some condition (e.g. "only the current user's records," "only open items") **without** showing a filter control to the user — the restriction should just apply silently.

## When to use this pattern

- The List View is query-backed (see `/context/10-view-entities-and-performance.md`).
- The scoping condition should always apply and isn't something the user needs to toggle.
- Examples: "my open activities," "records for the account currently being viewed," "items not yet closed."

## Steps

1. **Construct the filter expression** that restricts the result set to the desired condition. If the logic is more than trivial, put it in a Gosu function rather than inlining it (see `/rules/05-list-view-performance.md`) — better performance and easier to maintain/test.
2. **Add a Toolbar Filter widget** to the List View's toolbar, using the Filter Options tab.
3. **Choose the filter type:**
   - `ToolbarFilterOption` if the filter resolves to a single filter object.
   - `ToolbarFilterOptionsGroup` if it resolves to an array of filter objects.
4. **In the Filter Options tab's Advanced Properties, set:**
   - `selectOnEnter = true` — applies the filter automatically on load.
   - `visible = false` — hides the filter control from the user entirely.

## Result

The List View loads already scoped to the restriction, with no visible sign to the user that filtering happened — it just looks like the "right" data was there all along.

## Don't confuse with

A **user-facing** filter (where the user picks from filter options, like the "My open activities" example that reduces 14 rows to 7) — that's the same `ToolbarFilterOption`/`ToolbarFilterOptionsGroup` mechanism, just with `visible` left `true` (or omitted) so the control actually shows.

## Cross-references

- Performance rules for filter construction: `/rules/05-list-view-performance.md`
- General List View / query-backed root object concepts: `/context/08-list-view-architecture.md`, `/context/10-view-entities-and-performance.md`
