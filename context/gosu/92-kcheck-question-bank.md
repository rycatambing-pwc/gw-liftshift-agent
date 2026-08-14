---
document: kcheck-question-bank
purpose: Lightweight validation prompts derived from uploaded KCheck/reviewer material
scope: Test whether the agent understood key concepts
---

# KCheck Question Bank

Use these as internal validation prompts, not as runtime reference prose.

## Data model

Q: Where are entity definitions and entity extensions stored?
A: Entity definitions are `.eti`; customer entity extensions are `.etx`; internal/platform extensions may be `.eix`.

Q: What happens to ETI and ETX fields?
A: They combine into the logical view of an entity and are represented through generated classes/docs.

Q: What is a typekey field?
A: An entity field associated with a typelist; values are typekeys/typecodes, not strings.

## PCF

Q: What are the two main PCF element categories?
A: Widget and Location.

Q: What RowIterator properties are required?
A: `value`, `valueType`, `elementName`, `editable`.

Q: What does `validationExpression` return to allow save?
A: `null`.

## Queries

Q: What method creates a query?
A: `Query.make(...)`.

Q: What method accesses query results?
A: `select()`.

Q: What is preferred over `select().toList().Count`?
A: `select().Count`, or `getCountLimitedBy(n)` when threshold checking.

Q: Where should filtering happen when possible?
A: In the database/query before retrieval.

## Bundles

Q: What is a bundle?
A: An in-memory container for entity instances that represent database rows and manages transactions.

Q: What happens if one entity in a bundle fails to commit?
A: Bundle changes roll back.

Q: When is manual bundle processing often required?
A: Web services, batch processes, modifications to query result entities, certain plugins, read-only UI contexts.

## Rules and validation

Q: What are common rule set categories?
A: EventMessage, Preupdate, Validation.

Q: What delegate is needed for validation rule behavior?
A: Validatable.

Q: What metadata attribute controls validation trigger from FK/array changes?
A: `triggersValidation`.

## Logging

Q: What are CLF log data components?
A: Core fields and contextMap fields.

Q: What logging level is appropriate when user experience is affected?
A: ERROR.

## GUnit

Q: Where are GUnit tests commonly located?
A: `modules/configuration/gtest`.

Q: What annotation groups tests into suites?
A: `@Suites`.
