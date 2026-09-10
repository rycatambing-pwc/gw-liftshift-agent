# Naming and Packages Rules

These are firm conventions, not suggestions — violating them creates namespace collisions with Guidewire base code and breaks upgrade-merge hygiene.

## Customer Package Placement

- All customer Gosu code must live in **customer-owned packages** (e.g. `com.mycompany.*`, `ext.*`).
- Never place custom code in `gw.*` or `com.guidewire.*` — those namespaces are reserved for Guidewire base product code.
- Organize sub-packages by feature or domain area, not by layer or file type.

Full guidance: `/context/gosu/oop/11a-naming-and-packages.md`.

## `_Ext` Suffix — Where It Applies

The `_Ext` suffix signals "this is a customer extension of a base artifact." Apply it precisely — not universally.

| Artifact type | Apply `_Ext`? |
|---|---|
| Extension entity fields (`.etx` / `.eix`) | **Yes** |
| Custom PCF files (new files, not base modifications) | **Yes** (before the framework-appended type suffix) |
| Custom elements/IDs added inside a base PCF | **Yes** |
| Display keys added by the customer | **Yes** |
| Script parameters added to base rule files | **Yes** |
| Enhancement methods added to base types (`.gsx`) | **Yes** |
| New standalone Gosu classes (not extending a base artifact) | **No** — the class itself is entirely new, no collision risk |
| Modes added to a base PCF file | **Yes** (suffix the mode name, not the file) |
| Modes on an already-custom PCF file | **No** (the file is already custom) |

## Naming Conventions

| Symbol | Convention |
|---|---|
| Classes | `UpperCamelCase` |
| Methods | `lowerCamelCase` |
| Properties | `lowerCamelCase` |
| Constants | `UPPER_SNAKE_CASE` |
| Interfaces | `IUpperCamelCase` |
| Abstract classes | `AbstractUpperCamelCase` |
| Enhancement classes | Typically named after the type they enhance (e.g. `PolicyEnhancement`) |

## Boolean Operators — Gosu Keywords Only

Use Gosu's keyword operators exclusively. Never use Java/C-style symbols.

| Correct (Gosu) | Wrong (Java-style) |
|---|---|
| `not x` | `!x` |
| `a and b` | `a && b` |
| `a or b` | `a \|\| b` |

Using Java-style operators compiles but signals unfamiliarity with Gosu conventions and is flagged by static inspections.

## Style Preferences

- Prefer `Count` / `Empty` over `.size()` / `.isEmpty()` on collections.
- Prefer `typeis` for type-checking, `typeof` only when the `Type` object itself is needed.
- Use `?.` (null-safe dereference) and `?:` (Elvis) rather than explicit null guards where the intent is clear.
- Prefer feature literals (`Entity#Field`) over string-based reflection for property access.
- Prefer enhancements over utility classes for cross-cutting entity behavior.
