# Skill: Adding a Card (Tab) to an Existing CardViewPanel

Step-by-step recipe for adding a new tab to an existing CardViewPanel without disrupting the other cards. This is common when extending a summary screen with a new data slice.

## When to use this pattern

- A requirement says "add a [new section] tab to the [Entity] summary screen"
- A new related entity or data view needs its own tab alongside existing tabs
- You're extending a base CardViewPanel with custom content

## Steps

1. **Locate the target CardViewPanel file.**
   - CardViewPanel IDs typically end with `CV` (e.g., `PolicySummaryCV`).
   - Use `pcf-find-usages` to find it if you only know the page name.
   - Check whether it's inline (inside a parent PCF) or reusable (own `.pcf` file).

2. **Determine insertion position.**
   - Cards render as tabs in left-to-right order as they appear in XML.
   - Place the new card at a logical position — typically at the end for new custom tabs, or grouped with related existing cards.

3. **Add the new `<Card>` element:**

   ```xml
   <Card
     id="CustomData_Ext"
     title="DisplayKey.get(&quot;Web.Policy.CustomData_Ext&quot;)"
     visible="perm.PolicyPeriod.view(policyPeriod)">

     <!-- Card content goes here -->

   </Card>
   ```

   Required attributes:
   - `id` — unique, append `_Ext` if in a base file
   - `title` — display key for the tab label (use `DisplayKey.get("...")` syntax)

   Optional attributes:
   - `visible` — hide the tab entirely for certain users/conditions
   - `editable` — control whether content within the card is editable

4. **Add content inside the Card.** Choose one of:

   **Option A — Reference existing reusable panels (preferred):**
   ```xml
   <Card id="CustomData_Ext" title="DisplayKey.get(&quot;Web.Policy.CustomData_Ext&quot;)">
     <PanelRef def="CustomInfo_ExtDV(policyPeriod)"/>
     <PanelRef def="CustomItems_ExtLV(policyPeriod)"/>
   </Card>
   ```

   **Option B — Inline Detail View (for simple, single-use content):**
   ```xml
   <Card id="CustomData_Ext" title="DisplayKey.get(&quot;Web.Policy.CustomData_Ext&quot;)">
     <DetailViewPanel>
       <InputColumn>
         <TextInput id="CustomField1_Ext" value="policyPeriod.CustomField1_Ext"
                    label="displaykey.Web.Policy.CustomField1_Ext"/>
         <TextInput id="CustomField2_Ext" value="policyPeriod.CustomField2_Ext"
                    label="displaykey.Web.Policy.CustomField2_Ext"/>
       </InputColumn>
     </DetailViewPanel>
   </Card>
   ```

   **Option C — PanelRef with injected toolbar (for actions specific to this card):**
   ```xml
   <Card id="CustomData_Ext" title="DisplayKey.get(&quot;Web.Policy.CustomData_Ext&quot;)">
     <PanelRef def="CustomItems_ExtLV(policyPeriod)">
       <Toolbar>
         <ToolbarButton id="ExportItems_Ext"
                        label="displaykey.Web.Policy.ExportItems_Ext"
                        action="com.customer.pc.ExportUtil.export(policyPeriod)"/>
       </Toolbar>
     </PanelRef>
   </Card>
   ```

5. **Create display keys:**
   ```
   Web.Policy.CustomData_Ext = Custom Data
   ```
   Plus keys for any fields/buttons inside the card.

6. **If the card content needs its own entity variable**, add a `<Variable>` at the CardViewPanel level (not inside the Card — variables are scoped to the panel):
   ```xml
   <CardViewPanel id="PolicySummaryCV">
     <Variable name="customItems" type="entity.CustomItem[]"
               initialValue="policyPeriod.CustomItems_Ext"/>
     <!-- ... existing cards ... -->
     <Card id="CustomData_Ext" ...>
       <PanelRef def="CustomItems_ExtLV(customItems)"/>
     </Card>
   </CardViewPanel>
   ```

## Things to check before considering this done

- Is the `id` unique across all cards in this CardViewPanel?
- Does `title` use a display key (never a hardcoded string)?
- If the card references entity data via `<Variable>`, is the variable declared at CardViewPanel level?
- Are all PanelRef targets' `<Require>` parameters satisfied by what you're passing?
- If `visible` uses a permission, verify the permission key exists and applies to the right entity
- Do the referenced reusable panels (DV/LV files) exist? If not, create them first.
- Does the new tab appear in the correct position relative to existing tabs?

## Cross-references

- CardView summary panel pattern: `/skills/pcf-agent-skills/01-building-a-cardview-summary-panel.md`
- PanelRef/Require: `/context/pcf/05-shared-sections-and-modes.md`
- Toolbar injection via PanelRef: `/rules/pcf-agent-rules/04-toolbar-placement-and-edit-workflow.md`
- Naming: `/rules/pcf-agent-rules/01-naming-and-organization.md`
- Nesting rules: `/rules/pcf-agent-rules/03-container-nesting-constraints.md`
