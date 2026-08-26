# Making a List View Editable

Source: Guidewire Education module (highest confidence). Builds directly on `/context/08-list-view-architecture.md`.

## What "Editable" Means for a List View

A List View can display an array of entities, database query results, reference table rows, or any other tabular data. Typically, data is *viewed* in a List View and *edited* in a Detail View — but sometimes editing in place makes more sense. Making a List View editable allows: adding rows, removing rows, and modifying individual cell values directly in the table.

## The Editable Hierarchy

Editability cascades through four nested levels, each independently identifiable/configurable:

1. **List View Panel** — the outer editable container
2. **Row Iterator** — the editable iteration mechanism (see `/context/08-list-view-architecture.md`)
3. **Row** — an individual editable row
4. **Cell** — an individual editable value within a row

(Practical implication: "is this List View editable" isn't a single toggle — it's a property that exists at each of these four levels, and something can behave unexpectedly if one level is editable but another isn't configured to match.)

## Add / Remove Buttons — Visibility and Availability Logic

These are "iterator buttons," governed by the Row Iterator's properties:

| Rule | Detail |
|---|---|
| **Visibility** | Both Add and Remove buttons are visible **only if the screen is in edit mode.** |
| **Availability** | Both buttons are available **only if their action is defined.** |
| **Remove-specific** | Remove is additionally available **only if at least one row is selected** in the List View (in addition to having its action defined). |

**Rule for generated PCF:** don't hand-roll custom visibility/availability logic for these buttons — this exact combination (edit-mode-gated visibility; action-defined + selection-gated availability for Remove) is the standard, expected behavior.

## Toolbar Placement Recommendation (refines, doesn't contradict, `/rules/04-toolbar-placement-and-edit-workflow.md`)

- A List View **requires** a toolbar — it's where paging controls and any needed buttons live.
- **Recommended split:** put the Edit button on the **screen-level toolbar**; put the Add/Remove (iterator) buttons on the **toolbar closest to the List View** itself.
- Depending on screen complexity, these might end up being the same single toolbar holding both — that's acceptable, the split above is a default recommendation, not a hard requirement.

## Two Patterns for the Add Button

| Pattern | Mechanism | When to use |
|---|---|---|
| **A. Inline empty row** | Clicking Add inserts a new empty row directly into the List View; user fills it in by editing the cells in place. | Use when the List View already displays **all** the fields that need to be set on creation. |
| **B. Creation popup** | Clicking Add opens a popup with an empty object and all its fields; user fills the popup, clicks OK, and the initialized object is inserted as a new row. | Use when the List View only displays a **few** key fields, but the underlying object has more fields that need to be set at creation time. |

**Decision rule:** if the List View's visible columns cover everything the object needs on creation, use Pattern A. If the object has meaningful fields not shown in the List View's columns, use Pattern B.

> ⚠️ SCOPE NOTE: the source material explicitly states that **configuring the creational popup for Pattern B is out of scope** for the course this came from. We do not yet have the mechanics for building that popup — treat Pattern B as "known to exist, mechanism not yet documented" until a real example or further module covers it. Do not invent creation-popup PCF syntax without confirming it first.

## Cross-References

- Root-object semantics (`addTo`/`removeFrom` functions) from `/context/08-list-view-architecture.md` are what actually make row insertion/removal possible at the data layer — this module describes the *UI* side (buttons/visibility) that triggers those underlying functions.
- Standard Edit/Update/Cancel toolbar behavior is in `/rules/04-toolbar-placement-and-edit-workflow.md` — Add/Remove are a List-View-specific addition on top of that same edit-mode-gated pattern (Add/Remove are also only visible in edit mode, same as the general Edit workflow).
