---
document: gosu-style-naming-and-enhancements
purpose: Capture conventions useful for code review and customization detection
scope: naming, `_Ext`, packages, enhancements, UI helper classes, GosuDoc
---

# Gosu Style, Naming, and Enhancements

## Package rules

- Add new implementation classes to customer package spaces.
- Avoid adding new classes to Guidewire package spaces.
- Avoid using internal `com.guidewire.*` classes unless no supported alternative exists.
- Create subpackages by feature, not by generic function.

## Naming conventions

| Item | Convention |
|---|---|
| Classes | UpperCamelCase, singular noun/adjective. |
| Methods/functions | lowerCamelCase, verb phrase. |
| Properties | UpperCamelCase, noun/adjective; booleans often read as `isX`. |
| Constants | ALL_CAPS_WITH_UNDERSCORES. |
| Interfaces | UpperCamelCase; do not prefix with `I`. |
| Implementations | Descriptive name; avoid `Impl`; use `DefaultX` only if no better name. |
| Abstract classes | UpperCamelCase, often `AbstractX`. |

## `_Ext` guidance

Use project standards as source of truth, but common training guidance says:

- New fields added to existing entities: `_Ext`.
- New custom PCF files: `_Ext`.
- Custom elements/variables added to base PCFs: `_Ext`.
- New display keys: `_Ext`.
- New script parameter values: `_Ext`.
- Enhancements on Guidewire entities/classes: `_Ext` for added methods/properties.
- New classes in customer package spaces: usually no `_Ext`.

## GosuDoc

- Document public/protected classes and functions with GosuDoc/Javadoc-style comments.
- Private functions usually do not require GosuDoc.
- Generate with:

```text
gwb gosudoc
```

## Enhancements

Enhancements add methods/properties to existing types, especially generated Guidewire entities.

Agent rule:

- If a method is not found on an entity class, search `.gsx` files.
- Enhancements apply to subtypes/subclasses of the enhanced type.
- Enhancements should not be used to place narrow UI-only behavior on domain entities.

## UI helper classes

Best practice: place PCF/screen-support logic in a UI helper class when it is more than a small PCF-specific snippet.

Avoid:

- large PCF Code tab blocks
- entity enhancements used only for one screen's UI behavior

Acceptable:

- small PCF-specific initialization snippets in PCF code area
- reusable UI helper classes for screen logic

## Deprecated/internal APIs

If code uses deprecated classes/methods or internal packages, flag for review and verify whether a supported replacement exists.
