---
document: validation-checklist
purpose: Final review checklist before an agent returns Gosu/PolicyCenter findings
scope: Reduce hallucinations and overconfident analysis
---

# Validation Checklist

Before final output, answer these.

## File/context

- [ ] Did I identify the file type: `.gs`, `.gsx`, `.gr`, `.pcf`, `.eti`, `.etx`, `.tti`, `.ttx`, etc.?
- [ ] Did I identify execution context: UI, rule, plugin, batch, web service, query, test?

## Symbol resolution

- [ ] Did I check `.gsx` for unresolved methods/properties?
- [ ] Did I check `.eti/.etx/.eix` for entity fields?
- [ ] Did I check `.tti/.ttx/.tix` for typekey/typecode references?
- [ ] Did I check PCF root variables or row iterator `elementName` where relevant?
- [ ] Did I check generated Data Dictionary/Gosudoc/Javadoc if needed?

## Gosu semantics

- [ ] Did I handle `==` vs `===` correctly?
- [ ] Did I treat `Type#Field` as a feature/property reference?
- [ ] Did I distinguish collection blocks from database predicates?

## Query semantics

- [ ] Did I identify the primary entity returned?
- [ ] Did I list predicates, joins, subselects, and ordering?
- [ ] Did I distinguish database filtering from in-memory filtering?
- [ ] Did I avoid treating typekey values as strings?
- [ ] Did I identify query performance anti-patterns?

## Runtime/write behavior

- [ ] Are returned entities read-only or writable?
- [ ] Is there a writable bundle?
- [ ] If `bundle.add(...)` appears, is the returned writable reference modified?
- [ ] Could bundle size/paging be a problem?

## PCF/rules/validation

- [ ] Did I identify root object, variables, RowIterator element names, and modes?
- [ ] Did I distinguish UI `validationExpression` from validation rules?
- [ ] Did I check `Validatable`, `implementsEntity`, and `triggersValidation` where relevant?

## Final answer discipline

- [ ] Separate verified facts from inferred facts.
- [ ] State project-specific verification needed.
- [ ] Do not claim compile correctness unless validated against target project/version.
