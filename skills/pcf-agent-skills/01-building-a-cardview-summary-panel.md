# Skill: Building a CardView Summary Panel

Based on a real, working pattern from the project (generalized from an actual `.pcf` file). Use this as the template shape when asked to build a tabbed summary screen that shows multiple views of related data for a single entity.

## When to use this pattern

The user wants a multi-tab ("Card") summary view for an entity — e.g. a contact, policy, or claim — where each tab shows a different slice of that entity's data (a detail view, a list of related records, a custom section).

## Structure

1. **Root:** `<CardViewPanel>` with a unique `id`.
2. **Declare the input parameter** the whole panel needs via `<Require name="..." type="..."/>` — this is the entity the summary is about (e.g. a Contact, Policy, Claim).
3. **One `<Card>` per tab**, each with a unique `id` and a `title` using `DisplayKey.get("...")` — never a hardcoded string.
4. **Inside each `<Card>`**, either:
   - Reference an existing reusable Detail View or List View via `<PanelRef def="TargetPanel_ExtDV(entityVariable)"/>` or `..._ExtLV(entityVariable)`, passing the entity variable declared in step 2, matching that target panel's own `<Require>`.
   - Or build content directly inline with `<DetailViewPanel>` → `<InputColumn>` → `<Label>`/input widgets, if there's no reusable panel yet.
5. **To add extra actions to an included panel** without modifying the shared panel itself, wrap the `<PanelRef>` around a `<Toolbar>` containing `<ToolbarButton>` elements.

## Worked Example (generalized from real project code)

```xml
<?xml version="1.0"?>
<PCF
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:noNamespaceSchemaLocation="../../../../../../pcf.xsd">
  <CardViewPanel
    id="EntitySummaryCV">
    <Require
      name="anEntity"
      type="EntityType"/>

    <Card
      id="Basics"
      title="DisplayKey.get(&quot;Web.EntityDetail.PageLinks.Basics&quot;)">
      <PanelRef
        def="EntitySummary_ExtDV(anEntity)">
        <Toolbar>
          <ToolbarButton
            action="my.package.MyUtil.doSomething(anEntity)"
            available="CurrentLocation.InEditMode"
            id="MyCustomActionButton"
            label="DisplayKey.get(&quot;My.CustomAction&quot;)"/>
        </Toolbar>
      </PanelRef>
      <PanelRef
        def="RelatedItems_ExtLV(anEntity)">
        <Toolbar/>
      </PanelRef>
    </Card>

    <Card
      id="AdditionalInfo"
      title="DisplayKey.get(&quot;My.AdditionalInfo&quot;)">
      <DetailViewPanel>
        <InputColumn>
          <Label
            label="DisplayKey.get(&quot;My.SomeStaticNote&quot;)"/>
        </InputColumn>
      </DetailViewPanel>
    </Card>
  </CardViewPanel>
</PCF>
```

## Rules this pattern must satisfy (cross-reference)

- Every custom file/panel referenced (`EntitySummary_ExtDV`, `RelatedItems_ExtLV`) must follow the `_Ext` + framework-auto-suffix naming convention (`/rules/01-naming-and-organization.md`).
- All titles/labels use `DisplayKey.get(...)` — never hardcoded text (`/rules/02-code-and-content-practices.md`).
- Every `Card`, `PanelRef`'s target, and `ToolbarButton` needs a unique, descriptive `id`.
- `Card` is a **secondary container** — it cannot directly hold atomic widgets, only primary containers (`DetailViewPanel`, `PanelRef`-included views) — consistent with `/context/02-element-hierarchy-and-containers.md`.

## Open item affecting this skill

`available=` vs `visible=` on `ToolbarButton` — this example uses `available`; earlier sourced material used `visible`. Default to `available` when following this real-code pattern until the distinction is confirmed (see `/unresolved/01-open-questions.md`, item 1b).
