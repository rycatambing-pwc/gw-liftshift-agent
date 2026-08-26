# Shared Sections and Modes

Source: Guidewire public documentation. The conceptual explanation here is coherent and uncontradicted; only the exact XML mechanism for referencing a shared section (`<PanelRef>`) is unresolved (see below).

## Concept

A **shared section** is a reusable PCF file (typically a PanelSet) that can be dynamically included in multiple parent PCF files — e.g. a Driver Details panel shared between a job-wizard screen and a policy-file screen. This avoids duplicating UI definitions and keeps updates centralized.

A **mode** is a variant of a shared section that renders differently depending on context (e.g. `submission` vs. `policychange` vs. `viewonly`) — same underlying section, different behavior/fields/editability per mode.

**Mode-matching rule:** whatever includes a shared section must specify the same mode the shared section itself declares. Mismatched modes fail at runtime.

Guidewire Studio requires unique file names, so different mode variants of the "same" conceptual content are typically implemented as separate files (e.g. `DriverDetailsSubmission_ExtPanelSet.pcf` and `DriverDetailsPolicyChange_ExtPanelSet.pcf`) rather than one file serving multiple modes at once.

## Best Practices

- Use descriptive mode names (`"submission"`, `"policychange"`, `"viewonly"`) — not generic ones (`"mode1"`).
- If a PanelSet needs more than ~3–4 distinct modes, consider splitting into separate purpose-built PanelSets instead.
- Document which modes exist and where they're used, via comments in the PCF.

> ✅ CONFIDENCE UPDATE: the `submission`/`policychange`-style mode name examples above were originally sourced from a lower-confidence Documentation Assistant batch. A later, higher-confidence Guidewire Education module (`/context/20-modes-dispatch-and-defaults.md`) independently confirmed that PolicyCenter uses modes for exactly this purpose — transaction type variations (submission, change, renewal, cancellation). Treat this specific naming pattern as confirmed. See that file also for full mode-dispatch mechanics (subtype-based exact-type matching, default fallback, and the three-part mode naming convention in `/rules/01-naming-and-organization.md`).

## RESOLVED: The Actual Reference Mechanism — `def=`

Confirmed from a real project `.pcf` file. The correct attribute is **`def`**, and its value is a **function-call-style reference**: the target panel's name followed by parentheses containing the argument(s) it requires.

```xml
<PanelRef def="ABContactAnalysis_ExtDV(anABContact)"/>
```

This works together with a `<Require>` declaration in the **target** panel file, which declares what input(s) it expects:

```xml
<Require name="anABContact" type="ABContact"/>
```

So `PanelRef def="TargetName(argumentExpression)"` is effectively "call this reusable panel, passing it this variable/expression to satisfy its `Require`."

### `PanelRef` can also wrap additional content

A `PanelRef` isn't always self-closing — it can have child content, most commonly a `<Toolbar>`, to **append extra buttons to the included panel** at the point of inclusion (rather than needing to define them in the shared panel itself):

```xml
<PanelRef def="ABContactSummaryDV(anABContact)">
  <Toolbar>
    <ToolbarButton
      action="trainingapp.base.AssignedUserUtil.selectLeastBusyUser(anABContact)"
      available="CurrentLocation.InEditMode"
      id="SuggestLeastBusyUserButton"
      label="DisplayKey.get(&quot;Training.SuggestLeastBusyUser&quot;)"/>
  </Toolbar>
</PanelRef>
```

An empty `<Toolbar/>` inside a `PanelRef` is also valid — it simply adds no extra buttons.

**Resolution note:** neither of the two earlier guessed attribute names (`ref=`, `panelName=`) appear in real code. The earlier "anonymous, attribute-less `PanelRef`" observation (from an isolated release-notes diff snippet) likely just reflected a truncated/partial view of a larger element that did have a `def=` attribute outside the visible diff — not a genuinely different, attribute-less usage. Full history preserved in `/unresolved/01-open-questions.md` for audit purposes.

### Mode mechanism vs. `def`/`Require`

Note this real example does **not** use the `mode=` attribute described earlier in this file — it uses `def`+`Require`-based parameterization instead. It's not yet confirmed whether `mode` and `def`/`Require` are two different, coexisting mechanisms (e.g. `mode` for layout/field variants, `def`/`Require` for passing data) or whether the `mode` attribute description from public documentation was itself imprecise. Treat the `def`/`Require` mechanism above as confirmed-by-real-code (higher confidence); treat `mode` as documented-but-not-yet-seen-in-real-code (lower confidence) until it turns up in actual project files.
