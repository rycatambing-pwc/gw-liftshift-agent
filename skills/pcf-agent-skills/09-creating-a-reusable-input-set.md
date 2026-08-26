# Skill: Creating a Reusable InputSet

Step-by-step recipe for extracting a group of related fields into a reusable InputSet. InputSets are the DRY mechanism for field groups that appear in multiple Detail Views.

## When to use this pattern

- The same group of fields (e.g., address fields, contact info, coverage limits) appears in 2+ Detail Views
- A set of fields shares the same visibility/editability condition and you want to control it in one place
- You need partial page refresh performance — InputSets can be re-evaluated independently

## Key constraints (from `/context/pcf/12-input-sets.md`)

- InputSet MUST be inside a DetailViewPanel (cannot be a direct child of Screen or secondary views)
- InputSet CANNOT contain `<InputColumn>` — fields go directly inside
- InputSet CANNOT have its own `<Toolbar>`
- InputSets CAN nest inside other InputSets
- Included via `<InputSetRef>` (not `<PanelRef>`)

## Steps

1. **Identify the fields to extract.**
   - Look for the same field group repeated across multiple DVs.
   - Confirm all fields logically belong together (same entity or same sub-entity).

2. **Create a new PCF file of type `InputSet`:**
   - File name: `<DescriptiveName>_ExtInputSet.pcf` (or `<DescriptiveName>InputSet.pcf` if fully custom)
   - The framework auto-appends the `InputSet` suffix — don't double it in the ID.

3. **Declare parameters with `<Require>`:**
   ```xml
   <Require name="anAddress" type="entity.Address"/>
   ```
   The InputSet has no parent to inherit root objects from — it must declare everything it needs.

4. **Add the input widgets directly** (NO `<InputColumn>` wrapper):

   ```xml
   <?xml version="1.0"?>
   <PCF xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="../../../../../../pcf.xsd">
     <InputSet
       id="Address_ExtInputSet">
       <Require
         name="anAddress"
         type="entity.Address"/>

       <TextInput
         id="AddressLine1_Ext"
         value="anAddress.AddressLine1"
         label="displaykey.Web.Address.Line1"
         required="true"/>
       <TextInput
         id="City_Ext"
         value="anAddress.City"
         label="displaykey.Web.Address.City"
         required="true"/>
       <RangeInput
         id="State_Ext"
         value="anAddress.State"
         valueRange="typekey.State.getTypeKeys(false)"
         label="displaykey.Web.Address.State"/>
       <TextInput
         id="PostalCode_Ext"
         value="anAddress.PostalCode"
         label="displaykey.Web.Address.PostalCode"
         regex="\\d{5}(-\\d{4})?"/>
     </InputSet>
   </PCF>
   ```

5. **Set shared visibility/editability on the InputSet itself** (cascades to all children):
   ```xml
   <InputSet
     id="Address_ExtInputSet"
     visible="anAddress != null"
     editable="perm.Address.edit(anAddress)">
   ```
   This is the performance benefit — one evaluation controls all contained fields.

6. **Include the InputSet in consuming DVs via `<InputSetRef>`:**
   ```xml
   <!-- Inside a DetailViewPanel's InputColumn: -->
   <InputSetRef
     def="Address_ExtInputSet(policy.PrimaryAddress)"/>
   ```

7. **Remove the duplicated fields** from the original DVs that now use the InputSet.

## Things to check before considering this done

- Is the InputSet inside a `<DetailViewPanel>` → `<InputColumn>` at every usage site? (It cannot be a direct child of Screen)
- Does the InputSet NOT contain `<InputColumn>` elements? (Fields go directly inside InputSet)
- Does every `<InputSetRef>` pass the correct argument matching the `<Require>` type?
- Are the field `id` values still unique across the page (no collisions with the parent DV's IDs)?
- If the InputSet uses `visible`/`editable`, verify the Gosu expression works with the declared `<Require>` parameter
- Are display keys already defined (reuse existing ones if the fields already had labels)?

## Don't confuse with

- **PanelRef** — for including Detail Views, List Views, or Panel Sets (larger containers with their own structure)
- **InputSetRef** — specifically for InputSets (analogous but targets InputSet type)

An InputSet is a "fragment" of fields; a DV is a "complete panel." If you need columns, toolbars, or a standalone panel, use a DV with PanelRef instead.

## Cross-references

- InputSet architecture: `/context/pcf/12-input-sets.md`
- Nesting constraints: `/rules/pcf-agent-rules/03-container-nesting-constraints.md`
- Code practices (InputSet for DRY): `/rules/pcf-agent-rules/02-code-and-content-practices.md`
- Naming: `/rules/pcf-agent-rules/01-naming-and-organization.md`
