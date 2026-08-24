# Typelist

## Overview
A typelist is a named set of allowed values (called typecodes or typekeys) that represent a finite set of choices for a field in the InsuranceSuite data model. In web service APIs, typelist values are represented as constants within enumeration classes — for example, the LossType class contains values such as LossType.TC_WC for the Workers Compensation loss type. 

Typelists are a core component of the InsuranceSuite data model alongside persistent entities, controlling which values can be stored in specific fields. 

## Anatomy of a Typecode
Each individual value within a typelist is a typecode, which comprises three elements: 

1. **code** — the value the database stores as a column value
2. **name** — the label the user interface displays (e.g., in drop-down lists)
3. **priority** — a setting that controls the ordering of typecode names in drop-down lists


## File Types and Organization
Typelist files use specific file extensions that determine their role:

| File Extension	| Purpose |
|------------------|---------|
|`.tti`|	Base typelist definition (internal/base configuration)|
|`.tix`|	Extendable typelist definition|
|`.ttx`|	Typelist extension file|

Extension files are stored at:

configuration/config/extensions/typelist

Base typelists (those you may want to extend) live under:

configuration/config/Metadata/Typelist

## Key Structural Elements
A typelist file is an XML-based metadata file containing the following structural elements:

- `typelist` — the root element declaring the list and its name
- `typecode` elements — each defining an individual allowed value with code, name, and priority attributes
- `typefilter` elements — optional sub-structures that define filtered subsets of typecodes, used when a field's available choices depend on the value of another field (e.g., PersonalVehicle.BodyType filtered by VehicleType in PolicyCenter, or ActivityPattern.Category filtered by ActivityType in BillingCenter) 

## Qualified vs. Unqualified Extension Files
Typelist extension files (.ttx) come in two forms: 

Unqualified: No qualifier in the file name (e.g., Foo.ttx). Each extendable typelist may have at most one unqualified extension.
Qualified: Has a qualifier in the file name (e.g., Foo.bar.ttx, where bar is the qualifier). A typelist may have any number of qualified extensions.
Qualified extensions may reference typecodes defined in the unqualified extension.

### Creating vs. Extending a Typelist

Before making a typelist change, determine whether the requirement is for a new custom typelist or an extension of an existing typelist.

- For a new customer-defined typelist, create a `.tti` definition in the customer extension area.
- To add customer typecodes to an existing extendable base typelist, use a `.ttx` extension rather than modifying the base typelist.
- Before creating a new typelist, check whether an existing base or customer typelist already represents the required business concept.
- Before creating a `.ttx`, check whether an unqualified or qualified extension already exists for the target typelist.

### Naming Rules

- Typecodes added to a base application typelist should use the `_Ext` suffix.
- Example: if `Phone.tti` is extended through `Phone.ttx`, a customer-added typecode can be named `Other_Ext`.
- Do not assume that every typecode in a completely new customer-defined typelist requires `_Ext`. Apply the project's naming convention for new customer typelists and distinguish this case from extending a base typelist.
- Avoid creating a new typecode whose `code` duplicates an existing base or extension typecode.

### Base Configuration and Extensions

A base `.tti` contains the original Guidewire typelist definition. Customer-specific typecodes are usually added through an extension instead of changing the base file. This keeps Guidewire configuration separate from custom changes.

When working with an existing typelist, the requested change may belong to the base definition, an existing extension, or a new extension file. Determining which of these applies is part of understanding the current typelist structure before making a change.

### Typekeys

A typekey is an entity field associated with a typelist.

- A typekey stores/references a value from its associated typelist.
- When reviewing a typekey field, identify the typelist it references.
- A typekey can reference at most one typefilter from its associated typelist.
- If a field should allow only a subset of the typelist, check whether a typefilter is appropriate before implementing separate filtering logic elsewhere.

