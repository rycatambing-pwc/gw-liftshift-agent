## Context

This template drives the phased LOB removal workflow. It was refined from 8 real LOB removals (CP7, CA7, WCM, GL7, CR7, CU, BP7, CPP) where the agent missed 50+ issues the user had to find manually. Every phase, check, and search path below exists because a real failure proved it necessary.

**Before executing any phase, load `resources/lob-removal-lessons.md` for the full catalog of past failures and mitigations.**

## Workflow

1. Before starting, verify the agent-logs folder exists: `.pwc/agent/work-logs`.
2. Create a log file: `lob-removal-<LOB_CODE>-<YYYYMMDD>-<HHmmss>.md` following `log-format-spec.md`.
3. For each action, log a row with: timestamp (UTC ISO 8601), action category (`REMOVED`, `ADDED`, `MODIFIED`, `EXECUTED`, `VERIFIED`, `SKIPPED`, `QUERY`, `ERROR`), outcome (`OK`, `FAIL`, `WARN`, `PENDING`, `N/A`), target file/command, detail, and responsible agent. Append each impacted file to the Fallout Summary incrementally.
4. Ask the user which LOB code will be removed. Ask for ALL alternate names and prefixes (e.g., CU → "Customer Umbrella", "UMB", "Umbrella"; WCM → "WC7", "WorkersComp", "WC"; CR7 → "Crime", "ConvR"). **Build the complete list of grep patterns from all names/prefixes.**
5. Check exit criteria at each phase. Log whether met. Once the user has approved the plan and said "go", execute all phases continuously — only stop to ask the user if an unexpected error or decision is needed.
6. Before troubleshooting, check `.pwc/agent/lessons` AND `resources/lob-removal-lessons.md` for known solutions.
7. LOB code matching is case insensitive. Use start-boundary grep only: `\b[lob_code]` NOT `\b[lob_code]\b`.

## Common Tasks

0. **Environment Setup**
    - Before opening any terminal, run `pc-init-env.bat` to set JAVA_HOME (JDK 21+) and IDEA_HOME (2024+). If the batch file doesn't exist, create one that sets these variables.

---

## Phase 1: Establish the Baseline

**Intent:** Verify the PolicyCenter project compiles and runs before making any changes.

**Tasks:**
- [ ] Run skill `pc-current-state`
- [ ] Ask the user to disable the APD / Iapd Service Plugin
- [ ] Open a terminal
- [ ] Run `gwb clean`
- [ ] Run `gwb compile`
- [ ] Run `gwb runServer`

**Exit Criteria:**
- `gwb clean` succeeded
- `gwb compile` succeeded
- `gwb runServer` started successfully

---

## Phase 2: Discovery & Subsystem Tracing

**Intent:** Before deleting ANYTHING, discover EVERYTHING the LOB owns. Past removals missed entire subsystems (WC Dividends: 20+ files, NCCI Integration: 7+ files, Crime Models: 8 files, EPLI Events: multiple files) because this phase was skipped.

**Tasks:**
- [ ] **Grep for ALL LOB prefixes** (primary code + all alternates) across ALL paths in the Mandatory Search Scope (see SKILL.md). Use start-boundary patterns.
- [ ] **Find all LOB entities and typelists** — `.eti`, `.etx`, `.tti`, `.ttx`, `.tix` files.
- [ ] **For EACH LOB entity found, trace the full dependency chain:**
    - Entity → batch processes → scheduler entries
    - Entity → event rules → `order.txt` → messaging destinations
    - Entity → plugin registries (`.gwp`)
    - Entity → webservice endpoints (`.wsdl`, `.wsc`)
    - Entity → display names, display keys (ALL locale variants)
    - Entity → systable registrations (ALL `systables*.xml` files)
    - Entity → Gosu templates (`.gst`) — runtime crash risk
    - Entity → mock/sample data files
    - Entity → REST API schema files (`.schema.json`)
    - Entity → test files (`gtest/`)
