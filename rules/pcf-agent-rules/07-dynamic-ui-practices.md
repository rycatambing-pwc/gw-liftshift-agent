# Dynamic UI: Choosing Properties vs. Post-on-Change

Full background: `/context/17-dynamic-ui-and-post-on-change.md`.

## Rule: Don't Force a Commit Cycle for Purely Reactive UI

If a field needs to change appearance/visibility/content in response to another field's edit, and that reaction **doesn't need to be persisted yet**, use **Post-on-Change** on the triggering widget rather than relying on a full navigate/Update cycle to re-evaluate dynamic properties. Post-on-Change is local and doesn't hit the database — cheaper, and gives the user instant feedback while they're still mid-edit.

## Rule: Reserve Dynamic Properties for Persisted-State Reactions

Use ordinary dynamic properties (`visible`, `editable`, `label`, `value` expressions) when the field's state should reflect **already-committed** data — i.e. the correct behavior really is "this depends on what's saved," not "this depends on what the user just typed but hasn't saved."

## Rule: One Trigger Widget Per Post-on-Change Configuration

Post-on-Change is defined on exactly one triggering widget. Don't try to configure multiple independent trigger sources for a single Post-on-Change setup — if multiple fields need to each trigger their own reactive updates, configure Post-on-Change separately on each.

## Default Behavior Reminder

If nothing is set on the PostOnChange tab beyond enabling it, the server still determines whether other fields should change and redraws the screen automatically — you don't need to manually specify every dependent field unless you need more specific control, in which case use the `onChange` property with a Gosu expression.

## Rule: Never Use `deferUpdate` for New Configurations

`deferUpdate` exists solely to preserve legacy behavior for InsuranceSuite versions prior to R10. Do not add it when configuring a new Post-on-Change usage — if it appears in older base configuration, that's expected; don't propagate it into new custom work.

## Rule: Prefer Simple Expressions Over Complex Method Calls in `onChange`

A plain expression performs better than calling a method with complex processing (especially anything involving queries). If a complex method is genuinely required by the business logic, that's an acceptable tradeoff — but it should be a deliberate choice, not the default reach.

## Rule: Group Shared-Condition Fields with `InputGroup`

If multiple fields independently test the *same* condition to determine visibility/availability/editability, don't repeat that test on each field individually — group the fields into an `InputGroup` so the condition is evaluated once for the whole group. Repeated per-field testing of the same condition causes unnecessary re-renders and can produce a confusing, flickering UI.

## `disablePostOnEnter` for Screen-Entry-Time Conditions

Use `disablePostOnEnter` (a Boolean expression) when Post-on-Change should be skipped specifically on initial screen entry under some condition (e.g. locale-specific fields) — this is distinct from disabling Post-on-Change unconditionally or based on an unrelated field's value.
