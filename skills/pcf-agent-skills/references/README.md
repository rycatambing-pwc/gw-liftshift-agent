# PCF Agent Skills

Step-by-step task guides for common PCF operations. Each skill encodes a repeatable pattern extracted from real `.pcf` files or validated against Guidewire documentation.

## Available Skills

| # | Skill | Task |
|---|-------|------|
| 01 | `building-a-cardview-summary-panel` | Build a tabbed CardView summary screen for an entity |
| 02 | `hidden-default-list-view-filter` | Apply a silent always-on filter to a query-backed ListView |
| 03 | `navigate-to-existing-popup` | Wire a field/link to open an existing Popup via `.push()` |
| 04 | `creating-a-page` | Add a new Page to a Location Group (6-step checklist) |
| 05 | `optimizing-expensive-expressions` | Identify and fix PCF expression performance anti-patterns |
| 06 | `adding-fields-to-detail-view` | Add input fields to an existing Detail View |
| 07 | `building-a-popup` | Create a Popup with data-return (view/edit, create-new, search) |
| 08 | `wiring-a-toolbar-button` | Add a ToolbarButton with correct placement and action |
| 09 | `creating-a-reusable-input-set` | Extract shared fields into a reusable InputSet |
| 10 | `adding-a-card-to-cardview` | Add a new tab to an existing CardViewPanel |

## Design Principles

- Skills should come from real `.pcf` files or validated patterns, not documentation alone
- Each skill includes: when to use, steps, worked example (where applicable), completion checklist, cross-references
- Cross-references link to context files and rules for deeper knowledge

## Future Candidates

- Building an editable List View (Add/Remove pattern with inline vs popup creation)
- Creating a Wizard with multi-step screens
- Wiring a PickerInput to a search Popup
- Adding mode variants to an existing shared panel
- Building a ListDetailPanel (master-detail pattern)
