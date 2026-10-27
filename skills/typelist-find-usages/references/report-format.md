# Typelist usage report format

> Reference for the `typelist-find-usages` skill. Read it when the user chose to save the results (Step 5).
> Moved out of SKILL.md without changes to the steps.

```markdown
# Typelist Usage Report: <TypelistName>

> Generated: <YYYY-MM-DD HH:MM>
> Typelist File: <path to .tti file>
> Final: <true/false>
> Typecodes: <count>
> Extensions Found: <list of .ttx files>

## Summary

| Metric | Value |
|--------|-------|
| Entity typekey references | <count> |
| Gosu file usages | <count> |
| PCF file usages | <count> |
| Display property references | <count> |
| Configuration/XML references | <count> |
| BizRules references | <count> |
| Typelist mapping entries | <count> |
| **Total usages** | **<count>** |

## Typecodes Defined

| Code | Name | Priority | Retired |
|------|------|----------|---------|
| <code> | <name> | <priority> | <retired> |

## Usages in Entity Definitions

| # | Entity File | Entity Name | Field Name | Typefilter | Keyfilter |
|---|-------------|-------------|------------|------------|-----------|
| 1 | <relative_path> | <entity> | <field> | <filter or —> | <keyfilter or —> |

## Usages in Gosu Files (`configuration/gsrc/`)

| # | File | Line | Code |
|---|------|------|------|
| 1 | <relative_path> | <line_number> | `<trimmed line content>` |

## Usages in PCF Files (`configuration/config/web/pcf/`)

| # | File | Line | Code |
|---|------|------|------|
| 1 | <relative_path> | <line_number> | `<trimmed line content>` |

## Usages in Display Properties

| # | File | Property Key |
|---|------|-------------|
| 1 | <relative_path> | <property_key> |

## Usages in Configuration/XML Files

| # | File | Line | Context |
|---|------|------|---------|
| 1 | <relative_path> | <line_number> | `<trimmed line content>` |

## Usages in BizRules

| # | File | Line | Context |
|---|------|------|---------|
| 1 | <relative_path> | <line_number> | `<trimmed line content>` |

## Typelist Mapping

| Typecode | Namespace | Alias |
|----------|-----------|-------|
| <typecode> | <namespace> | <alias> |

---

*Search patterns: `typelist="<TypelistName>"`, `typekey\.<TypelistName>\.TC_\w+`, `\b<TypelistName>\b` (case-sensitive)*
```
