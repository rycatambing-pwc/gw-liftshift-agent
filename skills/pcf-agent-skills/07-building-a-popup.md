# Skill: Building a Popup with Data Return

Step-by-step recipe for creating a new Popup location. Popups appear on top of the current page and optionally return a value to the caller. There are three distinct use-case patterns — pick the one that matches.

## When to use this pattern

- The user needs to select, create, or view/edit something in a modal-like overlay
- The workflow requires returning a value to the calling page (e.g., a newly created entity or a search result)
- An existing action needs to open a focused form without navigating away

## Choose the use-case pattern first

| Use Case | Data Flow | Popup Commits? | Caller Commits? |
|----------|-----------|----------------|-----------------|
| **View/Edit existing** | Popup receives entity, edits it | Yes — popup commits directly | No (just refreshes) |
| **Create new** | Popup creates entity, returns it to caller | No — popup returns object | Yes — caller adds to its array/relationship |
| **Search/Select** | Popup finds record, returns selection | No | Depends on what caller does with it |

## Steps

1. **Create a new PCF file of type `Popup`.**
   - File name should describe the action: `NewExposure_ExtPopup.pcf`, `SelectContact_ExtPopup.pcf`
   - The `_Ext` goes before the type suffix if this is a custom popup.

2. **Set essential properties:**
   - `title` — display key for the popup header
   - Entry point with parameter(s) the popup needs from its caller
   - Variable for each entry point parameter

3. **Add a Screen** to the popup.

4. **Build the popup content:**
   - For **View/Edit**: include a `PanelRef` to an existing or new DV, add `EditButtons` to the Screen toolbar.
   - For **Create new**: include a DV/form for the new entity's fields. Add a "Create" `ToolbarButton` whose `action` creates the entity and returns it.
   - For **Search**: include search criteria inputs and a results LV. Wire a row-click or button to return the selection.

5. **Wire the return mechanism (Create/Search patterns):**
   - The popup's action must call the mechanism that returns data to the caller.
   - The caller receives the returned object and adds it to its context (e.g., `addToArray`, assignment to a field).

6. **Add the "Return to previous Location" link.**
   - Popups MUST have this — it's the user's way to dismiss without acting.
   - This is typically automatic in the Popup type, but verify it's present.

7. **Wire the caller to invoke this popup:**
   ```xml
   <!-- In the calling PCF: -->
   <ToolbarButton id="AddExposure_Ext"
                  label="displaykey.Web.Exposure.Add_Ext"
                  action="NewExposure_ExtPopup.push(currentCoverable)"/>
   ```
   Or from a `PickerInput`:
   ```xml
   <PickerInput id="ContactPicker_Ext"
                value="policy.PrimaryContact_Ext"
                label="displaykey.Web.Policy.PrimaryContact_Ext"
                pickLocation="SelectContact_ExtPopup.push(policy)"/>
   ```

## Worked Example — Create New Pattern

```xml
<?xml version="1.0"?>
<PCF xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:noNamespaceSchemaLocation="../../../../../../pcf.xsd">
  <Popup
    id="NewItem_ExtPopup"
    title="displaykey.Web.Item.New_Ext">
    <Require
      name="parentEntity"
      type="entity.MyParent"/>
    <Variable
      name="newItem"
      type="entity.MyItem"
      initialValue="new MyItem()"/>

    <Screen>
      <Toolbar>
        <ToolbarButton
          id="CreateButton_Ext"
          label="displaykey.Web.Item.Create_Ext"
          action="parentEntity.addToItems_Ext(newItem); CurrentLocation.pickValueAndCommit(newItem)"/>
        <ToolbarButton
          id="CancelButton_Ext"
          label="displaykey.Web.Cancel"
          action="CurrentLocation.cancel()"/>
      </Toolbar>
      <PanelRef
        def="ItemDetail_ExtDV(newItem)"/>
    </Screen>
  </Popup>
</PCF>
```

## Things to check before considering this done

- Does the popup have a "Return to previous Location" mechanism (Cancel button or the automatic return link)?
- For Create-new pattern: does the popup return the object to the caller? The caller must be the one to commit/persist.
- For View/Edit pattern: does the popup commit its own changes (not the caller)?
- Is `.push()` used at every call site (not `.go()` — that's for Location Groups)?
- Does the entry point parameter list match what every caller passes?
- Are display keys created for title, button labels?

## Cross-references

- Popup data flow contracts: `/context/pcf/16-popup-use-cases-and-data-flow.md`
- Navigation syntax (`.push()`): `/context/pcf/13-navigating-to-locations.md`, `/rules/pcf-agent-rules/06-navigation-syntax.md`
- Toolbar placement: `/rules/pcf-agent-rules/04-toolbar-placement-and-edit-workflow.md`
- Naming: `/rules/pcf-agent-rules/01-naming-and-organization.md`
