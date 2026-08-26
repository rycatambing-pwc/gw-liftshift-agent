# Input Sets

Source: Guidewire Education module (highest confidence). This is the third confirmed instance of the same inline-vs-reusable-PCF-file pattern seen for Detail Views (`/context/07-detail-views-inline-vs-reusable.md`) and List Views (`/context/08-list-view-architecture.md`) — Guidewire applies this pattern consistently across container types.

## What an Input Set Is

A collection of atomic widgets organized into a logical group, letting developers reuse the same content (and layout) across multiple places. Confirms and reinforces the nesting rules already in `/rules/03-container-nesting-constraints.md`:

- Input Sets **must** be embedded into Detail View Panels.
- Input Sets are **not** referenced by secondary views (Card, List Detail Panel).
- Input Sets do **not** have a toolbar directly associated with them.

**New in this module:** an `InputSet` widget can be defined inside a **Detail View Panel or another Input Set** — i.e. Input Sets can nest inside other Input Sets, not just inside Detail Views.

**New constraint:** unlike Detail View Panels (which require at least one `InputColumn`), **Input Sets cannot contain columns.**

## Reusable vs. Inline (same pattern as Detail/List Views)

### Inline
- Declared directly inside a Detail View Panel or another Input Set.
- Not referenceable elsewhere.
- Inherits its parent's root object (a variable can be defined for it, but this is uncommon).

### Reusable PCF File
- Becomes its own top-level PCF file, with its **own root object** declared (via `<Require>` — see `/context/05-shared-sections-and-modes.md`).
- Included elsewhere via the **`InputSetRef`** widget — analogous to `PanelRef`, specifying the file name and passing the required argument(s).
- Create as a reusable file when the same set of widgets is needed in multiple places.

**Worked example (ABCompanyDetails), inline version:**
1. Create `ABCompanyDetailsScreen.pcf`, declare root object `anABContact : ABContact`.
2. Add a Card View.
3. Add a Detail View Panel.
4. Add the Input Set and its atomic widgets, all inline — everything shows the same color in Studio (all one file); only the Screen itself is reusable.

**Reusable version:**
1. Create `ABCompanyDetailsScreen.pcf`, declare the same root object, add the Card View.
2. Create a separate file, e.g. `ContactInsightInputSet.pcf`, with its **own** `anABContact : ABContact` root object declaration and its own atomic widgets.
3. Include it back into the Screen via `InputSetRef`, passing the root object through.

## The Real Value-Add: Cascading Visibility/Editability

Reusability and shared-logic are **not mutually exclusive** benefits — an Input Set can do both at once.

An Input Set can carry a **single `visible` or `editable` property that applies to every widget it contains.** This means you don't need to set that property individually on each widget in the group — set it once on the Input Set, and it cascades.

**Practical case:** if two cards (e.g. "Basics" and "Person Info") need to show the same fields in the same order and with the same visibility/editability logic, put those fields in one Input Set and reuse it in both places — if the order changes or a widget is inserted, updating the one Input Set file updates every place it's used, and a single condition change (e.g. "hide this whole group unless the user has permission X") applies everywhere at once instead of needing to be repeated per-widget, per-location.

## Performance Note

Because an Input Set's contents can be updated as a unit, updating only that Input Set's HTML (rather than a larger surrounding region) can significantly improve performance for dynamic/partial page updates. Full mechanics of dynamic updates are a later topic — flagged for whenever that module comes in.
