# Performance: Fixing Expensive Expressions

Full anti-pattern background: `/context/19-expensive-expressions.md`.

## Rule: Hoist a Reused Expensive Expression Into a PCF Variable

If an expensive expression (see the four categories in `/context/19-expensive-expressions.md`) is used in a widget's `value` or `valueRange` property — or referenced by more than one property/widget — don't call it inline each time. Instead:

1. Create a **PCF-level variable**, initialized using the expensive expression.
2. Reference the **variable** in the widget property/properties, instead of the raw expensive call.

**Why this works:** a PCF-level variable is evaluated **only once, when the page is first constructed** — not again during the page's lifetime, even across Post-on-Change edits. This is the single biggest lever for neutralizing an expensive expression's cost.

**Caution — `recalculateOnRefresh`:** page variables have a `recalculateOnRefresh` property. If set to `true`, the initialize logic re-runs on **every** page refresh — which defeats the caching benefit above if the page has Post-on-Change fields (since those trigger frequent refreshes). Leave this `false` unless there's a specific reason the value must be recalculated on every refresh.

## Rule: One Shared Variable for Multiple Widgets Using the Same Expensive Method

If several widgets on a page all need the result of the same expensive method (e.g. to set their `required`, `editable`, `available` properties), don't call the method separately in each widget. Create **one page-level PCF variable**, initialize it with the method call once, and reference that single variable from every widget that needs it.

## Rule: For ListView Cells, Hoist to the Row Iterator (or ListView) — But Only If the Value Doesn't Vary Per Row

If an expensive method is used to compute a ListView cell's value, and that call is **repeated once per row** as the list loads, check whether the value actually depends on the row's specific data:

- **If the value is the same regardless of which row is being rendered** (e.g. some current-user-level lookup that doesn't vary by row), hoist it: create a variable on the **Row Iterator** (or on the ListView itself), initialized by calling the expensive method once. It will be set a single time when the page loads, and the cell can reference that variable instead of recalculating per row.
- **If the value genuinely depends on each row's own data**, this hoisting technique does not apply — don't force a row-varying computation into a single shared variable, since that would produce the same wrong value for every row.

## Rule: Use `.Empty` for Existence Checks, Join/Compare for Filtered Results

When a collection method is being used just to check "are there any matching records," replace it with a query and test the query's `.Empty` property. When a filtered subset is genuinely needed, write the filter into the query itself using join and compare methods — don't retrieve broadly and filter in Gosu afterward.

## Rule: Use Application Permission Keys, Not Manual Role Checks

Never check a user's role membership directly via a collection method (e.g. "does this user have only role X") to gate a widget's `Editable`/`Visible`/`Available` property. This is both a performance problem (background query + iteration) **and** an architectural one (it bypasses the permission framework Guidewire already provides).

**Correct approach:**
1. Extend the `SystemPermissionType` typelist with a new typecode (e.g. `edituserdetails_Ext`).
2. Test that permission directly in the widget's relevant dynamic property (e.g. `Editable`), rather than inspecting roles manually.
