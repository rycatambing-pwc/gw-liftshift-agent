# Skill: Adding Fields to an Existing Detail View

Step-by-step recipe for adding one or more new input fields to an existing Detail View. This is the single most common PCF modification task.

## When to use this pattern

- A requirement says "add field X to the [Entity] detail screen"
- A new entity field or typelist extension has been created and needs UI exposure
- An existing field needs to be shown in a different DV where it wasn't before

## Steps

1. **Locate the target Detail View file.**
   - Use `pcf-find-usages` if you only know the screen name — find the PanelRef chain back to the DV file.
   - DV files end with the `DV` suffix (e.g., `PolicyInfoDV.pcf`).

2. **Determine whether the DV is inline or reusable.**
   - Inline: defined inside a parent PCF — edit the parent file directly.
   - Reusable: own top-level `.pcf` file with `<Require>` parameters — edit that file.

3. **Identify the correct InputColumn.**
   - DVs have one or more `<InputColumn>` elements — place the new field in the column that matches the logical grouping.
   - If the DV has a single column, add to that column.
   - If multiple columns: left column = primary/identifying fields, right column = secondary/status fields (follow existing pattern in the file).

4. **Add the appropriate input widget.** Choose based on the field type:

   | Field Type | Widget | Key Attributes |
   |-----------|--------|----------------|
   | String | `TextInput` | `value`, `label`, `editable`, `required`, `maxChars` |
   | Multi-line string | `TextAreaInput` | `value`, `label`, `numRows` |
   | Date | `DateInput` | `value`, `label`, `validationExpression` |
   | Currency/money | `MonetaryAmountInput` or `CurrencyInput` | `value`, `label` |
   | Boolean | `BooleanRadio` or `CheckBox` | `value`, `label` |
   | Typelist (dropdown) | `RangeInput` | `value`, `valueRange`, `label` |
   | Typelist (radio) | `TypeKeyRadioButton` | `value`, `label`, `filter` |
   | Entity reference | `PickerInput` | `value`, `label`, `pickLocation` |

5. **Set the widget attributes:**
   - `id` — unique, descriptive, append `_Ext` if adding to a base OOTB file
   - `value` — Gosu expression path to the entity field (e.g., `policy.PrimaryInsuredName_Ext`)
   - `label` — always a display key: `displaykey.Web.Policy.MyField_Ext`
   - `editable` — Gosu boolean (or omit to inherit from parent container)
   - `visible` — Gosu boolean (or omit, defaults to `true`)
   - `required` — Gosu boolean (shows asterisk if true)

6. **Create the display key** in the appropriate `.properties` file:
   ```
   Web.Policy.MyField_Ext = My Field Label
   ```
   Location: `modules/configuration/config/displaykeys/`

7. **If the field needs validation**, add `validationExpression`:
   ```xml
   <TextInput id="PhoneNumber_Ext"
              value="contact.PhoneNumber_Ext"
              label="displaykey.Web.Contact.PhoneNumber_Ext"
              validationExpression="contact.PhoneNumber_Ext == null or contact.PhoneNumber_Ext.matches(&quot;\\d{10}&quot;) ? null : displaykey.Web.Contact.PhoneNumber_Ext.Invalid"/>
   ```
   See `/context/pcf/22-validation-expressions.md` — return `null` (valid) or display-key string (invalid).

8. **If the field should trigger reactive updates**, add PostOnChange:
   ```xml
   <RangeInput id="State_Ext" value="address.State_Ext" ...>
     <PostOnChange onChange="recalculateTaxRate()"/>
   </RangeInput>
   ```
   See `/rules/pcf-agent-rules/07-dynamic-ui-practices.md`.

## Things to check before considering this done

- Does the entity field actually exist? Check `.eti`/`.etx` files or delegate to `gw-entity-agent`.
- Is the display key created and spelled correctly (including the `displaykey.` prefix in the PCF)?
- Does the `id` follow `_Ext` convention if inside a base file?
- Is the widget placed in the correct position relative to related fields (group logically)?
- If `required="true"`, is there also a `validationExpression` for the specific format, or is presence-only sufficient?
- If the field is a typelist, does `valueRange` reference the correct typelist with appropriate filter?

## Cross-references

- Validation: `/context/pcf/22-validation-expressions.md`, `/rules/pcf-agent-rules/09-validation-expressions.md`
- Naming: `/rules/pcf-agent-rules/01-naming-and-organization.md`
- PostOnChange: `/context/pcf/17-dynamic-ui-and-post-on-change.md`, `/rules/pcf-agent-rules/07-dynamic-ui-practices.md`
- Inline vs reusable DV: `/context/pcf/07-detail-views-inline-vs-reusable.md`
