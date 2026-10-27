# LOB Removal Lessons Learned

Source: 8 LOB removals (CP7, CA7, WCM, GL7, CR7, CU, BP7, CPP) completed 2026-09-16 to 2026-09-18. Only IM (Inland Marine) retained.

The user manually found 24+ categories of remnants and 10+ compile errors the agent missed. This document catalogs every failure so agents can prevent them.

---

## The 13 Rules (Each Learned from a Real Failure)

### 1. Always Remove ALL Consumers Before Removing a Definition
**Error count:** 15+ compile errors across all LOBs
**Root cause:** Agents removed constants, typecodes, entity fields, and typelist files without first grepping for every consumer.
**Fix:** Before deleting any symbol, grep the entire codebase. Remove every consumer first, then delete the definition. Grep again after to verify zero references.

Specific failures:
| Symbol removed | Consumer left behind | File |
|---|---|---|
| `BOP_ELIGIBLE` typecode | `TC_BOP_ELIGIBLE` | `AccountHelper_Ext.gs` |
| `NON_EDITABLE_COVTERMS_FIELDS_PRTL` | use in Gosu | `CovTermEnhancementDgc.gsx` |
| `UMB_PRODUCTCODE_EXT` | reference in PCF | `SubmissionWizard_PolicyInfoDV.pcf` |
| WCM constants | `WCM_EACHACCIDENTLIMIT_KEY` | `EntityMetadataUtil.gs` |
| BP7/WCM/CU typecodes | various TC_ constants | `UnderwriterEvaluatorTriggeringPoint_Ext.gs` |

### 2. Trace Feature Subsystems, Not Just Individual Files
**Error count:** 20+ files missed (WC Dividends subsystem alone)
**Root cause:** The skill deleted individual LOB files but missed entire feature subsystems.

Entire subsystems missed:
| Subsystem | LOB | Files missed |
|---|---|---|
| WC Dividends | WCM | 20+ files (entities, typelists, batch, PCFs, rules, messaging, plugins, display keys, webservice) |
| NCCI Integration | WCM | 7+ files (entity extension, typelists, OfficialID types, enhancement, logger, test) |
| Crime Models (Verisk/ConvR) | CR7 | 8 files (3 model classes, 3 response model fields, 2 mapping methods) + 1 template |
| EPLI Events & Systables | CU | Events in PolicyPeriod.etx, systable data files, systables.CUST.xml registrations |

### 3. Check ALL Systables Registration Files
**Error count:** 3 FileNotFoundExceptions at server startup
**Missed:** `systables.CUST.xml` — agent didn't know this file existed. `employment_practices_liability_excluded_class_ext.xml` was deleted but registration left in `systables.CUST.xml`.
**Fix:** Check `systables.xml`, `systables.CUST.xml`, and any `systables.*.xml` variants.

### 4. Delete Rule order.txt Entries When Deleting .gr Files
**Error count:** 1 ClassNotFoundException crash (`DividendComp_Ext`)
**Fix:** When deleting any `.gr` rule, always remove its entry from the parent directory's `order.txt`.

### 5. Delete H2 Database After Entity/Systable Changes
**Error count:** 3 startup failures
**Fix:** Delete `<config_root>/tmp/pc.mv.db` and `<config_root>/tmp/pc.lock.db` after any entity or systable deletion (the file named by `jdbc-url` in `config/database-config.xml`; a same-named file in another `tmp/` folder is not the one the server opens).

### 6. Never Modify Platform-Owned Files
**Error count:** 45 files wrongly modified, had to restore from git
Platform files: `gw/webservice/*` API Javadoc, `config/metadata/*`, `display_*.properties` translations, base `.eti`/`.tti`/`.tix` files.

### 7. Grep Patterns Must Use Start-Boundary Only
Use `\bWCM` NOT `\bWCM\b`. Missed: `WCMLocation`, `WCMLargeDeductible`, `WCMonopolistic`, `WCClassCode`.

### 8. Display Key Grep Must Match Key Names, Not Hash IDs
Failure: `grep -vi "bp7"` on productmodel.display.properties deleted a key whose auto-generated hash contained `bp7` — removed a valid Restaurant QuestionChoice ("Night Club").
**Fix:** Match on key name prefix before the `=` sign, not the entire line.

### 9. UnderwriterEvaluatorTriggeringPoint_Ext.gs Is Fragile
Broken 3 times across WCM, CU, BP7. Aggregates typecodes in one `addAll` block. One bad typecode cascades `ErrorType` to entire array.
**Fix:** Read fresh before every LOB removal. Verify all remaining typecodes exist in `RuleContextDefinitionKey.ttx`.

### 10. Sequence Definition Deletions After Reference Updates
**Fix:** Agent A (reference updater) runs first, Agent B (definition deleter) runs after. Never in parallel.

