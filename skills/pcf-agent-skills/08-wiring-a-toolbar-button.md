# Skill: Wiring a ToolbarButton to a Gosu Action

Step-by-step recipe for adding a new ToolbarButton that executes a Gosu action. Covers correct toolbar placement, visibility/availability rules, and action wiring.

## When to use this pattern

- A requirement says "add a button that does X" on a page or list view
- A custom action needs to be accessible from the UI (e.g., "Recalculate Premium", "Send Notification", "Export")
- An existing toolbar needs a new operation added

## Steps

1. **Determine the correct toolbar location.** This is the most common mistake — buttons go in specific places:

   | Button Type | Toolbar Location |
   |-------------|-----------------|
   | Edit/Update/Cancel | Screen-level toolbar |
   | Add/Remove (for a list) | Closest toolbar to the ListViewPanel |
   | Custom page-level action | Screen-level toolbar |
   | Custom action on a specific panel | PanelRef-wrapped toolbar (injected via PanelRef child) |

   See `/rules/pcf-agent-rules/04-toolbar-placement-and-edit-workflow.md`.

2. **Add the ToolbarButton element:**

   ```xml
   <ToolbarButton
     id="RecalcPremium_Ext"
     label="displaykey.Web.Policy.RecalcPremium_Ext"
     action="policyPeriod.recalculatePremium_Ext()"
     visible="perm.PolicyPeriod.edit(policyPeriod)"
     available="CurrentLocation.InEditMode"
     hideIfReadOnly="true"/>
   ```

3. **Set the required attributes:**

   | Attribute | Purpose | Required? |
   |-----------|---------|-----------|
   | `id` | Unique identifier (use `_Ext` in base files) | Yes |
   | `label` | Display key for button text | Yes |
   | `action` | Gosu expression to execute on click | Yes |
   | `visible` | Show/hide the button (permission check or condition) | Usually |
   | `available` | Enable/disable (grayed out when false) | Often |
   | `hideIfReadOnly` | Hide when page is not in edit mode | If edit-only action |

4. **Write the Gosu action.** The `action` attribute accepts:
   - A direct method call: `entity.doSomething()`
   - A static method: `com.customer.util.MyHelper.performAction(entity)`
   - An enhancement method: `policyPeriod.customAction_Ext()`
   - Navigation: `MyPopup.push(entity)` or `MyGroup.go(entity)`
   - Multiple statements separated by `;`

   For complex logic, delegate to a Gosu helper/enhancement rather than inlining in the PCF.

5. **Set visibility and availability conditions:**
   - `visible` — controls whether the button renders at all. Use permission checks: `perm.Entity.action(instance)`
   - `available` — controls whether the button is clickable (appears grayed out if false). Common: `CurrentLocation.InEditMode`
   - `hideIfReadOnly="true"` — shorthand: hide when page is in read-only mode

6. **If injecting into a shared panel you don't own**, use PanelRef wrapping:

   ```xml
   <PanelRef def="ExistingPanel_ExtLV(entity)">
     <Toolbar>
       <ToolbarButton
         id="MyAction_Ext"
         label="displaykey.Web.MyAction_Ext"
         action="doMyAction(entity)"/>
     </Toolbar>
   </PanelRef>
   ```

7. **Create the display key:**
   ```
   Web.Policy.RecalcPremium_Ext = Recalculate Premium
   ```

## Worked Example — Edit-Mode Action on Screen Toolbar

```xml
<Screen>
  <Toolbar>
    <EditButtons/>
    <ToolbarButton
      id="SendNotification_Ext"
      label="displaykey.Web.Policy.SendNotification_Ext"
      action="com.customer.pc.notification.NotificationUtil.send(policyPeriod)"
      visible="perm.PolicyPeriod.edit(policyPeriod)"
      available="CurrentLocation.InEditMode"
      hideIfReadOnly="true"/>
  </Toolbar>
  <!-- ... panels ... -->
</Screen>
```

## Things to check before considering this done

- Is the button in the correct toolbar? (Edit buttons on Screen, Add/Remove near LV)
- Does the `action` Gosu expression compile? Verify the method exists (check enhancements/helpers).
- Is `visible` guarded by the appropriate permission (`perm.Entity.action`)?
- Does `available` correctly reflect when the action is meaningful?
- If the action modifies data, is the page in edit mode (bundle is writable)?
- Is the `id` unique and uses `_Ext` if in a base file?
- Is the display key created?

## Cross-references

- Toolbar placement rules: `/rules/pcf-agent-rules/04-toolbar-placement-and-edit-workflow.md`
- Naming: `/rules/pcf-agent-rules/01-naming-and-organization.md`
- PanelRef wrapping: `/context/pcf/05-shared-sections-and-modes.md`
- Navigation actions: `/context/pcf/13-navigating-to-locations.md`
