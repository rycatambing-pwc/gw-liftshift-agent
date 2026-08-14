---
document: data-model-entity-metadata-and-typelists
purpose: Teach an agent where PolicyCenter entity fields, generated properties, relationships, and typekeys come from
scope: `.eti`, `.etx`, `.eix`, `.tti`, `.ttx`, `.tix`, Data Dictionary, generated entity classes
---

# Data Model, Entity Metadata, and Typelists

## Why this matters

PolicyCenter entities are not ordinary hand-written Java/Gosu classes. Entity fields, relationships, typekey fields, delegates, and generated accessors are declared in data model metadata and generated into runtime classes.

## Entity files

| File type | Meaning | Agent action |
|---|---|---|
| `.eti` | Entity definition | Check for base fields, relationships, delegates, subtype/supertype. |
| `.etx` | Customer entity extension | Check for custom fields added to base entity. |
| `.eix` | Internal/platform extension | Treat as platform-owned/read-only unless project practice says otherwise. |

## Typelist files

| File type | Meaning | Agent action |
|---|---|---|
| `.tti` | Base typelist | Check available typecodes and typelist metadata. |
| `.ttx` | Customer typelist extension | Check custom typecodes and categories. |
| `.tix` | Internal/platform typelist extension | Treat as platform-owned extension. |

## Entity mental model

- An entity represents a business object.
- Entities serve as root objects for UI, rules, and data-related logic.
- Entities define fields and relationships.
- Code generators create corresponding Java/Gosu-accessible classes.
- ETI and ETX fields combine into one logical entity view.

## Column and relationship types

| Relationship | Recognition | Analysis guidance |
|---|---|---|
| Data column | primitive/string/date/decimal field | Verify datatype and nullability. |
| Foreign key | link to another entity | Treat dot-path traversal as potential lazy/runtime access. |
| Array | collection maintained by runtime/code | May not be physically stored as an array; inspect backing relation. |
| One-to-one | split logical entity across physical entities | Verify FK direction. |
| Many-to-many | join/association entity | Often requires non-null FKs and uniqueness constraints. |
| Circular/edge relationship | `edgeForeignKey` | Verify ordering/insertion/deletion implications. |

## Subtypes and supertypes

- A subtype inherits fields from its supertype.
- A supertype table may contain columns for subtypes in denormalized form.
- Irrelevant subtype columns may be null.
- Base subtypes may also be extendable.
- When scanning subtype field access, check both subtype and supertype metadata.

## Typekeys and typecodes

A typekey field is an entity field associated with a typelist.

Do not analyze this as a string:

```gosu
if (claim.LossCause == LossCause.TC_REAREND) {
}
```

or:

```gosu
if (line.LineOfBusinessType == typekey.LineOfBusinessType.TC_PERSONALAUTOLINE) {
}
```

Agent rule:

- Check the associated typelist.
- Verify the exact typecode constant.
- Do not replace with string comparisons unless the field is truly a string.

## Typefilters

A typefilter defines a named subset of typecodes available for a typekey field. When a UI/dropdown or field seems to show only part of a typelist, check for typefilters.

## Data Dictionary

The Data Dictionary documents entities, typelists, fields, and customer extensions. It is generated with:

```text
gwb genDataDictionary
```

Use it as a project source of truth after source files.

## Naming and extension notes

- Fields added to existing base entities commonly end with `_Ext`.
- Custom entities and custom typelists commonly use `_Ext` naming conventions.
- A base typelist can have at most one extension typelist in common training materials.
- Normalize naming rules against project standards before enforcing them.

## Agent checks

When seeing `Entity#Field` or `entity.Field`:

1. Identify `Entity` type.
2. Search `.eti`.
3. Search matching `.etx`.
4. Check subtype/supertype metadata.
5. If typekey, search typelist files.
6. If unresolved, search generated Data Dictionary/Gosudoc.
7. Report uncertainty if not verified.
