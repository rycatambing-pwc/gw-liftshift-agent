# Validation Expressions

Source: Guidewire Education module. Complements `/context/21-ui-field-validation.md` (which covered regex-based validation) — this module covers **expression-based** validation logic instead.

## The Ternary Pattern

Validation expressions are typically written as a ternary: `condition ? valueIfTrue : valueIfFalse`.

- **Returns `null`** → data is considered valid; save is allowed.
- **Returns a string** (typically a display key, i.e. an error message) → the widget is flagged, the error message string is displayed, and the save is **prevented**.

Any Gosu expression that returns either `null` or a string can be used — not limited to a literal ternary; a method call that returns one of those two things works too.

## Two Attributes, Different Timing and Scope

Inputs and cells have **two** validation-related attributes: `validationExpression` and `requestValidationExpression`. They are not interchangeable — they differ in *when* they run and *what they can see*.

### `requestValidationExpression`

- Executes on **any call to the server** — not just a commit. This includes simply navigating within the current Location (e.g. moving from one Card to another).
- Runs **before** the user attempts to commit data.
- **Cannot see the current (in-progress) value of the widget it's attached to** — it can only check the **last-saved** value of *other* widgets.
- **Intended use: rare, edge-case scenarios** where an invalid value could cause something worse than a normal validation failure — e.g. a thrown exception, or a rendering failure elsewhere on the page. Example: a bad date on one Card that would break rendering of a different Card that depends on it.

### `validationExpression`

- Executes when the application attempts to **commit** the widget's value — evaluated immediately before saving.
- Because all widget values are being saved at this point, the condition **can check the current values of other widgets** too, not just their last-saved state.
- **This is the default, preferred choice for the vast majority of validation needs.** It's considered more user-friendly because it doesn't interrupt the user with a validation failure until they're actually done with their work — rather than firing on every server round-trip.

## Rule of Thumb

**Default to `validationExpression`.** Only reach for `requestValidationExpression` in the narrow case where an invalid value could cause an actual error/exception or break something else's rendering *before* the user even tries to save — not as a general-purpose "validate earlier" mechanism.
