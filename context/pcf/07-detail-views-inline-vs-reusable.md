# Detail Views: Structure, and Inline vs. Reusable Containers

Source: Guidewire Education module (highest confidence). This resolves *why* the `Require`/`PanelRef def=` mechanism (see `/context/05-shared-sections-and-modes.md`) exists.

## What a Detail View Is

A Detail View lets users view a single instance of an object on screen. Per this module's opening summary, it can include inputs, links, cards, panels, input headers, and input footers.

> ⚠️ WATCH: this "cards" mention appears to conflict with the established nesting model (`/context/02-element-hierarchy-and-containers.md` and real project code), where Detail View is a **primary container** that holds Input Columns/atomic widgets — not Cards, which are a **secondary** container one tier up. This may just be loose introductory phrasing rather than a real structural allowance. Treat as unconfirmed; don't design a Detail-View-containing-a-Card pattern without verifying against real code first.

## Input Column Requirement

A Detail View must have **at least one `<InputColumn>`**, which holds atomic widgets in a vertical layout. More than one InputColumn can be used to arrange widgets horizontally. Conceptually, a Detail View is an InputColumn *container* — the InputColumn is what actually organizes layout and input widgets.

## The Core Distinction: Inline Widget vs. Reusable PCF File

Any container (e.g. a Detail View Panel) can be implemented one of two ways:

### Inline (not reusable)
- Declared as a **child element directly inside a parent** PCF (e.g. defined right inside a `Screen` or `Card`).
- **Cannot be referenced by other PCF files** — nothing else can point to it.
- **Inherits its root object from its parent** rather than declaring its own. (You *can* define a variable for an inline Detail View widget, but this is uncommon.)
- In Guidewire Studio's editor, everything inline shows the same color (all defined in the one file — see the "gray/blue overlay" convention in `/tools/01-inspection-and-debugging.md`).

### Reusable PCF File
- The container becomes its **own top-level PCF file** — do this when the container is likely needed in more than one place.
- **Declares its own root object** as an input parameter — this is exactly what `<Require>` does (see `/context/05-shared-sections-and-modes.md`). A reusable Detail View file needs `<Require>` because, unlike an inline container, it has no parent to inherit a root object from.
- Filename convention: ends in **`DV`** (consistent with the `_ExtDV` auto-suffix rule in `/rules/01-naming-and-organization.md`).
- Other PCF files include it via a **`PanelRef`** widget, which names the file and passes the required argument(s) — i.e. `<PanelRef def="SomeName_ExtDV(rootObjectVariable)"/>`.

## Worked Example: ABContactSummary (matches real project code)

This module's own teaching example is structurally identical to the real `.pcf` file already captured in `/skills/01-building-a-cardview-summary-panel.md` — good independent confirmation of that pattern.

**Inline version:** `ABContactSummaryScreen.pcf` declares root object `anABContact : ABContact`, then directly nests a Card → Detail View → InputColumn → atomic widgets, all inline in the one file. Only the Screen itself is reusable; everything inside it is not.

**Reusable version:** `ABContactSummaryScreen.pcf` declares the same root object and adds a Card, but instead of nesting the Detail View inline, a separate file `ABContactSummaryDV.pcf` is created with its **own** `anABContact : ABContact` root object declaration, its own InputColumn and atomic widgets — then included back into the Screen's Card via `PanelRef`, passing the root object through.

## When to Choose Which

- **Use inline** when the container is specific to one screen and won't be reused elsewhere.
- **Use a reusable PCF file** when the same view is (or is likely to be) needed in multiple places — e.g. the same contact summary shown in both a search-results detail panel and a main contact page.
