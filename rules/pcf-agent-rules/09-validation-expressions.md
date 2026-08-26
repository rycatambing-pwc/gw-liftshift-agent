# Validation Expression Rules

Full background: `/context/22-validation-expressions.md`.

## Rule: Default to `validationExpression`

Unless there's a specific reason to do otherwise, use **`validationExpression`** for validation logic. It fires at commit time, can see other widgets' current values, and doesn't interrupt the user with validation errors until they're done editing — the more user-friendly default.

## Rule: Reserve `requestValidationExpression` for Pre-Commit Failure Prevention Only

Only use **`requestValidationExpression`** when an invalid value could cause something worse than a normal failed save before the user commits — e.g. a thrown exception, or breaking the rendering of another part of the page that depends on this value (such as a date field on one Card that another Card's display logic depends on).

Do **not** use `requestValidationExpression` as a general "validate earlier" mechanism — remember it cannot see the widget's own current, in-progress value, only the last-*saved* values of other widgets, which makes it unsuitable for most ordinary validation needs.

## Rule: Return `null` or a Display-Key String — Nothing Else

A validation expression (either attribute) must return either `null` (valid) or a string, typically a display key, that becomes the shown error message (invalid, save blocked). Don't return other types or rely on side effects — the null/string contract is what the framework expects.