### 11. Check Gosu Templates (.gst) When Removing Model Properties
`VeriskPrometrixDocument_Ext.gst` had 147 lines referencing deleted `responseExt.Crime.*` — would crash at runtime but not at compile time.

### 12. Check Plugin Registry (.gwp), Messaging Config, and Scheduler
3 missed registrations caused startup failures.

### 13. Verify Mock/Test Data After Model Changes
Dead files left behind: `CPRequirements.gs` (gtest), `SmallSampleCommunityData.gs`, `WCClassAdjustment_Ext.eti` (entire entity still on disk).

---

## Complete Catalog of User-Caught Remnants

### Compile Errors Found by User

| # | File | Error | LOB |
|---|------|-------|-----|
| 1 | `UnderwriterEvaluatorTriggeringPoint_Ext.gs` | WCM typecodes not removed | WCM |
| 2 | `UnderwriterEvaluatorTriggeringPoint_Ext.gs` | CU typecodes not removed | CU |
| 3 | `UnderwriterEvaluatorTriggeringPoint_Ext.gs` | BP7 typecodes not removed | BP7 |
| 4 | `EntityMetadataUtil.gs` | Referenced deleted WCM constants | WCM |
| 5 | `SpecialCasesClauseLoadGenerator.gs` | Orphaned `{` and `}` braces | WCM |
| 6 | `PolicyContactRolePanelSet.PolicyAddlInsured.pcf` | Renamed CA7 display key to nonexistent key | CA7 |
| 7 | `PolicyPeriodValidation_Ext.gs` | Renamed GL7 display key to nonexistent key | GL7 |
| 8 | `AccountHelper_Ext.gs` | Referenced deleted `TC_BOP_ELIGIBLE` | BP7 |
| 9 | `CovTermEnhancementDgc.gsx` | Referenced deleted `NON_EDITABLE_COVTERMS_FIELDS_PRTL` | BP7 |
| 10 | `SubmissionWizard_PolicyInfoDV.pcf` | Referenced deleted `UMB_PRODUCTCODE_EXT` | CU |

### Server Startup Errors Found by User

| # | Error | LOB | Root Cause |
|---|-------|-----|------------|
| 1 | `CUPolicyType` invalid typelist in `policyperiod_ext-1.0.schema.json` | CU | Didn't clean REST API schema |
| 2 | `coverageNameCU_Ext` in same schema | CU | Same file, different property |
| 3 | Restaurant QuestionChoice missing — hash contained `bp7` | BP7 | Grep false positive on hash ID |
| 4 | `wc_decile_dividend_map.xml` FileNotFoundException | WCM | Deleted file, left registration in `systables.xml` |
| 5 | `employment_practices_liability_excluded_class_ext.xml` FileNotFoundException | CU | Deleted file, left registration in `systables.CUST.xml` |
| 6 | `DividendComp_Ext` ClassNotFoundException | WCM | Deleted rule .gr, left entry in `order.txt` |
| 7 | `BP7BusinessOwnersLine` BizRules import failure | BP7 | gwrules bootstrap file |

### Remnants Found by User in Manual Searches (24 Categories)

| # | File | What was left | LOB | Key count |
|---|------|--------------|-----|-----------|
| 1 | `display.properties` | CU Underlying Policy GL display keys | CU/GL7 | 58 |
| 2 | `productmodel.display.properties` | BP7 QuestionSet pre-qual keys | BP7 | 1,310 |
| 3 | `productmodel.display.properties` | GL7 QuestionSet pre-qual keys | GL7 | 839 |
| 4 | `PropFacCoverageBucket_Ext.tti` | "Commercial Property" typecode | CP7 | 1 |
| 5 | `config.xml` | `EnableCPDTOParallelRating` parameter | CP7 | 1 |
| 6 | `SmallSampleCommunityData.gs` | "Jillian Losttime Workers Comp" sample data | WCM | — |
| 7 | `display.properties` | CA7 validation keys | CA7 | 3 |
| 8 | `typelist.properties` | CUPolicyType display keys | CU | 10 |
| 9 | `typelist.properties` | LOB rule context display keys (ALL LOBs) | ALL | 34 |
| 10 | `typelist_en_US.properties` | `LOBName_UM.CommercialProperty` + `WorkersComp` | CP7/WCM | 2 |
| 11 | `typelist_yy.properties` | Same entries | CP7/WCM | 2 |
| 12 | `schema.display.properties` | CU Underlying Policy schema keys | CU | multiple |
| 13 | `schema.display_en_US_EDG.properties` | CU Edge keys | CU | multiple |
| 14 | `schema.display_en_US_EDG_PH.properties` | CU Edge PH keys | CU | multiple |
| 15 | `display_en_US.properties` | `WC7CoveredEmployee` data flow mask keys | WCM | 15 |
| 16 | `display_yy.properties` | Same test locale keys | WCM | 15 |
| 17 | `typelist.properties` | `APDCloudProduct.CommercialUmb` + `InstalledPolicyLine.CU` | CU | 2 |
| 18 | `typelist_es.properties` | `ClassCodeType.CR` Spanish translation | CR7 | 1 |
| 19 | `typelist_es_ES.properties` | `ClassCodeType.CR` Spain translation | CR7 | 1 |
| 20 | `VeriskPrometrixDocument_Ext.gst` | 147 lines Crime section | CR7 | — |
| 21 | `CPRequirements.gs` (gtest) | Entire CP7 rating test file | CP7 | — |
| 22 | `ResourceContext.ttx` | "Guidewire WC" typecode | WCM | 1 |
| 23 | `WCClassAdjustment_Ext.eti` | Entire WCM entity still on disk | WCM | — |
| 24 | `TerritoryCode.en` | BP7 displayname entry | BP7 | 1 |

