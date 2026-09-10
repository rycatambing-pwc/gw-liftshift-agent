# UI and PCF-Embedded Gosu Rules

These rules govern Gosu code written inside PCF files and in UI helper classes. Full background: `/context/gosu/ui_and_rules/08-pcf-ui-model-and-embedded-gosu.md`, `/context/gosu/ui_and_rules/09-rules-validation-and-entity-names.md`.

## Rule: `validationExpression` Must Return `null` or a Display-Key String — Nothing Else

A `validationExpression` attribute must return exactly one of:
- `null` — meaning the field value is valid; the save proceeds.
- A **string** (typically a display key) — meaning the field value is invalid; this string becomes the shown error message and the save is blocked.

Do not return other types, boolean values, or rely on side effects. The null/string contract is what the PCF framework expects.

## Rule: Reserve `requestValidationExpression` for Pre-Commit Failure Prevention Only

`requestValidationExpression` fires on **every server request** — not just at commit time. It also **cannot see the widget's own current in-progress value**, only the last-saved values of other widgets.

Use it **only** when an invalid intermediate value would cause something worse than a normal failed save — e.g. an exception or broken rendering of a dependent widget. Do **not** use it as a general "validate earlier" shortcut. For normal field validation, always use `validationExpression`.

## Rule: Use `PostOnChange` for Reactive UI Without Persisting

If a field needs to change appearance, visibility, or content in response to another field's edit, and that reaction does not need to be persisted yet, use **PostOnChange** on the triggering widget.

PostOnChange is a local, non-database operation — cheaper than a full Update cycle and gives the user instant feedback mid-edit.

**Do not** force a commit cycle just to re-evaluate dynamic properties on dependent fields.

## Rule: Do Not Use `deferUpdate` in New Configurations

`deferUpdate` exists solely to preserve legacy behavior for InsuranceSuite versions prior to R10. Do not add it when configuring a new PostOnChange usage. If it appears in older base configuration, leave it — do not propagate it into new custom code.

## Rule: Move Non-Trivial PCF Code-Tab Logic Into a UI Helper Class

PCF Code-tab Gosu is not reusable, cannot be unit-tested independently, and complicates upgrade merges. Keep the Code tab minimal — simple expressions and direct property accesses only.

When logic grows beyond a straightforward expression (multiple conditions, helper computations, repeated patterns), extract it into a dedicated **UI helper `.gs` class** in the customer package and call that class from the Code tab.

## Rule: `PostOnChange` Has One Trigger Widget Per Configuration

PostOnChange is defined on exactly one triggering widget. Do not try to configure multiple independent trigger sources for a single reactive change setup. If multiple fields each need to trigger their own updates, configure PostOnChange separately on each triggering widget.

## Rule: Group Shared-Condition Fields with `InputGroup`

If multiple fields test the **same** condition independently (e.g. each has `visible="someCondition"`), do not repeat the test on each field. Group them into an `InputGroup` and set the condition once on the group. Repeated per-field evaluation of the same condition causes unnecessary re-renders.

## Rule: Understand PCF Variable Scope Before Referencing Symbols

PCF variable scope follows a 4-level lookup: (1) local variable in current scope, (2) iterator element in a `RowIterator`, (3) page-level `Variable` declarations, (4) the PCF root object. Inside a `RowIterator`, the row element is accessed by `elementName`, not through the parent root. Referencing the wrong scope produces silent wrong-value bugs, not compilation errors.

Full details: `/context/gosu/ui_and_rules/08-pcf-ui-model-and-embedded-gosu.md`.

## Rule: Avoid Expensive Logic in `PostOnChange` Handlers

`PostOnChange` fires on **every field change** and triggers a synchronous server round-trip that blocks the user until the response returns. Do not put database queries, rule evaluations, or other expensive operations directly in a `PostOnChange` handler. Hoist expensive values into PCF `<Variable>` elements, or use a dedicated service method that caches results.

## Rule: Do Not Conflate PCF `validationExpression` with `.gr` Validation Rules

These two mechanisms run in different contexts and have different scopes:

| Mechanism | When it fires | Scope |
|---|---|---|
| PCF `validationExpression` | On screen save, after user interaction | UI only — never called from APIs or batch |
| `.gr` validation rules | On commit, at the domain layer | Applies to all entry points (UI, API, batch) |

Using only `validationExpression` leaves the API layer unprotected. Business-critical validation that must hold regardless of entry point belongs in a `.gr` validation rule. PCF `validationExpression` is for user-facing messaging on top of that.

## Rule: Preupdate Rules Do Not Re-Trigger on Objects Modified During the Same Execution Cycle

A preupdate rule that modifies entity B while processing entity A will **not** cause another preupdate rule run for entity B in the same cycle. The platform processes each object's preupdate rules once per cycle. Do not design rule logic that depends on cascading preupdate re-entry — it will silently not fire.

## Rule: Verify the `Validatable` Delegate Before Writing Validation Rules

Before writing a validation rule for an entity, confirm the entity's `.eti` or `.etx` declares the `Validatable` delegate. Without this delegate, the validation framework does not fire for that entity regardless of how the rule is written.

```xml
<!-- Required in the entity's .eti or .etx -->
<delegate name="Validatable" type="Validatable"/>
```