- [ ] **Find all LOB Gosu code** — `gsrc/` recursive search.
- [ ] **Find all LOB PCF/UI files** — `config/web/pcf/` search.
- [ ] **Find all LOB product model files** — product model directory.
- [ ] **Find all LOB configuration registrations** across all mandatory search paths.
- [ ] **Build the complete inventory** grouped by subsystem. Present to the user for review.

**Exit Criteria:**
- Complete inventory produced and reviewed by user
- All subsystems identified (not just individual files)
- User has approved the inventory before proceeding

---

## Phase 3: Remove LOB PCF Files

**Tasks:**
- [ ] Run `pcf-find-usages` against ALL PCF files in `configuration/config/web/pcf/line/[lob_code]` to produce a reference map of consumers
- [ ] Remove or update `PanelRef`/`InputSetRef` elements in base PCFs whose `def` targets a deleted file
- [ ] Remove `LocationRef` entries in LocationGroup PCFs pointing to deleted LOB pages
- [ ] Find and delete LOB-specific mode files outside the LOB folder (e.g., in `line/common/`)
- [ ] Remove LOB entries from shared navigation PCFs (`LineWizardStepSet`, `PolicyMenuItemSet`, etc.)
- [ ] Delete the folder and its contents: `configuration/config/web/pcf/line/[lob_code]`
- [ ] Delete the folder: `configuration/config/productmodel/policylinepatterns/<lob>Line`
- [ ] Delete files matching: `[lob_code]ManuscriptEndorsementPopup.pcf`
- [ ] Run `gwb codegen` — expected: no errors

**Exit Criteria:**
- All PCF deletions completed
- No broken `PanelRef`, `InputSetRef`, or `LocationRef` references remain in base PCFs
- `gwb codegen` succeeded

---

## Phase 4: Remove Gosu Files

**Tasks:**
- [ ] Delete `configuration/gsrc/gw/lob/[lob_code_lower]/` folder
- [ ] Delete `configuration/gsrc/gw/cust/lob/[lob_code_lower]/` folder
- [ ] Delete `configuration/gsrc/ext/lob/[lob_code_lower]/` folder
- [ ] Delete `configuration/gsrc/gw/ext/sbt/bizrules/builder/[lob_code_lower]/` folder
- [ ] Delete webservice LOB files: `CC[lob_code]*` in `gsrc/gw/webservice/pc/pc5000/ccintegration/lob/`, `pc900/`, `pc910/`
- [ ] **Grep for any remaining LOB Gosu files** outside these standard paths. Past removals found files in unexpected locations (e.g., `SBTWCClassCodesToOOTB.gs`, `AddressVerificationUIHelper.gs`).

**Exit Criteria:**
- All LOB Gosu folders and files deleted
- No LOB Gosu files remain outside standard paths

---

## Phase 5: Refactor Shared Gosu Files

**Intent:** Remove LOB references from shared Gosu files. This is where consumer-first deletion is CRITICAL.

**Tasks:**

For EACH file below (and any additional files found during Phase 2 discovery):

1. **Grep the entire codebase** for each LOB symbol (constant, type, import) that will be removed from this file
2. **Remove all consumers first** (in other files)
3. **Then edit the shared file** to remove LOB references
4. **After editing, read the file** to verify syntax is valid (no orphaned braces, dangling else, empty blocks)

Standard files to refactor:
- [ ] `gsrc/cust/lob/common/LobCommonAdditionalInsuredHelperFactory.gs`
- [ ] `gsrc/cust/lob/common/schedules/LobScheduleColumnHelperFactory.gs`
- [ ] `gsrc/cust/lob/common/validation/PolicyPeriodValidation_Ext.gs`
- [ ] `gsrc/cust/pc/preupdate/PreUpdateHandler_Ext.gs`
- [ ] `gsrc/cust/plugin/rateflow/RateQueryWithFailoverLookupPlugin_Ext.gs`
- [ ] `gsrc/gw/policylocation/PolicyLocationEnhancement.gsx`
- [ ] `gsrc/gw/lob/common/LobPropertyServices.gs`
- [ ] `gsrc/gw/rest/ext/pc/job/v1/JobApiExtHandler.gs`
- [ ] `gsrc/gw/rest/internal/pc/dgc/job/v1/coverage/CovTermEnhancementDgc.gsx`

