---
document: gosu-agent-routing
purpose: Decide which Gosu/PolicyCenter reference module to load during code scanning
scope: Code analysis, retrieval routing, source lookup
---

# Agent Routing

## Always load

- `01-quick-mental-model.md`

## Trigger map

| Trigger in code | Load these files | Why |
|---|---|---|
| Unknown Gosu syntax, `var`, `uses`, `construct`, `typeis`, `\ x ->`, `*.`, `#` | `02-core-gosu-deltas.md` | Syntax and Java-to-Gosu deltas |
| Entity classes, `PolicyPeriod`, `Policy`, `Account`, generated properties | `03-policycenter-runtime-model.md`, `04-data-model-entity-metadata-and-typelists.md` | Entity behavior comes from metadata and runtime |
| `.eti`, `.etx`, `.eix`, `foreignkey`, `array`, `edgeForeignKey`, `implementsEntity` | `04-data-model-entity-metadata-and-typelists.md` | Entity metadata and relationships |
| `.tti`, `.ttx`, `.tix`, `typekey`, `typefilter`, typecode | `04-data-model-entity-metadata-and-typelists.md` | Typelist and typekey semantics |
| `Query.make`, `compare`, `compareIn`, `Relop`, `join`, `subselect`, `select` | `05-query-format-proposal.md`, `06-query-pattern-cards.md` | Query API shape and interpretation |
| `where(` after `select()`, `firstWhere`, `lastWhere`, `countWhere`, `hasMatch`, `contains`, `intersect`, `union`, `Empty`, `FirstResult`, `getCountLimitedBy`, `ArrayLoader` | `07-query-performance-antipatterns.md`, `06-query-pattern-cards.md` | Query performance and DB vs memory distinction |
| `.pcf`, `ListView`, `DetailView`, `InputSet`, `RowIterator`, `PanelRef`, `ListViewInput`, `ToolbarFilter`, `postOnChange`, `Client Reflection`, `validationExpression` | `08-pcf-ui-model-and-embedded-gosu.md` | PCF context and embedded Gosu |
| `.gr`, `Preupdate`, `Validation`, `EventMessage`, `actions.exit`, `DisplayName`, `.en`, `Validatable`, `rejectField`, `triggersValidation` | `09-rules-validation-and-entity-names.md` | Rules, validation, entity names |
| `Bundle`, `Transaction`, `runWithNewBundle`, `newBundle`, `getCurrent`, `bundle.add`, `commit` | `10-bundles-and-transactions.md` | Writable/read-only bundle semantics |
| `enhancement`, `.gsx`, `_Ext`, `ScriptParameter`, `GosuDoc`, `deprecated` | `11-gosu-style-naming-and-enhancements.md`, `02-core-gosu-deltas.md` | Enhancements and naming conventions |
| `_logger`, `Logger`, `StructuredLogger`, `CLF`, `contextMap`, `print(`, `DebugEnabled`, `ErrorEnabled` | `12-logging-and-structured-logger.md` | Logging review |
| `gtest`, `GUnit`, `assertTrue`, `assertEquals`, `@Suites`, `TestServer` | `13-gunit-testing.md` | Test file analysis |
| `Profiler.push`, `Profiler.pop`, `gwb inspect`, `DBCC`, schema validation, inspection | `14-system-health-profiler-dbcc-and-inspections.md` | Performance/static-analysis operational context |
| `Extractable`, `archivingOwner`, `Overlap`, domain graph, archive graph | `15-archiving-and-domain-graph.md` | Archiving/domain graph |

## Project-source lookup rules

When a symbol is unresolved:

1. Check local `.gs` or `.gr` file.
2. Check imports/`uses`.
3. Check `.gsx` enhancements.
4. Check entity metadata: `.eti`, `.etx`, `.eix`.
5. Check typelists: `.tti`, `.ttx`, `.tix`.
6. Check PCF variables/root objects if inside `.pcf`.
7. Check generated Gosudoc/Javadoc/Data Dictionary.

## Do not retrieve by semantics alone

Use rule-based triggers for code symbols. Short tokens such as `#Field`, `Relop`, `typekey`, and `.gsx` may not retrieve well using embeddings alone.
