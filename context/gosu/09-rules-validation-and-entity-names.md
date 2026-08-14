---
document: rules-validation-and-entity-names
purpose: Teach an agent to analyze Gosu Rules, validation, and entity DisplayName behavior
scope: `.gr`, `.en`, validation rules, delegates, Validatable, DisplayName
---

# Rules, Validation, and Entity Names

## Entity names

Entity Name files (`.en`) define UI-friendly display names for entity instances. The default entity name type is accessed via `DisplayName`.

Agent rule:

- When code uses `entity.DisplayName`, check whether an `.en` file defines it.
- If no entity name exists, display behavior may fall back to a field list or default behavior.
- Entity name paths must reference actual database-backed properties.

## Gosu Rules

Gosu Rules are `.gr` files. A rule is a decision:

```text
if condition then action
```

Rule components:

- root entity
- name
- condition
- action

Rule hierarchy:

```text
Rule set category -> rule set -> rules -> child rules
```

Common categories:

- `EventMessage`
- `Preupdate`
- `Validation`

## Rule execution

- Rules execute in hierarchy order.
- If a parent rule condition is true, its action executes and then child rules execute.
- Preupdate rules typically run before validation rules.
- Preupdate rules do not rerun on objects modified during initial rule execution.

## Exit methods

| Method | Meaning |
|---|---|
| `actions.exit()` | Exit the entire rule set. |
| `actions.exitAfter()` | Execute this rule's child rules, then exit the rule set. |
| `actions.exitToNextParent()` | Skip to the next top-level/parent-level rule path. Verify exact behavior in project docs. |
| `actions.exitToNext()` | Stop current rule and go to next peer rule. |

## Validation rules

Validation rules enforce complex business logic and relationships between fields.

Requirements and triggers:

- Entity must implement the `Validatable` delegate.
- `implementsEntity` in `.eti/.etx` declares delegates.
- `triggersValidation` on foreign keys or arrays controls parent validation when subobjects change.

Possible outcomes:

- reject with error
- reject with warning
- no rejection

Common API:

```gosu
entity.rejectField(...)
```

Verify exact signature in target version.

## UI validation vs validation rules

| UI validation expression | Validation rule |
|---|---|
| In PCF atomic widget. | In `.gr` validation rules. |
| Good for simple single-field checks. | Good for complex relationships and business rules. |
| Configured per widget. | Requires validatable entity/delegate setup. |
| Enforced in UI context. | Enforced during commit/API validation path. |

## Delegates

A delegate models a reusable capability in the data model. Examples:

- `Validatable` — reusable warning/error validation behavior.
- `Assignable` — assignment-related behavior.

Agent rule: when validation behavior is unclear, inspect `.eti/.etx` for `implementsEntity` and FK/array `triggersValidation`.