**Additional files frequently missed — CHECK THESE:**
- [ ] `AccountHelper_Ext.gs` — referenced `TC_BOP_ELIGIBLE` after BP7 typecode was deleted
- [ ] `CovTermEnhancementDgc.gsx` — referenced deleted constants
- [ ] `ClauseEnhancementDgc.gsx`
- [ ] `PolicyPeriodBaseEnhancement.gsx`
- [ ] `CUSTRenewalProcessImpl.gs`
- [ ] `SubmissionWizard_PolicyInfoDV.pcf` — referenced deleted constants
- [ ] Any `.gsx` enhancement files found during Phase 2

**FRAGILE FILE — SPECIAL HANDLING:**
- [ ] `UnderwriterEvaluatorTriggeringPoint_Ext.gs` — Read fresh. Remove ONLY the LOB-specific typecodes. After editing, verify EVERY remaining typecode exists in `RuleContextDefinitionKey.ttx`. If Gosu reports `ArrayList<ErrorType>` cascade errors, only 1-2 entries are actually bad.

**Exit Criteria:**
- All shared Gosu files refactored
- No orphaned syntax errors
- `UnderwriterEvaluatorTriggeringPoint_Ext.gs` verified — all remaining typecodes valid

---

## Phase 6: BizRules Bootstrap Updates

**Tasks:**
- [ ] Navigate to `configuration/config/import/bizrules/`
- [ ] Find and delete gwrules files with prefix matching [lob_code]
- [ ] Task the entity-agent to remove [lob_code] references in `AppCritLineOfBusiness.eti`
- [ ] **Check `config/bizrules/` and `config/gwrules/`** for any remaining LOB references (BP7 had a pre-existing gwrules bootstrap reference that caused BizRules import failure)

**Exit Criteria:**
- All LOB gwrules files deleted
- No [lob_code] references in `AppCritLineOfBusiness.eti`
- No LOB references in `config/bizrules/` or `config/gwrules/`

---

## Phase 7: Update Configuration Files

**Tasks:**
- [ ] Delete `configuration/config/resources/systables/custom_form_inference.[lob_code].xml`
- [ ] Delete `configuration/config/resources/systables/[lob_code]-*.xml`
- [ ] Delete `configuration/config/resources/systables.[lob_code].xml`
- [ ] **Remove LOB registrations from `systables.xml`** — check for entries pointing to deleted files
- [ ] **Remove LOB registrations from `systables.CUST.xml`** — this file was missed during CU removal, causing `FileNotFoundException`
- [ ] **Remove LOB registrations from ANY `systables.*.xml` variant** — check ALL of them
- [ ] Delete `configuration/config/content/submissionintake/Mapping Script_[lob_code]Line.kts`
- [ ] **Check `config/xml/config.xml`** for LOB-specific parameters (e.g., `EnableCPDTOParallelRating` was missed for CP7)
- [ ] **Check `config/statesets/StateSets.xml`** — WCM entries were missed
- [ ] **Check `config/resources/ResourceContextMap.xml`** — WCM entries were missed

**Exit Criteria:**
- All LOB systable files and registrations removed
- No LOB parameters in `config.xml`
- No LOB entries in `StateSets.xml` or `ResourceContextMap.xml`

---

## Phase 8: Remove Display Properties and Locale Files

**Intent:** This phase was the single biggest source of missed remnants. The user manually found 2,000+ orphaned keys across multiple properties files the agent never searched. EVERY file in this list must be swept.

