# PCF Element Hierarchy and Container Model

Source: Guidewire Education modules 1 & 2 (highest confidence). This is the core mental model for how any PCF page is structured.

## Widgets: Atomic vs. Container

**Widgets** are displayable PCF elements rendered into HTML. They split into two kinds:

- **Atomic Widgets** — individual field items (inputs, cells, buttons). The smallest UI building block. Each displays one data value or executes one action. Widgets can specify view/edit permissions for the logged-in user.
- **Container Widgets** — collections of atomic widgets and/or other container widgets, organizing data and functionality into logical groups.

Examples of Container Widgets: `Screen`, `List Detail Panel`, `Card`, `Detail View`, `List View`, `Input Set`.

## The Four-Tier Containment Hierarchy

| Tier | What it is | Can directly contain | Can be contained by |
|---|---|---|---|
| **1. Atomic Widgets** | Inputs, cells, buttons | Nothing (lowest level) | **Only primary containers** |
| **2. Primary Views** — Detail View, List View | Reusable views organizing atomic widgets | Atomic widgets directly. Detail View can contain List View, but **not vice versa**. | Screen and secondary containers |
| **3. Secondary Views** — Card, List Detail Panel | Organize primary containers | Primary containers directly, and **other secondary views** | Screen |
| **4. Screen** | Top-level container | Primary views and secondary views directly (not atomic widgets directly) | Locations |

### Primary Container Details

- **Detail View (Detail View Panel):** a series of data fields in one or more columns. Any input widget can appear inside. Can show a single object's data or data from multiple related objects. Referenceable by screens and secondary containers.
- **List View (List View Panel):** tabular display of multiple records. Uses a small set of atomic widgets to show the most relevant fields per row. Referenceable by screens and secondary containers.
- **Input Set — the exception:** behaves like a primary view (contains atomic widgets, groups them for reuse, lets you apply shared visibility/editability rules) but:
  - Must be embedded inside a **Detail View Panel** — cannot be directly referenced by a Screen or a secondary container.
  - Cannot have a toolbar directly attached to it.

### Secondary Container Details

- **Card (Card View):** a collection of cards, each containing Detail Views or List Views.
- **List Detail Panel:** a List View in the top panel; the bottom panel shows detail for whichever row is selected in the top list.

### Top-Level Container

- **Screen:** every atomic widget, primary view, and secondary view is contained in a screen, directly or indirectly. Screens are referenced by Locations (see `03-locations-reference.md`).

## Open Mapping Question

`PanelSet` (a reusable, mode-aware panel shared across job-wizard and policy-file screens — heavily used in real PolicyCenter line-of-business PCFs) does not appear by that name anywhere in the Education modules' container list above. It has not been confirmed whether it equals "Card," is a variant of a Secondary or Primary container, or is a distinct mechanism layered on top of this hierarchy. **Do not assume a mapping — treat as unresolved until real project code or a later module confirms it.** See `/unresolved/01-open-questions.md`.
