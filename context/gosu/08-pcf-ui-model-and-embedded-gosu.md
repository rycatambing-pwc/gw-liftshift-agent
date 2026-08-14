---
document: pcf-ui-model-and-embedded-gosu
purpose: Help an LLM interpret PCF XML, embedded Gosu expressions, and UI performance patterns
scope: `.pcf`, widgets, locations, ListView, RowIterator, dynamic behavior, validation expressions
---

# PCF UI Model and Embedded Gosu

## Mental model

PCF means Page Configuration Format. It is XSD-validated XML that defines UI structure, layout, behavior, navigation, variables, and embedded Gosu expressions.

## Two top-level PCF element categories

| Category | Meaning |
|---|---|
| Widget | Displayable element rendered into HTML. |
| Location | Navigable place in the UI. A location does not itself define visual content. |

## Widget hierarchy

| Widget type | Examples | Purpose |
|---|---|---|
| Atomic widget | Input, Cell, Button | Displays data or performs an action. |
| Primary container | DetailView, ListView, InputSet | Organizes atomic widgets. |
| Secondary container | ListDetailPanel, Card | Organizes primary containers. |
| Top-level container | Screen | Organizes primary/secondary containers. |

## Location types

- Page — contains a single screen, used within location groups.
- Location Group — collection of pages sharing info bar/actions/sidebar.
- Wizard — ordered screens with wizard navigation.
- Popup — temporary UI context; returns to prior location.
- Worksheet — screen rendered in workspace frame.
- Forward — contains logic to choose next location.
- Exit Point — URL outside Guidewire; no screen widget.

## DetailView

Two common forms:

- DetailView PCF file: reusable, takes a root object, commonly named with `DV`.
- Inline DetailView widget: inherits parent root object and is not separately reusable.

Agent check:

- Identify root object.
- Identify required variables.
- Check embedded expressions against root object scope.

## ListView and RowIterator

A ListView displays a collection or query result as rows.

RowIterator required properties:

- `value` — set of elements to process.
- `valueType` — type of the set.
- `elementName` — variable name for the current row object.
- `editable` — whether rows are editable.

Agent rule:

- Inside row cells, expressions often refer to `elementName`, not the parent root object.
- If a ListView is query-backed, query performance rules apply.

## Embedding ListViews

- Use `ListViewInput` when embedding a ListView in a DetailView.
- Use `PanelRef` when embedding a panel from a Screen.

## View entities

View entities can improve ListView performance by providing a logical view of entity data and reducing dot-path expansion. When a ListView uses related entity fields, check whether a view entity should be used.

## Toolbar filters

Toolbar filters can filter query-backed ListViews. Hidden default filters may use:

- `visible = false`
- `selectOnEnter = true`

Agent rule: if a filter property calls a Gosu function, inspect whether it limits the result set at the query level.

## Dynamic behavior

Dynamic UI behavior happens while a field value changes, before data is committed.

### PostOnChange

- Defined on the triggering widget.
- Causes a server postback.
- `onChange` can execute a Gosu expression.
- Avoid expensive logic in `onChange`.

### Client Reflection

- Defined on listening widgets.
- Uses `triggerIds` and `VALUE` token.
- Best for some UI reactions without row-by-row server roundtrips.

## Expensive PCF expressions

Watch for:

- multi-step dot paths
- array expansion
- collection methods
- complex methods called from widget properties

Prefer:

- PCF-level variables
- row iterator variables
- query-backed filtering
- UI helper classes

## UI validation expressions

`validationExpression`:

- Field/widget-level validation.
- Validates when widget is updated.
- Return `null` to allow save.
- Return string/error message to prevent save and flag widget.

`requestValidationExpression`:

- Validates on every server request.

Do not confuse these with Gosu validation rules in `.gr` files.

## Modes

Modes choose different PCF variants for a business scenario such as LOB or contact type. Ensure default mode exists when required. New custom modes on base modal PCFs often use `_Ext` naming.