**Tasks:**

For EACH properties file below, grep for ALL LOB prefixes (primary + alternates) and present matches to the user before removing:

- [ ] `config/locale/display.properties` — main English display keys. Match on key name before `=` only.
- [ ] `config/locale/display_en_US.properties` — WCM had 15 `WC7CoveredEmployee` data flow mask keys here
- [ ] `config/locale/display_yy.properties` — test locale, same keys as en_US
- [ ] `config/locale/productmodel.display.properties` — BP7 had 1,310 keys, GL7 had 839 keys here. DO NOT skip this file.
- [ ] `config/locale/typelist.properties` — CU had 10 keys + 34 rule context keys for ALL LOBs + `APDCloudProduct`/`InstalledPolicyLine` entries
- [ ] `config/locale/typelist_en_US.properties` — `LOBName_UM.CommercialProperty`, `WorkersComp` entries were here
- [ ] `config/locale/typelist_yy.properties` — same entries as en_US
- [ ] `config/locale/typelist_es.properties` — `ClassCodeType.CR` Spanish translation was here
- [ ] `config/locale/typelist_es_ES.properties` — Spain translation variant
- [ ] `config/locale/schema.display.properties` — CU Underlying Policy schema keys were here
- [ ] `config/locale/schema.display_en_US_EDG.properties` — CU Edge keys were here
- [ ] `config/locale/schema.display_en_US_EDG_PH.properties` — CU Edge PH keys were here
- [ ] `config/extensions/displayname/*.en` — Find and delete LOB displayname files (e.g., `BP7Building.en`). Also check individual `.en` files like `TerritoryCode.en` that had BP7 entries.
- [ ] `config/displaynames/*.en` — same check in this alternate location
- [ ] `config/smoketests/typelists.properties` — THIS FILE IS ALWAYS MISSED. CPP had entries here that no agent ever found.

**Exit Criteria:**
- ZERO LOB-prefixed keys in ALL properties files listed above
- ZERO LOB displayname files remaining
- Smoketests properties verified clean

---

## Phase 9: Ratebook Removal

**Tasks:**
- [ ] Delete `configuration/config/content/cust-ratebooks/[lob_code]/` folder
- [ ] Delete `configuration/config/content/iso-ratebooks/[lob_code]/` folder
- [ ] Delete `configuration/build/idea/classes/updates/adopted/SBT*[lob_code]*.zip` if it exists

**Exit Criteria:**
- All LOB ratebook folders and SBT artifacts deleted

---

## Phase 10: Cleanup API Enablement Config

**Tasks:**
- [ ] Delete `configuration/config/integration/apis/installedlobs/[lob_code]_ext-1.0.yaml`
- [ ] Delete `configuration/config/integration/apis/installedlobs/[lob_code]_codegen_config_ext-1.0.yaml`
- [ ] **Grep REST API schema files** (`integration/**/*.schema.json`) for LOB type references — `CUPolicyType` and `coverageNameCU_Ext` were both missed in `policyperiod_ext-1.0.schema.json`
- [ ] Run `gwb clean`
- [ ] Run `gwb codegen`

**Exit Criteria:**
- API YAML files deleted
- ZERO LOB references in REST API schema files
- `gwb codegen` succeeded

---

## Phase 11: Remove Entity Extensions

**Tasks:**
- [ ] Run `gwb clean`
- [ ] Navigate to `configuration/config/extensions/entity/`
- [ ] Run `entity-find-usages` skill against each LOB entity before deletion (to find consumers)
- [ ] Find entity files matching LOB prefix: `*.eti`, `*.etx`, `*.eix`
- [ ] Report matches to the user and get approval
- [ ] Delete matching entity files
- [ ] Delete `[lob_code].state.etx` if present
- [ ] Delete `[lob_code].CUST.etx` if present
- [ ] Delete `PolicyPeriod.[lob_code].etx` if present
- [ ] **Check for any LOB entity files OUTSIDE the standard path** — `WCClassAdjustment_Ext.eti` was found still on disk after WCM removal
- [ ] **Check event rule entries** in entity `.etx` event blocks — EPLI events in `PolicyPeriod.etx` were missed during CU removal
- [ ] Run `gwb codegen`

