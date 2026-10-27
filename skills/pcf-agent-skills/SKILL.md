---
name: pcf-agent-skills
description: Step-by-step recipes for common Guidewire PolicyCenter PCF tasks - building a CardView summary panel or adding a card to one, applying a hidden default List View filter, navigating to or building a Popup, creating a Page in a Location Group, adding fields to a Detail View, wiring a ToolbarButton, extracting a reusable Input Set, and fixing expensive PCF expressions. Use when creating or changing PCF screens, widgets or navigation.
---

# PCF Task Recipes — Router

## How to use

1. Match the request to one row in the table below.
2. Read that task file (in this folder) before writing any PCF.
3. Read the rules and context files listed on the same row — they are the ones the recipe relies on. Do not bulk-load the whole `context/pcf/` folder.
4. If no row fits, use the context trigger map in `gw-pcf-agent` (`.claude/agents/gw-pcf-agent.md`, "Project PCF Reference").

Paths starting with `.claude/` are relative to the project root. Task files are in this skill's folder.

## Task routing

| Request | Task file | Rules (`.claude/rules/pcf-agent-rules/`) | Context (`.claude/context/pcf/`) |
|---|---|---|---|
| Build a tabbed summary screen with `CardViewPanel` | `references/01-building-a-cardview-summary-panel.md` | 01, 02 | 02 |
| Silent always-on filter on a query-backed List View | `references/02-hidden-default-list-view-filter.md` | 05 | 08, 10 |
| Open an existing Popup from a field or link (`.push()`) | `references/03-navigate-to-existing-popup.md` | 06 | 03, 05, 13 |
| Add a new Page to a Location Group | `references/04-creating-a-page.md` | 04, 06 | 05, 15 |
| Find and fix expensive PCF expressions | `references/05-optimizing-expensive-expressions.md` | 08 | 17, 18, 19 |
| Add input fields to an existing Detail View | `references/06-adding-fields-to-detail-view.md` | 01, 07, 09 | 07, 17, 22 |
| Create a Popup with a data-return contract | `references/07-building-a-popup.md` | 01, 04, 06 | 13, 16 |
| Add a `ToolbarButton` with correct placement and action | `references/08-wiring-a-toolbar-button.md` | 01, 04 | 05, 13 |
| Extract shared fields into a reusable `InputSet` | `references/09-creating-a-reusable-input-set.md` | 01, 02, 03 | 12 |
| Add a tab to an existing `CardViewPanel` | `references/10-adding-a-card-to-cardview.md` | 01, 03, 04 | 05 (+ task 01 as the base pattern) |

## Rule files

| # | File |
|---|---|
| 01 | `.claude/rules/pcf-agent-rules/01-naming-and-organization.md` |
| 02 | `.claude/rules/pcf-agent-rules/02-code-and-content-practices.md` |
| 03 | `.claude/rules/pcf-agent-rules/03-container-nesting-constraints.md` |
| 04 | `.claude/rules/pcf-agent-rules/04-toolbar-placement-and-edit-workflow.md` |
| 05 | `.claude/rules/pcf-agent-rules/05-list-view-performance.md` |
| 06 | `.claude/rules/pcf-agent-rules/06-navigation-syntax.md` |
| 07 | `.claude/rules/pcf-agent-rules/07-dynamic-ui-practices.md` |
| 08 | `.claude/rules/pcf-agent-rules/08-performance-expensive-expressions.md` |
| 09 | `.claude/rules/pcf-agent-rules/09-validation-expressions.md` |

## Context files

| # | File |
|---|---|
| 02 | `.claude/context/pcf/02-element-hierarchy-and-containers.md` |
| 03 | `.claude/context/pcf/03-locations-reference.md` |
| 05 | `.claude/context/pcf/05-shared-sections-and-modes.md` |
| 07 | `.claude/context/pcf/07-detail-views-inline-vs-reusable.md` |
| 08 | `.claude/context/pcf/08-list-view-architecture.md` |
| 10 | `.claude/context/pcf/10-view-entities-and-performance.md` |
| 12 | `.claude/context/pcf/12-input-sets.md` |
| 13 | `.claude/context/pcf/13-navigating-to-locations.md` |
| 15 | `.claude/context/pcf/15-pages-visibility-and-editability.md` |
| 16 | `.claude/context/pcf/16-popup-use-cases-and-data-flow.md` |
| 17 | `.claude/context/pcf/17-dynamic-ui-and-post-on-change.md` |
| 18 | `.claude/context/pcf/18-post-on-change-implementation-and-performance.md` |
| 19 | `.claude/context/pcf/19-expensive-expressions.md` |
| 22 | `.claude/context/pcf/22-validation-expressions.md` |

Unconfirmed PCF facts are tracked in `.claude/context/pcf/open-questions.md`. The full PCF attribute reference and schema are `modules/pcf.html` and `modules/pcf.xsd` in the project.
