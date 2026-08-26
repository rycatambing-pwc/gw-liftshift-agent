# Code and Content Practices

## Minimize Gosu in `<Code>` Blocks

Avoid large blocks of Gosu code embedded directly in PCF `<Code>` elements:
- Not reusable across PCF files
- Cannot be debugged within the PCF editor
- Complicates upgrade merges

**Do instead:** move non-trivial logic into reusable Gosu classes and rules files; keep PCF-embedded code minimal (simple expressions, not multi-step logic).

## Always Use Display Keys for Text

Never hardcode user-facing strings. Define static text via `<Text>` elements with unique IDs, referenced elsewhere in the PCF. This is required for localization and centralized text management.

## Always Assign Unique, Descriptive IDs

Every widget should have a unique `id`. Guidewire strongly recommends this to make future identification and maintenance easier — don't rely on positional/implicit identification.

## Avoid Mutually Mutable Configuration (MMC)

Be aware that any element both you and Guidewire can modify creates merge complexity on upgrade. Where possible, extract customizations out of core InsuranceSuite configuration rather than editing shared/base elements directly in a way that both sides might touch.

## Prefer an Input Set for Shared Visibility/Editability Logic

If multiple widgets need the same `visible` or `editable` condition — especially if that same group of widgets appears in more than one place (e.g. two different Cards) — group them into an **Input Set** and set the condition once on the Input Set itself, rather than repeating it on every individual widget in every location.

Benefits: one place to update layout/order changes, one place to update the shared condition, and (per `/context/12-input-sets.md`) a performance advantage for partial/dynamic page updates since the Input Set's content can be refreshed as a single unit.

## Choosing Between Data Model Validation and UI Field-Level Validation

Full background: `/context/21-ui-field-validation.md`.

- If a format constraint should hold **everywhere**, regardless of how data enters the system (UI or API) — use **data model validation**.
- If the valid format legitimately **varies by context** (e.g. country-specific formats shown via different modes) — use a field's `regex` property for **UI-level validation** instead.

## Move Reusable Validation Logic Out of the PCF Code Tab

If a validation regex (or any non-trivial validation logic) needs to be reused across multiple PCFs, or is likely to need future changes, don't write it directly on a PCF's Code tab. Put it on an **enhancement or helper class** instead — this keeps it reusable and means any future change only needs to happen in one place, not repeated across every PCF that uses it. (Same principle as the general "minimize Gosu in `<Code>` blocks" rule above, applied specifically to validation.)
