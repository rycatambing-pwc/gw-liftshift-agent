---
document: gosu-query-format-proposal
purpose: Standard format for documenting and analyzing Gosu Query API patterns
scope: Guidewire `gw.api.database.Query` pattern cards
---

# Proposed Format for Gosu Query Patterns

Use this pattern-card structure whenever documenting Gosu Query API behavior.

```markdown
### [QUERY_PATTERN_ID: HumanReadableName]

<intent>
What data question this query answers.
</intent>

<recognition_triggers>
Syntax fragments that should trigger this card.
</recognition_triggers>

<sql_analogy>
Approximate SQL equivalent. Mark as analogy, not exact generated SQL.
</sql_analogy>

<gosu_shape>
Minimal canonical Gosu shape.
</gosu_shape>

<annotated_example>
A realistic example with comments.
</annotated_example>

<analysis_steps>
How the agent should inspect this in a real codebase.
</analysis_steps>

<execution_semantics>
When DB work happens, what object is returned, and what remains lazy/deferred.
</execution_semantics>

<type_rules>
Rules for entity types, feature literals, typekeys, strings, dates, joins, arrays.
</type_rules>

<common_mistakes>
Wrong assumptions and corrections.
</common_mistakes>

<verification_needed>
Project-specific facts to check before claiming certainty.
</verification_needed>
```

## Why this format

Gosu Query API resembles SQL but is not SQL. It has entity queries, row queries, property references, result objects, standard filters, ordering, and platform-specific execution semantics.

The agent must answer these every time:

1. What is the primary entity returned?
2. What predicates are applied before retrieval?
3. What joins/subselects exist?
4. Are values strings, typekeys, dates, numbers, or entity references?
5. Is filtering/sorting/counting happening in the database or in memory?
6. Are returned entities being modified?
7. Is a writable bundle required?
8. What must be checked in the project metadata?

## Standard query summary output

For each query, prefer this summary:

```text
Primary entity: <Entity>
Returned object: <result type / result behavior>
Predicates: <field/operator/value>
Joins/subselects: <if any>
Database-level work: <filters/order/count>
In-memory work: <where/map/sum/firstWhere/etc. after retrieval>
Typekey checks: <verified/not verified>
Bundle/write checks: <read-only/writable/unknown>
Verification needed: <metadata, typelist, enhancement, generated docs>
```
