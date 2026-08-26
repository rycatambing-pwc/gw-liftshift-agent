# PCF Agent — Knowledge Base

Context, rules, skills, and tools for a Claude Code agent specializing in Guidewire PCF (Page Configuration Format) development.

## How this is organized

- **`context/`** — background/reference knowledge. What things are, how they relate, how they work conceptually. 22 files.
- **`rules/`** — firm, checkable conventions. "Always/never" statements. Violating these produces invalid PCF or real upgrade/performance problems, not just style issues. 9 files.
- **`skills/`** — step-by-step, task-shaped workflows for concrete jobs ("build X," "wire up Y"). 5 real skills + 1 README.
- **`tools/`** — debugging/inspection aids (keyboard shortcuts, editor conventions).
- **`unresolved/`** — things that are NOT yet confirmed fact. Don't treat anything in here as ground truth; it's a tracking list of open questions and their resolution status.

## Context Index

| # | File | Covers |
|---|---|---|
| 01 | pcf-overview | What a PCF is, XSD validation, MMC principle, Widget/Location split |
| 02 | element-hierarchy-and-containers | Atomic/Container widgets, 4-tier nesting model |
| 03 | locations-reference | Page, Location Group, Wizard, Popup, Worksheet, Forward, Exit Point |
| 04 | core-element-syntax | Confirmed XML syntax: Text, Code, Variable, Card, ToolbarButton, PanelRef, Require, etc. |
| 05 | shared-sections-and-modes | Mode concept, mode-matching rule |
| 06 | folder-and-package-structure | Folder layout per product, APD-generated file naming |
| 07 | detail-views-inline-vs-reusable | Inline vs. reusable PCF file pattern (Detail View) |
| 08 | list-view-architecture | Root object semantics, row iterators, reusable List Views |
| 09 | list-view-editability | Editable hierarchy, Add/Remove button rules, editable patterns |
| 10 | view-entities-and-performance | View Entities, query-backed List Views, perf fixes |
| 11 | list-view-filtering | Toolbar Filter widget, hidden default filters |
| 12 | input-sets | Input Set architecture, InputSetRef, cascading visibility/editability |
| 13 | navigating-to-locations | `.push()`/`.go()` navigation syntax |
| 14 | location-groups | Location Group structure, Entry Points, nesting levels |
| 15 | pages-visibility-and-editability | `canVisit`, `canEdit`, `locationref` |
| 16 | popup-use-cases-and-data-flow | Popup's 3 use cases, data return contracts |
| 17 | dynamic-ui-and-post-on-change | Static vs. dynamic properties, Post-on-Change basics |
| 18 | post-on-change-implementation-and-performance | Deep Post-on-Change mechanics, `deferUpdate`, `InputGroup` |
| 19 | expensive-expressions | The 4-category anti-pattern catalog |
| 20 | modes-dispatch-and-defaults | Mode dispatch (exact-type matching!), default fallback, mode naming |
| 21 | ui-field-validation | `regex` property, data-model vs. UI validation |
| 22 | validation-expressions | `validationExpression` vs `requestValidationExpression` |

## Rules Index

| # | File | Covers |
|---|---|---|
| 01 | naming-and-organization | `_Ext` conventions (files, IDs, modes), package placement |
| 02 | code-and-content-practices | Minimal Gosu, display keys, unique IDs, MMC, Input Set reuse, validation logic placement |
| 03 | container-nesting-constraints | What can legally contain what; Input Set and ListViewInput exceptions |
| 04 | toolbar-placement-and-edit-workflow | Where toolbars go; Edit/Update/Cancel; Add/Remove button logic |
| 05 | list-view-performance | View Entity extension over full-entity retrieval; filter-early |
| 06 | navigation-syntax | `EntryPoint.method(objectList)`; push vs go by target type |
| 07 | dynamic-ui-practices | When to use Post-on-Change vs. dynamic properties; `deferUpdate` ban |
| 08 | performance-expensive-expressions | PCF variables, Row Iterator hoisting, permission keys |
| 09 | validation-expressions | Default to `validationExpression`; return null/string only |

## Skills Index

| # | File | Task |
|---|---|---|
| 01 | building-a-cardview-summary-panel | Tabbed CardView summary screen (real-code-derived) |
| 02 | hidden-default-list-view-filter | Silent, always-applied List View filter |
| 03 | navigate-to-existing-popup | Wire a field/link to open an existing Popup |
| 04 | creating-a-page | 6-step new Page checklist |
| 05 | optimizing-expensive-expressions | Review/fix workflow for performance anti-patterns |

## Before Using This to Generate Real PCF

Check `/unresolved/01-open-questions.md` first. Notable open items as of this compilation:
- `PanelSet`'s exact place in the container hierarchy taxonomy
- Several minor naming-suffix and attribute-syntax gaps (List View Input widget, `locationref`'s `location` attribute syntax, navigation cell widgets)
- The full `modules/pcf.html`/`.htm` schema reference was never directly obtained — everything here is built from Education material, real project code, and (filtered/corrected) public documentation

## Provenance Note

Content is drawn from three tiers of source, in descending order of trust:
1. **Real project `.pcf` code** — highest confidence, used to resolve several conflicts.
2. **Guidewire Education modules** — high confidence, structured course material (majority of this knowledge base).
3. **Public Guidewire documentation, via a Documentation Assistant** — lower confidence; several early conflicts came from this tier and were resolved or flagged. Used mainly in the earliest files (context 01–11).

Where sources conflicted, resolution notes are preserved inline in the relevant file rather than silently overwritten, so the reasoning stays auditable.
