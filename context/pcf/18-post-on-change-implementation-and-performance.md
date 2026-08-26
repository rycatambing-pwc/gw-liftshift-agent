# Post-on-Change: Implementation and Performance

Source: Guidewire Education module. Deep-dive companion to `/context/17-dynamic-ui-and-post-on-change.md` — read that one first for the conceptual basics.

## Enabling It

Widgets that support Post-on-Change have a **PostOnChange tab** in Guidewire Studio. Check **"Enable Post On Change"** on that tab to turn it on.

## What Actually Happens on Change (more precise than the earlier module)

When the trigger widget's value changes:
1. **All user-editable data on the screen** (not just the trigger field) is sent from the client browser to the application server.
2. **Nothing is committed** — this is purely a re-evaluation pass.
3. The server reevaluates the page using the posted values and identifies which widgets need to change as a result.
4. The server instructs the browser to **redraw only the widgets that actually changed** — not the whole page.

Post-on-Change affects only what's rendered in the browser. It never commits data.

## `disablePostOnEnter`

A Boolean expression property that lets you disable Post-on-Change for a widget **specifically when the screen is first entered** (as opposed to disabling it unconditionally). Example use case: testing the application locale to skip an update that only matters for specific locales/countries.

## Toggling Post-on-Change Per-Condition

You can conditionally disable/enable Post-on-Change for a specific widget based on other data — not just at screen-entry time.

**Real example:** an "Invoicing Method" field disables Post-on-Change entirely when the currency is not USD. When disabled this way: the widget doesn't announce its change, no round-trip occurs, the page isn't redrawn, and data isn't refreshed — it behaves as if Post-on-Change weren't configured at all, for that condition.

## `onChange` Calling a Gosu Function (real example)

The `onChange` property can invoke a Gosu function defined in an entity enhancement. Real example, from a `FlagEntry`'s resolution-field change, calling `setFieldsOnResolution()` defined in `FlagEntryEnhancement.gsx`:

```gosu
/* This function is called when a FlagEntry's resolution field
   is set. This function sets the UnflagDate and UnflagUser
   fields. This serves the role of a "FlagEntry Pre-Update"
   rule set.
*/
function setFieldsOnResolution() : void {
  this.UnflagDate = gw.api.util.DateUtil.currentDate()
  this.UnflagUser = User.util.getCurrentUser()
}
```

This is a real, working pattern: Post-on-Change triggering a "pre-update rule set"-style side effect via an entity enhancement function.

## `deferUpdate` — Legacy Only

`deferUpdate` exists to preserve legacy behavior for InsuranceSuite versions **prior to R10**. **Do not use this property when configuring a new Post-on-Change usage** — it's not a general-purpose option, it's a compatibility shim for old upgrades.

## Performance Best Practice #1: Prefer Simple Expressions Over Complex Method Calls in `onChange`

A plain expression in `onChange` performs better than calling a method that does complex processing. This isn't always avoidable — business requirements sometimes genuinely need the complex logic — but it should be a deliberate tradeoff, not an accident. Watch especially for onChange functions that include queries; those can visibly impact page performance.

## Performance Best Practice #2: Group Shared Conditions with `InputGroup`

**Problem:** if several individual fields each independently test the *same* condition (e.g. "is this a Rental service type?") to determine their own visibility/availability/editability, that condition gets evaluated once per field — each evaluation can trigger its own layout re-render, which slows page reload and can create a confusing, flickering UI where it's unclear what action the user should take.

**Fix:** group the related fields into an **`InputGroup`** widget, so the shared condition is tested **once** for the whole group, rather than repeatedly per individual field.

**Real example:** a screen with Appraisal and Rental checkboxes. If Rental is checked, the various rental-related fields should display together; if Appraisal is checked, the Initial Assessor field should display. Wrapping each condition's related fields in their own `InputGroup` means the "is this Rental?" test runs once for the whole rental field set, not once per rental field.

## Summary Principle

Whenever implementing Post-on-Change-driven dynamic behavior, think about actual usage patterns on the page — not just whether the behavior works, but whether it will cause excessive re-testing/re-rendering as currently structured. The fixes above (avoid complex onChange methods where possible; group shared-condition fields with `InputGroup`) are the standard levers for keeping dynamic behavior fast.
