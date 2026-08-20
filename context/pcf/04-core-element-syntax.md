# Core PCF Element Syntax Reference

Source: Guidewire public documentation, filtered to only uncontradicted, concretely-sourced examples (several came from a real release-notes diff file, `APDRiskPanelSet.pcf`, which gives higher confidence than narrative-only descriptions). Cross-checked against Education modules where they overlap.

> This is a partial reference. The authoritative, complete attribute-level schema is `modules/pcf.html` in an actual InsuranceSuite installation — not yet obtained. Treat this file as "known-good examples," not an exhaustive spec. See `/unresolved/01-open-questions.md`.

## Root Element

```xml
<PCF>
  <!-- PCF elements go here -->
</PCF>
```

## Display Keys — `<Text>`

Static, localizable text for labels/buttons/titles, referenced by ID elsewhere in the PCF:

```xml
<Text id="ClaimSearchTitle" value="Search Claims"/>
```

## Non-visible Logic — `<Code>`

Contains Gosu code for background operations/initialization/validation. **Rule: keep this minimal** — see `/rules/02-code-and-content-practices.md`.

## Variables — `<Variable>`

Holds a reference to an entity or data value during rendering, bound to a Gosu expression:

```xml
<Variable id="claimVar" value="claim"/>
```

## Editors / Inputs

```xml
<TextInput value="claim.claimNumber"/>
```

## Structural / Container Elements (confirmed from real PCF diff example)

- **`<Card>`** — attributes: `id`, `title`, `visible`
- **`<DetailViewPanel>`** — detail-display panel
- **`<InputColumn>`** — organizes inputs into a column layout
- **`<InputIterator>`** — iterates over a collection to render repeated inputs; attributes: `elementName`, `id`, `value`, `valueType`
- **`<InputSet>`** — groups related inputs (see hierarchy rules in `02-element-hierarchy-and-containers.md`)

## Buttons — `<ToolbarButton>`

Must be nested inside a `<Toolbar>`. Confirmed real example:

```xml
<Toolbar>
  <ToolbarButton
    action="APDNewExposurePopup.push(riskCoverable)"
    hideIfReadOnly="true"
    id="addExposureButton"
    label="DisplayKey.get(&quot;Web.Policy.ManualLine.RiskExposure.Add&quot;)"
    visible="userPreferences.canDesign() and not isCloudProduct"/>
</Toolbar>
```

| Attribute | Purpose |
|---|---|
| `id` | Unique identifier |
| `label` | Display label, typically via `DisplayKey.get(...)` |
| `action` | Gosu expression run on click |
| `hideIfReadOnly` | Hides button in read-only mode |
| `visible` | Gosu boolean expression controlling visibility |

## List Views

- **List View** — read-only tabular display
- **List View Input** — editable tabular display
- **List Detail Panel** — pairs a list with a detail panel for the selected row (see hierarchy doc)

## Panel Inclusion — `<PanelRef>` (CONFIRMED from real project code)

```xml
<PanelRef def="ABContactAnalysis_ExtDV(anABContact)"/>
```

- `def` — the target panel's name plus a parenthesized argument expression satisfying that panel's `<Require>` declaration.
- Can optionally contain a nested `<Toolbar>` to append extra buttons to the included panel at the inclusion site.

See `/context/05-shared-sections-and-modes.md` for full detail and the related `<Require>` mechanism below.

## Parameterization — `<Require>` (CONFIRMED from real project code)

Declares an input parameter a PCF file/panel expects, enabling it to be reused with different data:

```xml
<Require
  name="anABContact"
  type="ABContact"/>
```

Whatever includes this panel via `PanelRef def="..."` must supply a matching argument.

## Card View Structure (CONFIRMED from real project code)

The real root element for a "Card View" (Secondary Container) is `<CardViewPanel>`, containing one or more `<Card>` children:

```xml
<CardViewPanel id="ABContactSummaryCV">
  <Require name="anABContact" type="ABContact"/>
  <Card id="Basics" title="DisplayKey.get(&quot;Web.ContactDetail.PageLinks.Basics&quot;)">
    <PanelRef def="ABContactSummaryDV(anABContact)"/>
  </Card>
</CardViewPanel>
```

- `<Card>` attributes confirmed: `id`, `title` (typically a `DisplayKey.get(...)` expression)
- A `<Card>` can directly contain `<PanelRef>` elements (referencing Detail/List Views) or a `<DetailViewPanel>` directly with its own `<InputColumn>`/`<Label>` children.

## Labels — `<Label>` (CONFIRMED from real project code)

A simple atomic widget for static, non-input text within a Detail View:

```xml
<Label label="DisplayKey.get(&quot;Training.InstructorComplete&quot;)"/>
```

## Note: `available=` vs `visible=` on ToolbarButton

Real code shows `available="CurrentLocation.InEditMode"` on a `ToolbarButton`, while earlier sourced examples showed `visible="userPreferences.canDesign() and not isCloudProduct"`. Both appear to be legitimate Gosu-boolean-expression attributes, but it is **not yet confirmed** whether they mean the same thing (redundant naming) or serve different purposes (e.g. `visible` = shown/hidden vs. `available` = enabled/disabled while still shown). Treat as functionally similar but distinct until confirmed — do not assume interchangeable.