**Exit Criteria:**
- All LOB entity files deleted
- No LOB entity files remaining anywhere on disk
- `gwb codegen` succeeded

---

## Phase 12: Cleanup Typelists

**Tasks:**
- [ ] Run `typelist-find-usages` skill against each LOB typelist before deletion
- [ ] Find and delete `InstalledPolicyLine[lob_code].ttx`
- [ ] Task typelist-agent to remove [lob_code] entries from `PolicyLine.ttx`
- [ ] **Check ALL `.ttx` files** in `config/extensions/typelist/` for typecodes mentioning the LOB — `PropFacCoverageBucket_Ext.tti` had a "Commercial Property" typecode for CP7, `ResourceContext.ttx` had "Guidewire WC" for WCM
- [ ] Run `gwb codegen`

**Exit Criteria:**
- All LOB typelist files and entries removed
- ZERO LOB typecodes in any `.ttx` file
- `gwb codegen` succeeded

---

## Phase 13: Remove Templates, Tests, and Mock Data

**Intent:** These files were systematically missed in past removals. `.gst` templates don't cause compile errors but CRASH at runtime.

**Tasks:**
- [ ] **Grep ALL `.gst` files** for LOB entity property references — `VeriskPrometrixDocument_Ext.gst` had 147 lines of Crime section referencing deleted properties
- [ ] Delete LOB-specific `.gst` template files or remove LOB sections from shared templates
- [ ] **Search `gtest/`** for LOB test files — `CPRequirements.gs` was a complete CP7 test file left on disk
- [ ] **Search `**/mock/**` and `**/sample*/**`** for LOB mock/sample data — `SmallSampleCommunityData.gs` had WCM sample data
- [ ] Delete or clean all found files

**Exit Criteria:**
- ZERO LOB references in `.gst` files
- ZERO LOB test files in `gtest/`
- ZERO LOB mock/sample data files

---

## Phase 14: Handle Fragile Files

**Intent:** These files aggregate content from multiple LOBs and have broken repeatedly. Each gets individual attention.

**Tasks:**
- [ ] **`UnderwriterEvaluatorTriggeringPoint_Ext.gs`** — Read fresh. Verify EVERY remaining typecode exists in `RuleContextDefinitionKey.ttx`. If cascading `ErrorType` errors appear, only 1-2 entries are bad.
- [ ] **`EntityMetadataUtil.gs`** — Grep for any remaining LOB constant references.
- [ ] **`CommonConstants_Ext.gs`** — Verify no LOB-specific constants remain. If any were removed earlier, grep again for their consumers.
- [ ] **`display.properties`** — Re-read and verify no LOB keys remain (this file is edited across multiple phases and keys can be missed).
- [ ] **`productmodel.display.properties`** — Re-scan for bulk LOB keys (1,000+ per LOB).

**Exit Criteria:**
- All fragile files verified clean
- All remaining typecodes in `UnderwriterEvaluatorTriggeringPoint_Ext.gs` confirmed valid

---

## Phase 15: Exhaustive Verification Sweep (MANDATORY — DO NOT SKIP)

**Intent:** This phase exists because the user manually found 24+ categories of remnants after the agent declared LOB removal "complete." This is the source of truth — not agent self-reporting.

