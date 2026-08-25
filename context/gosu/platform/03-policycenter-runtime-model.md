---
document: policycenter-runtime-model
purpose: Explain PolicyCenter runtime concepts needed to understand Gosu code
scope: Runtime context, generated metadata, entities, typekeys, bundles, PCF/rules context
---

# PolicyCenter Runtime Model

Gosu syntax is only part of the problem. In PolicyCenter, much of the meaning comes from generated metadata and runtime services.

## Runtime concepts the agent must recognize

| Concept | Why it matters |
|---|---|
| Entity metadata | Fields/properties may come from `.eti`, `.etx`, or `.eix`, not `.gs`. |
| Typelists/typekeys | Many business values are typed platform values, not strings. |
| Enhancements | Methods/properties can be injected from `.gsx`. |
| Bundles | Entity writeability depends on transaction/bundle context. |
| Query API | Database filtering must be distinguished from in-memory filtering. |
| Effective dating | Policy entities may be time-sliced/versioned. Verify actual model behavior. |
| PCF context | Embedded Gosu variables come from root objects, PCF variables, row iterators, and modes. |
| Rules context | `.gr` files run under rule set categories with root entities and execution hierarchy. |

## Symbol resolution protocol

When scanning a symbol like `period.PolicyNumber`, do not assume it is declared in a `.gs` class.

Search in this order:

1. Local file scope.
2. `uses` imports.
3. Direct class/interface declaration.
4. `.gsx` enhancements.
5. `.eti` and `.etx` entity metadata.
6. `.tti`, `.ttx`, `.tix` typelists for typekey values.
7. PCF/rule variables if applicable.
8. Generated Gosudoc/Javadoc/Data Dictionary.

## Runtime modules

Use these deeper modules:

- Data model and typekeys: `platform/04-data-model-entity-metadata-and-typelists.md`
- Queries: `queries/05-query-format-proposal.md`, `queries/06-query-pattern-cards.md`, `queries/07-query-performance-antipatterns.md`
- PCF: `ui_and_rules/08-pcf-ui-model-and-embedded-gosu.md`
- Rules/validation/entity names: `ui_and_rules/09-rules-validation-and-entity-names.md`
- Bundles: `platform/10-bundles-and-transactions.md`

## Confidence rule

For any entity field, typelist, typecode, LOB-specific class, or product model reference, state whether it was verified in project files. If not verified, label it as needing project verification.