---

## False Positive Handling

| LOB Prefix | Known False Positives | Mitigation |
|---|---|---|
| CP / CPP | `CPPolicy`, `CPPolicyBuildingIterative`, `CPClassCode` | Verify LOB code vs platform CP |
| CU | `CUSTOM`, `CURRENT`, `CURSOR`, `CUSTRenewalProcessImpl` | Use `\bCU[^a-z]` or specific identifiers |
| GL | `GLOBAL`, many platform terms | Use `GL7` or `\bGL7` |
| WC | `WC7` in platform typelists | Verify platform vs customer |
| CR | `CREATE`, `CREDENTIAL`, `CRITERIA` | Use `CR7` or `CRLine`, `CrimeCoverage` |
| BP | `BPProcess`, other platform terms | Use `BP7` or `\bBP7` |

---

## Post-Removal Verification Checklist

The detailed yes/no version, built from the catalog above, is `known-answer-checklist.md`. Use it in Phases 15 and 19.

- [ ] Full grep sweep with start-boundary patterns across ALL mandatory search paths
- [ ] ZERO hits in ALL locale variant properties files (en_US, yy, es, es_ES, EDG, EDG_PH)
- [ ] ZERO hits in smoketests directory
- [ ] ZERO hits in REST API schema files
- [ ] ZERO LOB entity files remaining on disk
- [ ] ZERO LOB displayname (.en/.es) files remaining
- [ ] ZERO LOB .gst template files remaining
- [ ] ZERO LOB gtest files remaining
- [ ] `UnderwriterEvaluatorTriggeringPoint_Ext.gs` verified — all remaining typecodes exist
- [ ] `gwb codegen` passes
- [ ] `gwb compile` passes with zero errors
- [ ] H2 database deleted
- [ ] Server starts to MULTIUSER run level
- [ ] Final grep sweep AFTER all fixes (fixes can introduce new orphans)
- [ ] Work log complete with all actions recorded

---

## Lesson 14: Agents Can Mangle Adjacent XML When Removing Blocks
**Error:** During CR7 removal from AAIS, the agent removing CR7 CancelRefund blocks from `cancel_refund.xml` accidentally stripped the `<` from a `<ExpirationDate/>` tag on an adjacent CA7 entry (line 490), turning it into bare text `ExpirationDate/>`. This caused "SCHEMA ERRORS IN PLUGIN FILES — Cannot have any text content" at server startup, preventing MULTIUSER.
**Root cause:** The agent's bulk edit operation clipped the edge of a neighboring XML block.
**Fix:** After any bulk XML block removal, grep the file for orphaned text content (lines that don't start with `<` or whitespace followed by `<`). Validate XML well-formedness before declaring done.
**How to apply:** Add a post-edit XML validation step: `grep -nP '^\s+[A-Z][a-zA-Z]+/>' <file>` to catch tags missing their `<` bracket.

## Lesson 15: Agents Can Accidentally Empty Non-Target Files During Bulk XML Cleanup
**Error:** During CR7 removal from AAIS, the agent cleaning SurePath FormPattern files accidentally zeroed out two CA7 files: `CA7FormPatterns.1.NE.xml` and `CA7FormPatterns.2.SD.xml` (0 bytes). These empty files caused "SCHEMA ERRORS IN PLUGIN FILES — Cannot have any text content" at server startup.
**Root cause:** The agent editing the SurePath directory to remove CR7 FormPattern blocks operated on CA7 files by mistake — likely matching on "Crime" content that appeared in CA7 form data, or mis-targeting the file during bulk operations.
**Fix:** Restored from git: `git checkout -- <file>`.
**How to apply:** After any bulk file modification in a shared directory, verify that ONLY the intended files were changed. Run `git diff --name-only` and check that no unexpected files appear. If a file's size drops to 0, it was accidentally emptied — restore from git immediately.
