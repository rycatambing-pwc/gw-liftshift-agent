# List View Architecture

Source: Guidewire Education module (highest confidence). Companion to `/context/07-detail-views-inline-vs-reusable.md` — List Views follow the same inline-vs-reusable-PCF-file pattern as Detail Views.

## What a List View Is

A List View Panel shows **summary information about a collection of objects** (as opposed to a Detail View, which shows detailed information about a single object).

## Row Widgets and Row Iterators

- A **Row Iterator** iterates over a data set, dynamically generating one row per record.
- **Row widgets** organize the layout of cells for a single object instance as the row iterator processes it. They do **not** perform "navigation" — adding a second row widget does not display two different objects, it just arranges that one instance's cells across two rows.
- Generated markup for a row widget is a `<TR>` HTML tag.
- Within a Row Iterator, the object for the current row is referenced via the variable defined in the `elementName` property (e.g. when configuring a cell's `value`/`action`). As the iterator processes each object in the array in turn, `elementName` points to that object for the duration of that row's processing.

> Cross-reference: `elementName` was already noted as an `<InputIterator>` attribute in `/context/04-core-element-syntax.md`. Not yet confirmed whether "Row Iterator" is a distinct XML element (e.g. a hypothetical `<RowIterator>`) or simply describes how `<InputIterator>` behaves specifically in a List View context. See `/unresolved/01-open-questions.md`.

## The List View's Root Object — Important Nuance

Unlike a Detail View (whose root object is typically the single entity being displayed), a List View's root object is typically **the parent of the array, not the array itself**. Why: the parent entity automatically provides `addTo<ArrayName>` and `removeFrom<ArrayName>` functions, which are what make the List View editable later.

**Exception:** if there's no natural parent — e.g. the List View displays results of a database query — the root object is the set of elements itself, and there are **no** `addTo`/`removeFrom` functions available (so that List View can't use that mechanism to be made editable in the same way).

## Other Iterator Types (named, not yet syntax-confirmed)

The PCF architecture has several iterator types beyond the Row Iterator:
- **Menu item iterators** — take a set of objects, generate one menu item per object.
- **Panel Iterators** — take a set of objects, generate one panel (typically a Detail View) per object.
- **PolicyCenter Coverage Iterators** — take a set of coverages tied to a covered item (e.g. a vehicle), generate one coverage input per coverage.

None of these have confirmed XML syntax yet — flagged in `/unresolved/01-open-questions.md` for resolution via real code.

## Reusable vs. Inline (parallels Detail View exactly)

Same pattern as `/context/07-detail-views-inline-vs-reusable.md`:
- **Reusable:** List View Panel becomes its own top-level PCF file (filename convention ends in `LV`, per `/rules/01-naming-and-organization.md`), included elsewhere via `PanelRef`. Real example: `ABContactHistoryPage` (a Screen) includes `ABContactHistoryLV` via `PanelRef`.
- **Inline:** declared directly inside a `Screen`, `Card View Panel`, or `List Detail Panel`. Not referenceable by other files. Inherits its parent's root object (a variable can be defined for it, but this is uncommon).

## Containment Exception: Embedding a List View Inside a Detail View

Both Detail View and List View are **primary containers**. The general rule (see `/rules/03-container-nesting-constraints.md`) is that a primary container can only contain atomic widgets, not other containers — so you **cannot** use `PanelRef` to include a List View inside a Detail View.

**The workaround: `ListViewInput`.** This widget forces the List View to *behave as* an atomic widget:
- It can then be placed anywhere inside a Detail View's `InputColumn`.
- Because it behaves as an atomic widget, it can also take a **label**, the way a normal atomic widget can.

> Note: earlier material described "List View Input" simply as "an editable tabular display" (a contrast with the read-only "List View"). This module frames `ListViewInput` specifically as the mechanism for embedding a List View inside a Detail View by making it act atomic. These are likely the same widget serving both a structural purpose (embeddable-as-atomic) and a behavioral one (editable) — but exact attribute syntax for `ListViewInput` has not been seen in real code yet. Don't assume full behavior until confirmed. See `/unresolved/01-open-questions.md`.

## Toolbar Placement (reinforces `/rules/04-toolbar-placement-and-edit-workflow.md`)

This module repeats, independently, the same toolbar placement rules already captured from the Detail View module — same "can be directly added to Screen/PanelRef/List View Input," "can be associated with Detail/Card/List Detail/List View Panels," "not directly placeable on an Input Set" pattern. Treat `/rules/04` as doubly confirmed; no changes needed there.
