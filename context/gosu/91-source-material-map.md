---
document: source-material-map
purpose: Track how uploaded references were used in v2 pack
scope: Provenance and inclusion/exclusion decisions
---

# Source Material Map

## Inclusion categories

- Core include: directly improves Gosu/PolicyCenter code scanning.
- Conditional include: useful only for specific scan types.
- Validation/test material: useful for checks, not primary reference prose.
- Archive only: outside current Gosu/code-scanning scope.

## Source decisions

| Source file | Decision | Used for |
|---|---|---|
| `best_practice.md` | Core + conditional | Query performance, PCF performance, naming/style, GosuDoc. |
| `bundle.md` | Core | Bundles and transaction module. |
| `data_model.md` | Core | Data model, entity metadata, typelists. |
| `data_model_and_pcf_kcheck.md` | Validation + core extraction | Data model facts, PCF facts, question bank. |
| `gosu.md` | Core + conditional | Gosu syntax, rules, logging, enhancements, validation, style. |
| `gosu_kcheck.md` | Validation + extraction | Rules, logging, query, bundle, GUnit checks. |
| `pcf.md` | Core | PCF architecture, ListView, RowIterator, locations. |
| `reviewer_insurancesuite_developer_fundamentals_dec2025.md` | Coverage roadmap + extraction | Cross-check across all modules. |
| `system_health_to_cloud_kcheck.md` | Conditional + archive | Profiler, DBCC, inspections; cloud/Git portions archived. |
| `guidwire_cloud_questions_with_answers_dec_2025.md` | Archive only | Cloud/Git/deployment Q&A; freshness-sensitive. |
| `_duplicate_redundancy_report.md` | Metadata only | Confirms overlap but no exact duplicates. |
| `README.md` | Metadata only | OCR warning and source package note. |

## OCR caution

KCheck and image-derived text may include OCR errors and selected/correct markers are best effort. Use those files for validation prompts and cross-checks, not as direct code examples.