**Tasks:**
- [ ] Run a full codebase grep with start-boundary patterns for EVERY LOB prefix (primary code AND all alternates) across ALL paths in the Mandatory Search Scope (see SKILL.md).
- [ ] Verify ZERO hits in EACH of these specifically (all were missed in past removals):
    - `config/locale/typelist.properties`
    - `config/locale/typelist_en_US.properties`
    - `config/locale/typelist_yy.properties`
    - `config/locale/typelist_es.properties`
    - `config/locale/typelist_es_ES.properties`
    - `config/locale/display_en_US.properties`
    - `config/locale/display_yy.properties`
    - `config/locale/schema.display.properties`
    - `config/locale/schema.display_en_US_EDG.properties`
    - `config/locale/schema.display_en_US_EDG_PH.properties`
    - `config/smoketests/typelists.properties`
    - `config/resources/ResourceContextMap.xml`
    - `config/xml/config.xml`
    - `config/extensions/typelist/*.ttx` — all files
    - `integration/**/*.schema.json`
    - `gsrc/**/*.gst`
    - `gtest/**`
    - `config/extensions/displayname/*.en`
- [ ] **Check for entire LOB files still on disk** — entity files, test files, template files that should have been deleted but weren't.
- [ ] **Report ALL remaining hits** to the user with file path, line number, and match context. Do NOT silently skip any hit.
- [ ] **Clean up all remaining hits.**
- [ ] **Re-run the sweep** after cleanup — verify ZERO hits.

**Exit Criteria:**
- Full codebase grep returns ZERO LOB references in customer-owned files
- Sweep has been run TWICE — once to find remnants, once to confirm cleanup

---

## Phase 16: Milestone Check

**Tasks:**
- [ ] Run `gwb codegen`. If errors:
    1. Identify errors and generate a fix plan
    2. Present plan to user for approval
    3. Execute fixes
    4. Re-run until clean
- [ ] Run `gwb compile`. If errors:
    1. Classify each error: consumer referencing deleted symbol → remove consumer (return to Phase 5 logic). Syntax error → fix. Platform file → restore from git.
    2. Generate a fix plan
    3. Present plan to user for approval
    4. Execute fixes
    5. Re-run until clean

**Exit Criteria:**
- `gwb codegen` succeeded
- `gwb compile` succeeded

---

## Phase 17: Server Startup Verification

**Tasks:**
- [ ] Delete H2 database: `tmp/pc.mv.db` and `tmp/pc.lock.db`
- [ ] Run `gwb runServer`
- [ ] If startup errors, classify and fix:
    - `FileNotFoundException` → check systable registration files (`systables.xml`, `systables.CUST.xml`, ALL variants)
    - `ClassNotFoundException` → check rule `order.txt` entries
    - `Invalid typelist` in API → check REST API schema files
    - H2 cache errors → delete H2 and restart
    - `BizRules import failure` → check `config/bizrules/` and `config/gwrules/`
- [ ] Re-run server until it starts clean

**Exit Criteria:**
- Server reaches MULTIUSER run level
- No startup errors

---

## Phase 18: GUnit Test Updates

**Tasks:**
- [ ] Task gosu-agent to fix compile and test errors
- [ ] Run `gwb runSuite`
- [ ] Fix broken unit tests
- [ ] Re-run until all tests pass

**Exit Criteria:**
- All unit tests pass

---

## Phase 19: Final Verification Sweep

**Intent:** Fixes applied during Phases 16-18 can introduce NEW orphaned references. One last sweep.

**Tasks:**
- [ ] Run the same full codebase grep from Phase 15
- [ ] If any new hits found, clean them up
- [ ] Verify ZERO hits

**Exit Criteria:**
- ZERO LOB references in customer-owned files
- LOB removal is COMPLETE

---

## Success Criteria (ALL must be met)

- [ ] All phases completed with exit criteria met
- [ ] `gwb codegen` completes successfully
- [ ] `gwb compile` completes successfully
- [ ] Server starts to MULTIUSER run level
- [ ] All GUnit tests pass
- [ ] Final verification sweep returns ZERO LOB references in customer-owned files
- [ ] Work log is complete with all actions logged
