# Entity and Data Model Rules

These are correctness rules, not style preferences — violating them causes data corruption, silent failures, or runtime exceptions. Full background: `/context/gosu/platform/04-data-model-entity-metadata-and-typelists.md`.

## Platform-Owned Metadata Files Are Read-Only

The following file types are owned by the Guidewire platform and must **never** be customer-modified:

| File type | Purpose | Customer equivalent |
|---|---|---|
| `.eti` | Base entity definitions | `.etx` — add fields here |
| `.eix` | Internal entity extensions | `.etx` — add fields here |
| `.tti` | Base typelist definitions | `.ttx` — add typecodes here |
| `.tix` | Platform typelist extensions | `.ttx` — add typecodes here |

Hand-editing these files will cause upgrade conflicts and may be silently overwritten.

## Generated Entity Classes Are Read-Only

Entity classes in Gosu (e.g. `entity.Policy`) are **runtime-generated** from `.eti`/`.etx` metadata at build time. Never hand-edit these generated classes — changes will be overwritten on the next build and are invisible to the platform's schema management.

## Never Report Entity Field or Method Facts Without Verifying Project Metadata

Training data and documentation may be stale. Before stating that a field, method, or relationship does or does not exist on an entity:

1. Check `.eti` / `.etx` / `.eix` files for fields and relationships.
2. Check `.gsx` enhancement files for methods and computed properties.
3. Check `.tti` / `.ttx` for valid typecodes.

Only project files are authoritative — do not rely on memory or external references.

## `setFieldValue` Is Forbidden

**Never call `setFieldValue` on an entity.** It bypasses type safety, skips validation hooks, and can silently corrupt data.

**Do instead:** always use the typed property setter that the entity metadata generates.

```gosu
// WRONG
policy.setFieldValue("PolicyNumber", "ABC123")

// CORRECT
policy.PolicyNumber = "ABC123"
```

## Array Relationship Mutation — Use `addToX()` / `removeFromX()`

Never assign directly to an entity's array relationship property. Array relationships are managed by the platform — direct assignment is not supported and produces incorrect behavior.

```gosu
// WRONG
claim.Exposures = myExposureList

// CORRECT
claim.addToExposures(newExposure)
claim.removeFromExposures(oldExposure)
```

## Typekey Comparisons — Constants, Not Strings

Typekey fields must be compared to **typekey constants**, not string literals. String comparison bypasses type safety and breaks when typecodes are renamed or filtered.

```gosu
// WRONG
if (policy.Status == "draft") { ... }

// CORRECT
if (policy.Status == PolicyStatus.TC_DRAFT) { ... }
```

Use `.Code` or `.Name` only when a string representation is genuinely needed (e.g. for display or serialization).

## String Fields Auto-Trim

Guidewire string entity fields are **automatically trimmed** on assignment. Do not add explicit `.trim()` calls — they are redundant and signal a misunderstanding of the platform's behavior.

## Entity Fields Come from Metadata, Not `.gs` Files

An entity's available fields are defined in `.eti` / `.etx` / `.eix` XML metadata files, not in Gosu source. Never assume a field exists because a class with a similar name exists in Gosu — always verify the field is declared in the entity metadata before referencing it.

## Subtype Awareness

When working with a base entity type (e.g. `Account`), be aware that concrete instances may be subtypes (e.g. `PersonAccount`, `CompanyAccount`). Use `typeis` to check the runtime subtype before accessing subtype-specific fields or methods.

```gosu
if (account typeis PersonAccount) {
  var firstName = (account as PersonAccount).FirstName
}
```
