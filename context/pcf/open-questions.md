# PCF Open Questions

Index of PCF facts that are not yet confirmed from real project code. Each entry links back to the file that raised it. When a question is resolved, record the answer and the evidence (file path in the project), then update the source file.

Most of these can be settled from the PCF Format Reference shipped with the installation: `modules/pcf.html` (per-element / per-attribute reference) and `modules/pcf.xsd` (schema), both present in this project.

## Open

| # | Question | Raised in |
|---|---|---|
| 1a | Does `PanelSet` map to Card, a Secondary/Primary container, or a separate mechanism? | `.claude/context/pcf/02-element-hierarchy-and-containers.md` |
| 1b | `available=` vs `visible=` on `ToolbarButton` — which is correct for this pattern? The real-code example uses `available`. | `.claude/skills/pcf-agent-skills/references/01-building-a-cardview-summary-panel.md` |
| 2 | Is "Row Iterator" a distinct XML element (`<RowIterator>`) or `<InputIterator>` used inside a List View? | `.claude/context/pcf/08-list-view-architecture.md` |
| 3 | Exact XML syntax of the List View structural elements listed in the architecture file. | `.claude/context/pcf/08-list-view-architecture.md` |
| 4 | Exact attribute syntax of `ListViewInput` (placement rule is confirmed; syntax is not). | `.claude/context/pcf/08-list-view-architecture.md`, `.claude/rules/pcf-agent-rules/03-container-nesting-constraints.md` |
| 5 | Creation-popup mechanics: PCF syntax for returning a new object from a Popup to the caller's array. | `.claude/context/pcf/16-popup-use-cases-and-data-flow.md`, `.claude/rules/pcf-agent-rules/04-toolbar-placement-and-edit-workflow.md` |
| 6 | Does a Location Group menu link's `location` attribute use the same `EntryPoint.method(objectList)` syntax as `action`? | `.claude/context/pcf/15-pages-visibility-and-editability.md`, `.claude/skills/pcf-agent-skills/references/04-creating-a-page.md` |
| 7 | Custom Location Group naming: `MyCustom_ExtGroup` or `MyCustomGroup_Ext`? | `.claude/context/pcf/14-location-groups.md`, `.claude/rules/pcf-agent-rules/06-navigation-syntax.md` |
| 8 | Is a Studio "PCF package" the same as the `job` / `policy` / `policyfile` folders? | `.claude/context/pcf/06-folder-and-package-structure.md` |
| 9 | Location-type summary table (navigation method, initial display, UI component) was not transcribed from the source module. | `.claude/context/pcf/13-navigating-to-locations.md` |
| 10 | Complete attribute-level schema for the elements in the core syntax reference. | `.claude/context/pcf/04-core-element-syntax.md`, `.claude/tools/pcf/01-inspection-and-debugging.md` |

## Resolved

| # | Question | Answer | Evidence |
|---|---|---|---|
| R1 | Is the PCF Format Reference `pcf.html` or `pcf.htm`? | `pcf.html` | `modules/pcf.html` exists in this project (raised in `.claude/context/pcf/17-dynamic-ui-and-post-on-change.md`) |
| R2 | Attribute name used by `PanelRef` to point at its target (`ref=`, `panelName=`, or none)? | `def=` — the earlier guesses do not appear in real code | `.claude/context/pcf/05-shared-sections-and-modes.md` (resolution note) |
