# Navigating to Locations

Source: Guidewire Education module. Recap of Location types is consistent with `/context/03-locations-reference.md` — no new conflicts there. This module's genuinely new content is the **navigation method syntax**.

## Location Types (recap, matches `/context/03-locations-reference.md`)

Page, Popup, Worksheet, Location Group, Wizard, Forward, Exit Point. Locations don't define visual content themselves but can contain Screens that do.

## Navigation Method Syntax: `.push()` and `.go()`

A Location is navigated to via a Gosu method call on the Location's PCF name, typically inside an `action=` expression on an atomic widget (button, link, etc.):

```
<LocationName>.push(<argument>)
```

**Confirmed from real project code** (seen earlier in `/skills/01-building-a-cardview-summary-panel.md`'s source example):
```xml
action="APDNewExposurePopup.push(riskCoverable)"
```
— `.push()` is the call used to open a **Popup**, passing whatever argument the popup's root object requires.

**Wizard navigation differs by product** (per this module):
| Product | Typical Wizard navigation method |
|---|---|
| ClaimCenter | `go()` |
| PolicyCenter | `go()` |
| BillingCenter | `push()` |

> ⚠️ Don't conflate these two facts. "`.push()` opens a Popup" (confirmed by real code, general) and "`.push()` is BillingCenter's typical way to enter a Wizard" (from this module, product-specific, Wizard-only) are two separate, non-contradictory statements — not the same rule stated twice. Confirm which Location type and which product before assuming which method applies.

## Gap: Full Navigation-Method/Display Table Not Captured

The source module references "a table... summary of location types, their typical navigation method, what they initially display, and what component of the UI the initial display is located in" — but only the Wizard go()/push() note survived into these notes; the full table rows weren't transcribed. If you still have access to this table, it would be a valuable, compact reference to add (would likely resolve several small "how does X Location type actually get invoked" questions in one shot). Flagged in `/unresolved/01-open-questions.md`.

## Worked Pattern: Making a Field Navigate to an Existing Popup

Real scenario from this module: an "Assigned User" field on a contact should be clickable, opening an existing `UserDetailPopup.pcf` so an authorized user can view/edit that user's details.

Key point: if the popup **already exists** (including its own permission handling), the task is purely wiring the navigation — set the field's `action` to call `.push()` on the popup's name, passing whatever argument the popup requires as its root object. No new popup needs to be built, and no permission logic needs to be duplicated if the popup already handles it.

See `/skills/03-navigate-to-existing-popup.md` for the generalized skill version of this.
