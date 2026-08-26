# Toolbar Placement Rules and the Edit/Update/Cancel Workflow

Source: Guidewire Education module (Detail Views lesson).

## What a Toolbar Is

A toolbar is a row of widgets associated with a container widget, letting the user take action on that container's data. Typically holds button widgets (e.g. Edit buttons); a toolbar associated with a List View Panel may have no buttons at all.

## Where Toolbars Can Go

| Relationship | Applies to |
|---|---|
| **Can be directly added to** | `Screen`, `PanelRef`, `List View Input` |
| **Can be associated with** | `Detail View Panel`, `Card View Panel`, `List Detail Panel`, `List View Panel` |
| **Cannot be directly placed on or referenced by** | `Input Set` |

**Rule:** if you need toolbar-driven actions in the context of an Input Set's data, don't attach a toolbar to the Input Set itself — an Input Set is normally referenced/placed inside an `InputColumn` within a `Detail View Panel`, so put the toolbar on the enclosing Detail View Panel (or the `PanelRef` that includes it) instead.

(Cross-reference: this is also consistent with the confirmed real-code pattern in `/skills/01-building-a-cardview-summary-panel.md`, where a `<Toolbar>` is nested directly inside a `<PanelRef>`.)

## The Standard Edit / Update / Cancel State Machine

This is the default behavior for a toolbar-driven edit workflow on a data-backed container:

| Action | Effect |
|---|---|
| **Edit** clicked | Input widgets switch from read-only → edit mode. An entry is added to the "unsaved" menu. |
| **Update** clicked | Changes are **committed** to the backing data object. Input widgets switch from edit mode → read-only. The entry is **removed** from the unsaved menu. |
| **Cancel** clicked | Changes are **discarded** (not committed). Input widgets switch from edit mode → read-only. The entry is **removed** from the unsaved menu. |

**Rule for any skill/generated PCF that implements editability:** don't invent custom edit-state logic from scratch — this Edit/Update/Cancel pattern is the standard mechanism, and toolbars implementing it should follow this exact state transition (mode switch + unsaved-menu entry add/remove) rather than a bespoke variant, unless there's a specific documented reason to deviate.

## Editable List View: Add/Remove Button Rules

For a List View made editable with Add/Remove (iterator) buttons — see full detail in `/context/09-list-view-editability.md`:

| Rule | Detail |
|---|---|
| Visibility (both buttons) | Only visible when the screen is in edit mode |
| Availability (both buttons) | Only available when their action is defined |
| Availability (Remove only) | Additionally requires at least one row selected in the List View |

**Toolbar placement recommendation:** Edit button → screen-level toolbar; Add/Remove buttons → the toolbar closest to the List View itself (may collapse into one toolbar on simpler screens — acceptable, not a violation).

**Add button pattern choice:** if the List View's visible columns cover everything needed at creation, insert a new empty row directly (edit in place). If the object has fields not shown in the List View, use a creation popup instead (mechanics not yet documented — see `/unresolved/01-open-questions.md`).
