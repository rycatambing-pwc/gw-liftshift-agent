# Skill: pc-plan-lob-removal

## Purpose

Generate and execute a comprehensive plan for removing a Line of Business (LOB) from an existing Guidewire PolicyCenter project. This skill is invoked by the `gw-planner` agent to produce a structured, phased removal plan, then orchestrate execution across specialized agents with mandatory verification at every phase boundary.

**This skill was refined from 8 real LOB removals (CP7, CA7, WCM, GL7, CR7, CU, BP7, CPP) where the agent missed 50+ issues the user had to find manually. Every rule below exists because a real failure proved it necessary.**

## When to Activate

- When the user requests removal of a Line of Business from PolicyCenter.
- When the `gw-planner` agent needs to orchestrate LOB removal across multiple specialized agents.
- When planning the decommissioning of an LOB that is no longer needed in the project.

---

## Inputs

| Input | Description | Example |
|-------|-------------|---------|
| LOB Code | The short code identifying the Line of Business | `BP7`, `CU`, `UPL` |
| Project Root | The root path of the PolicyCenter project (auto-detected from cwd) | `C:\dev\policycenter` |

### Alternate Name Discovery (DO NOT ask an open-ended question)

The AI MUST NOT ask the user "what are the alternate names?" as a free-text question. Instead, follow this procedure:

1. **Auto-detect the project root** from the current working directory.
2. **Grep the codebase** for the LOB code to find related identifiers. Search:
   - Entity files (`.eti`, `.etx`) — look for entity names that start with the LOB prefix
   - Typelist files (`.tti`, `.ttx`) — look for typecodes mentioning the LOB
   - Product model directories — look for folder/file names containing the LOB
   - Gosu files — look for class names, constants, and packages containing the LOB
   - Display properties — look for key patterns containing the LOB
   - `InstalledPolicyLine` typelist — look for the LOB's line code
3. **Extract candidate alternate names/prefixes** from the grep results. For example, for LOB code `WCM`, grepping might find: `WCM`, `WC7`, `WC`, `WorkersComp`, `WCClassCode`, `WCMLocation`. Deduplicate and extract the distinct prefixes.
4. **Present the candidates as a numbered selection** using `AskUserQuestion` with `multiSelect: true`. Include:
   - Each discovered prefix/name as an option
   - The grep evidence (which file/pattern it came from) in the option description
   - Let the user select which ones are genuine LOB alternate names vs false positives
5. **Build the final grep pattern list** from the user's selections.

**Example interaction:**

The AI greps and finds these patterns for `CR7`:
```
I found these potential names/prefixes related to CR7 in the codebase:
  1. CR7 — found in 45 files (entity names, Gosu classes, PCFs)
  2. Crime — found in 12 files (CrimeCoverage, CrimeLine entity refs)
  3. CR — found in 200+ files (but many are false positives like CREATE, CRITERIA)
  4. CRLine — found in 3 files (product model line pattern)
```
Then uses AskUserQuestion multiSelect to let the user pick which are real LOB names.

**This ensures the user picks from real data — not guessing from memory, and the AI doesn't invent names from training data.**

---

## Iron Rules — Violations WILL Cause Compile/Runtime Failures

These rules are NON-NEGOTIABLE. Past LOB removals violated every one of them, causing 50+ errors the user had to find and fix manually.

### Rule 1: Consumer-First Deletion
NEVER delete a definition (constant, typecode, entity, display key, typelist, enhancement) without FIRST grepping the ENTIRE codebase for all consumers. Sequence:
1. Grep for the symbol across ALL directories (gsrc, config, gtest, integration)
2. List every consumer found
3. Remove every consumer first
4. THEN delete the definition
5. Grep again to verify zero references remain

**Why this exists:** This rule was violated on EVERY LOB removal. The same file (`UnderwriterEvaluatorTriggeringPoint_Ext.gs`) broke 3 times across 3 different LOBs. Constants were deleted while Gosu files still referenced them. Typecodes were removed while PCFs still used them.

### Rule 2: Start-Boundary Grep Only
Use `\bWCM` NOT `\bWCM\b`. The end boundary misses compound identifiers like `WCMLocation`, `WCMLargeDeductible`.

### Rule 3: Match Key Names, Not Entire Lines
When grepping display/properties files, match on the key name (before the `=`) ONLY. Auto-generated hash IDs can contain LOB abbreviations by coincidence. A false positive on a hash containing `bp7` deleted a valid Restaurant QuestionChoice ("Night Club") and crashed server startup.

### Rule 4: Sequential Agent Execution — No Parallel Edits to Shared Files
NEVER run definition-deleting agents in parallel with reference-updating agents. Agent A (update/remove references) completes fully BEFORE Agent B (delete definitions) starts. Parallel execution orphaned references on every LOB removal.

**Additionally:** NEVER let two agents edit the SAME file simultaneously. During CP7/CA7/GL7/WCM removal, a `display.properties` agent bulk-deleted all lines matching the LOB pattern while a separate Gosu agent renamed key references — each assuming the other hadn't touched the file. Similarly, `UnderwriterEvaluatorTriggeringPoint_Ext.gs` was edited by multiple LOB passes and the WCM agent missed 4 typecodes because earlier passes had already changed the file without the agent knowing.

**When a file has been edited by ANY prior agent or prior LOB pass, the next agent MUST re-read the file fresh before editing.** Do not assume a file is in a known state.

### Rule 5: Never Modify Platform-Owned Files
Platform files include: `gw/webservice/*` API Javadoc, `config/metadata/*`, base `.eti`/`.tti`/`.tix` files, `display_*.properties` translations (except main `display.properties` for customer keys), `typelist_*.properties` translations for base typecodes. 45 files were wrongly modified during past removals and had to be restored from git.

### Rule 6: Trace Subsystems, Not Individual Files
Individual file deletion missed 20+ files in WCM alone. Entire subsystems were missed: WC Dividends (20+ files), NCCI Integration (7+ files), Crime Models/Verisk (8 files + 1 template), EPLI Events & Systables. For each LOB, trace the full dependency chain (see Phase 2).

### Rule 7: Remove Dead References, Never Rename Them
When a display key reference points to a removed LOB, REMOVE the reference entirely. Never rename it to another key. Renaming to nonexistent keys caused compile errors in CA7 (`PolicyContactRolePanelSet.PolicyAddlInsured.pcf`) and GL7 (`PolicyPeriodValidation_Ext.gs`).

### Rule 8: Verify Syntax After Every Edit
When removing an if-guard, case branch, or constant, verify the surrounding syntax is still valid. Check for orphaned braces `{` `}`, dangling else, or empty switch blocks. Read the file after editing. Orphaned braces in `SpecialCasesClauseLoadGenerator.gs` caused a parse error during WCM removal.

### Rule 9: Validate XML After Bulk Block Removal
When removing XML blocks (systable entries, FormPattern blocks, CancelRefund entries), the agent can accidentally mangle adjacent entries — stripping `<` from tags, orphaning text content. During CR7 removal from AAIS, the agent stripped `<` from `<ExpirationDate/>` on an adjacent CA7 entry in `cancel_refund.xml`, turning it into bare text that crashed server startup with "SCHEMA ERRORS IN PLUGIN FILES — Cannot have any text content."
**After every bulk XML removal:** grep the file for orphaned text content (lines containing tag-like text without a `<` bracket). Validate the file is well-formed XML before declaring done.

### Rule 10: Run git diff --stat After All Agents Complete
Agents can accidentally empty or modify files they weren't supposed to touch. During CR7 removal from AAIS, the SurePath cleanup agent accidentally zeroed out two CA7 files (`CA7FormPatterns.1.NE.xml`, `CA7FormPatterns.2.SD.xml`), causing server startup failure.
**After all execution phases complete and BEFORE the verification sweep:** run `git diff --stat` and verify:
1. Only expected files were modified (no unexpected files in the diff)
2. No files have size 0 (zeroed out accidentally)
3. No non-LOB files were changed (e.g., CA7 files shouldn't change during CR7 removal)
If unexpected files appear, restore them with `git checkout -- <file>`.

---

## Mandatory Search Scope

EVERY LOB removal must search ALL of these paths. Past removals missed files because the search scope was too narrow — the user manually found remnants in 24+ file categories the agent never searched.

| Category | Paths to Search |
|----------|----------------|
| **Entities & Typelists** | `config/extensions/entity/` — `.eti`, `.etx`, `.eix` files; `config/extensions/typelist/` — `.tti`, `.ttx` files |
| **Product Model** | `config/resources/productmodel/`, `config/resources/ratebooks/`, `config/resources/systabledata/` |
| **Systable Registrations** | `config/resources/systables.xml`, `config/resources/systables.CUST.xml`, **any** `systables.*.xml` variant (e.g., `systables.BP7.xml`) |
| **Rules & Events** | `config/rules/**/` — `.gr` files AND their parent `order.txt` entries |
| **Plugin Registry** | `config/plugin/registry/**/*.gwp` |
| **Messaging** | `config/messaging/messaging-config.xml` |
| **Scheduler** | `config/scheduler/scheduler-config.xml` |
| **Display Properties** | `config/locale/display.properties`, `config/locale/display_en_US.properties`, `config/locale/display_yy.properties` |
| **Schema Display** | `config/locale/schema.display.properties`, `config/locale/schema.display_en_US_EDG.properties`, `config/locale/schema.display_en_US_EDG_PH.properties` |
| **Typelist Properties** | `config/locale/typelist.properties`, `config/locale/typelist_en_US.properties`, `config/locale/typelist_yy.properties`, `config/locale/typelist_es.properties`, `config/locale/typelist_es_ES.properties` — **ALL locale variants** |
| **Product Model Display** | `config/locale/productmodel.display.properties` |
| **Smoketests** | `config/smoketests/typelists.properties`, `config/smoketests/**` |
| **State Sets** | `config/statesets/StateSets.xml`, `config/statesets/**` |
| **Resource Context** | `config/resources/ResourceContextMap.xml` |
| **Webservice** | `config/integration/`, `config/web/`, `*.wsdl`, `*.wsc`, `*.xsd` |
| **REST API Schemas** | `integration/**/*.schema.json`, `config/integration/**` |
| **APD Config** | `config/apd/`, `config/pca_config/` |
| **OSGI** | `config/osgi/` |
| **Import** | `config/import/`, `config/import/bizrules/` |
| **Content** | `config/content/`, `config/content/submissionintake/` |
| **Display Name Files** | `config/extensions/displayname/` and `config/displaynames/` — `.en`, `.es`, and all locale variants |
| **Gosu Source** | `gsrc/**/*.gs`, `gsrc/**/*.gsx`, `gsrc/**/*.gst` (templates — runtime crash risk!) |
| **Gosu Tests** | `gtest/**/*.gs`, `gtest/**/*.gsx` |
| **Mock/Sample Data** | `**/mock/**`, `**/sample*/**` |
| **BizRules** | `config/bizrules/`, `config/gwrules/`, `config/import/bizrules/` |
| **Build Artifacts** | `build/idea/classes/updates/adopted/` — SBT zip files |
| **Config XML** | `config/xml/config.xml` — LOB-specific parameters |
| **Ratebooks** | `config/content/cust-ratebooks/`, `config/content/iso-ratebooks/` |
| **API Enablement** | `config/integration/apis/installedlobs/` |

---

## Known Fragile Files

These files aggregate content from multiple LOBs and break easily. Handle with special care:

| File | Why It's Fragile | Required Action |
|------|-----------------|-----------------|
| `UnderwriterEvaluatorTriggeringPoint_Ext.gs` | Aggregates typecodes from ALL LOBs in one `addAll` block. One bad typecode causes Gosu to type the entire array as `ArrayList<ErrorType>` — cascading errors on ALL entries. Broken 3 times (WCM, CU, BP7). | Read fresh before EVERY LOB removal. After editing, verify EVERY remaining typecode exists in `RuleContextDefinitionKey.ttx`. |
| `EntityMetadataUtil.gs` | References constants from multiple LOBs. | After removing any constant, grep this file specifically. |
| `CommonConstants_Ext.gs` | Central constant repository — LOB-specific mixed with shared. | Remove only constants confirmed unused after consumer removal. |
| `display.properties` | Thousands of keys, LOB-specific mixed with shared. | Match on key name prefix before `=` sign. Only remove keys clearly LOB-specific. |
| `productmodel.display.properties` | Can contain 1,000+ keys per LOB (BP7 had 1,310, GL7 had 839). | Sweep with start-boundary grep. These bulk keys are commonly missed. |
| REST API schema files (`*.schema.json`) | May reference LOB-specific typelists or properties. | Grep schema files for LOB types — `CUPolicyType` was missed in `policyperiod_ext-1.0.schema.json`. |
| `VeriskPrometrixDocument_Ext.gst` (and other `.gst` files) | Templates reference entity properties at render time. Don't cause compile errors — crash at RUNTIME. | Grep `.gst` files for LOB entity properties. Crime section was 147 lines of dead code. |

---

## False Positive Handling

Short LOB prefixes generate false positives. Handle explicitly:

| LOB Prefix | Known False Positives | How to Filter |
|------------|----------------------|---------------|
| CP / CPP | `CPPolicy`, `CPPolicyBuildingIterative`, `CPClassCode` — platform Commercial Property types | Verify each match: is it CP7/CPP LOB code or platform CP? |
| CU | `CUSTOM`, `CURRENT`, `CURSOR`, `CUSTRenewalProcessImpl` | Use `\bCU[^a-z]` or grep specific identifiers (`CULine`, `CUPolicyType`) |
| GL | `GLOBAL`, many platform terms start with GL | Use `GL7` or `\bGL7` as primary pattern |
| WC | `WC7` exists in platform typelists | Verify platform vs customer origin for each hit |
| CR | `CREATE`, `CREDENTIAL`, `CRITERIA` | Use `CR7` or LOB-specific identifiers (`CRLine`, `CrimeCoverage`) |
| BP | `BPProcess`, other platform terms | Use `BP7` or `\bBP7` as primary pattern |

---

## Workflow

### Step 0: Load Resources, Discover Names, and Validate Prerequisites

1. **Load the plan template** from `resources/lob-removal-plan-template.md`.
2. **Load lessons learned** from `resources/lob-removal-lessons.md`.
3. **Accept the LOB code** from the user (passed as argument or asked via single question).
4. **Auto-detect the project root** from the current working directory (look for `modules/configuration/` or `gwb.bat`).
5. **Verify agent definitions exist.** Check that `.claude/gw-liftshift-agent/agents/` (or `.claude/agents/`) contains these files:
   - `gw-gosu-agent.md`
   - `gw-pcf-agent.md`
   - `gw-entity-agent.md`
   - `gw-typelist-agent.md`
   - `gw-build-agent.md`
   - `gw-planner-agent.md`
   
   If missing, WARN the user: "Agent definitions not found — subagent delegation will not work. Clone the gw-liftshift-agent repo into the project's `.claude/` directory, or run without delegation (single agent mode)."
6. **Run the Alternate Name Discovery procedure** (see Inputs section above):
   a. Grep the codebase for the LOB code across entity files, typelists, product model, Gosu, display properties, and InstalledPolicyLine.
   b. Extract candidate alternate names/prefixes from grep results.
   c. Present candidates as a multi-select question using `AskUserQuestion` — the user picks which are real LOB names.
7. **Build the final grep pattern list** from the LOB code + user-confirmed alternates.
8. **Generate the removal plan** by substituting `[lob_code]` placeholders with the actual LOB code.
9. **Save the plan** at `.pwc/agent/plans/lob-removal-[lob_code].md`.
10. **Present the plan** to the user and ask for approval before any execution begins.

### Step 1: Execute Phases Sequentially

Execute the phases defined in the plan template. At each phase boundary:
- Verify exit criteria are met
- Log all actions to the work log
- Get user confirmation before proceeding

### Step 2: Mandatory Verification Sweep (NEW — This Was the #1 Gap)

After ALL deletion/modification phases complete, BEFORE declaring the LOB removal done:

1. Run a **full codebase grep** with start-boundary patterns for EVERY LOB prefix (primary code AND all alternates) across ALL paths in the Mandatory Search Scope table.
2. **Verify ZERO hits** in every file category. Report ALL remaining hits to the user with file path, line number, and match context. Do NOT silently skip any hit.
3. **Check for entire LOB files still on disk** — entity files, test files, template files. `WCClassAdjustment_Ext.eti` was found still on disk after WCM removal was declared "complete."
4. **Check `UnderwriterEvaluatorTriggeringPoint_Ext.gs`** — verify all remaining typecodes exist in `RuleContextDefinitionKey.ttx`.
5. **Check `productmodel.display.properties`** specifically — can contain 1,000+ orphaned keys per LOB.
6. **Check ALL locale variant properties files** — `en_US`, `yy`, `es`, `es_ES`, `EDG`, `EDG_PH` variants were ALL missed in past removals.
7. **Check `config/smoketests/`** — this directory was missed in every past removal.
8. **Check REST API schema files** — `*.schema.json` under `integration/`.

Any remaining hits are cleaned up. Then re-run the sweep. Only when the sweep returns ZERO customer-owned hits is the verification phase complete.

### Step 3: Compile and Server Gates

1. **Delete H2 database** — `tmp/pc.mv.db` and `tmp/pc.lock.db`.
2. **Run `gwb clean`**
3. **Run `gwb codegen`** — must succeed with zero errors.
4. **Run `gwb compile`** — must succeed with zero errors. If errors found:
   - Consumer referencing deleted symbol → return to consumer removal
   - Syntax error from incomplete edit → fix orphaned syntax
   - Platform file error → restore from git
5. **Start the server** — must reach MULTIUSER run level. If startup errors:
   - `FileNotFoundException` → check systable registration files (systables.xml, systables.CUST.xml, all variants)
   - `ClassNotFoundException` → check rule `order.txt` entries
   - `Invalid typelist` → check API schema files
   - H2 errors → delete H2 and restart
6. **Run final grep sweep** — fixes can introduce new orphans.
7. **Only declare LOB removal complete** when: compile is clean, server starts, AND final sweep shows zero LOB references in customer-owned files.

---

## Plan Generation Rules

When generating the plan from the template:

1. Replace all `[lob_code]` placeholders with the actual LOB code (preserving case as used in the template context).
2. Include all phases from the template in sequential order.
3. Preserve the exit criteria for each phase — these are checkpoints that must be verified before proceeding.
4. Identify which specialized agent handles each phase (see Agent Delegation Map).
5. Each phase's task prompt to the subagent must include:
   - The LOB code and confirmed alternate names/prefixes.
   - The specific files or directories to work on (from the discovery phase).
   - Exit criteria that must be met.
   - Do NOT repeat Iron Rules or LOB Removal Protocol — the agent `.md` system prompt already has them.
6. Log all actions to `.pwc/agent/work-logs` following the format defined in `resources/log-format-spec.md`. Every action must be tagged with a category and outcome. The fallout summary section must be built incrementally.
7. Before troubleshooting any issues, check `.pwc/agent/lessons` AND `resources/lob-removal-lessons.md` for known solutions.
8. LOB code matching is case insensitive, but grep patterns should cover both cases.
9. When dispatching subagents, identify shared files (display.properties, CommonConstants_Ext.gs, UnderwriterEvaluatorTriggeringPoint_Ext.gs) and ensure only ONE agent touches each shared file at a time. Tell each agent which files are off-limits.
10. After each subagent completes, verify its work before dispatching the next phase — do not trust self-reporting.

---

## Agent Delegation Map

### How Agent Delegation Works

When you call `Agent(subagent_type: "gw-gosu-agent", prompt: "...")`, Claude Code:
1. Finds the `.md` file whose `name:` frontmatter matches `gw-gosu-agent` (discovered recursively under `.claude/`)
2. Loads the `.md` body (everything after the YAML `---` block) as the subagent's **system prompt**
3. Applies the `tools:` and `model:` from the frontmatter
4. Delivers your `prompt` as the first user message

**This means each subagent already has its LOB Removal Protocol rules, delegation boundaries, and domain knowledge loaded.** Do NOT repeat the Iron Rules or LOB removal procedures in the task prompt — the agent `.md` already contains them. Task prompts should be concise: LOB code, phase number, specific files/directories to work on, and exit criteria.

**Example — good task prompt:**
```
Phase 5: Remove CR7 references from shared Gosu files.
LOB code: CR7. Alternate names: Crime.
Project root: C:\IS_APPS\MERGED-PC\PC\modules\configuration
Files to refactor: [list from discovery phase]
Exit criteria: zero CR7/Crime references in shared Gosu files, no orphaned syntax.
```

**Example — bad task prompt (redundant):**
```
Phase 5: Remove CR7 references. Remember to grep for consumers before deleting.
Use start-boundary grep only. Never rename dead references. Verify syntax after edits.
Check UnderwriterEvaluatorTriggeringPoint_Ext.gs...
[repeating everything already in the agent's system prompt]
```

### Phase-to-Agent Assignment

| Phase | Primary Agent | Notes |
|-------|--------------|-------|
| 1. Establish Baseline | gw-planner | Runs `pc-current-state` skill, coordinates build verification |
| 2. Discovery & Subsystem Tracing | gw-planner + all agents | Each agent searches its domain for LOB references |
| 3. Remove LOB PCF Files | gw-pcf-agent | Runs `pcf-find-usages` first, deletes LOB folder/files, cleans broken references |
| 4. Remove Gosu Files | gw-gosu-agent | Deletes LOB Gosu source folders and files |
| 5. Refactor Shared Gosu Files | gw-gosu-agent | Removes LOB references from shared files. Consumer-first: grep before every deletion |
| 6. BizRules Bootstrap Updates | gw-entity-agent | Removes gwrules files and entity references |
| 7. Update Configuration Files | gw-planner | Coordinates config cleanup — ALL locale variants, ALL properties files |
| 8. Remove Display Properties | gw-planner | Sweeps ALL properties files including locale variants, schema display, productmodel display |
| 9. Ratebook Removal | gw-planner | Deletes ratebook folders and SBT zip artifacts |
| 10. Cleanup API Enablement Config | gw-planner | Removes API YAML files, REST schema references, runs codegen |
| 11. Remove Entity Extensions | gw-entity-agent | Removes entity extension files, runs `entity-find-usages` first |
| 12. Cleanup Typelists | gw-typelist-agent | Removes typelist entries and files, runs `typelist-find-usages` first |
| 13. Remove Templates & Test Files | gw-gosu-agent | Removes `.gst` templates, gtest files, mock data, sample data |
| 14. Handle Fragile Files | gw-gosu-agent | Reads and verifies `UnderwriterEvaluatorTriggeringPoint_Ext.gs`, `EntityMetadataUtil.gs`, `CommonConstants_Ext.gs` |
| 15. Exhaustive Verification Sweep | gw-planner | Full codebase grep across ALL mandatory search paths. ZERO hits required. |
| 16. Milestone Check | gw-gosu-agent, gw-pcf-agent | Compile errors resolved, codegen clean |
| 17. Server Startup Verification | gw-build-agent | Server starts to MULTIUSER, startup errors resolved |
| 18. GUnit Test Updates | gw-gosu-agent | Fixes broken unit tests |
| 19. Final Verification Sweep | gw-planner | Post-fix grep sweep — fixes can introduce new orphans |

---

## Output Format

The generated plan must follow this structure:

```markdown
# LOB Removal Plan: [LOB Code] — [LOB Name]

> Generated: {{timestamp}}
> LOB Code: {{lob_code}}
> Alternate Names/Prefixes: {{alternate_names}}
> Project Root: {{project_root}}

## Overview

Removal of the [LOB Name] ([LOB Code]) Line of Business from the PolicyCenter project.
This plan follows the phased approach with mandatory verification sweeps to ensure
ZERO LOB remnants remain in customer-owned files.

## Pre-Conditions
- PolicyCenter project compiles successfully.
- The APD / Iapd Service Plugin is disabled.
- The `.pwc/agent/work-logs` folder exists.
- All alternate names/prefixes for the LOB have been confirmed.

## Phase 1: Establish the Baseline
...

## Phase 2: Discovery & Subsystem Tracing
...

[Remaining phases from template]

## Phase 15: Exhaustive Verification Sweep
...

## Phase 19: Final Verification Sweep
...

## Success Criteria
- All phases completed with exit criteria met.
- `gwb codegen` completes successfully.
- `gwb compile` completes successfully.
- Server starts to MULTIUSER run level.
- Final verification sweep returns ZERO LOB references in customer-owned files.
- All GUnit tests pass.
```

---

## Behavioral Rules

1. **Never execute removal tasks without user approval.** This skill generates the plan — execution requires explicit approval at each phase boundary.
2. **Always confirm the LOB code, ALL alternate names, AND all related prefixes** before generating the plan.
3. **Preserve the sequential ordering** of phases. Later phases depend on earlier phases completing successfully.
4. **Exit criteria are mandatory checkpoints.** No phase proceeds until its exit criteria are verified and the user confirms.
5. **Log everything.** Every file removed, added, or modified must be recorded with category and outcome.
6. **Check lessons learned first.** Before troubleshooting, consult `.pwc/agent/lessons` AND `resources/lob-removal-lessons.md`.
7. **User confirmation model:** Once the user approves the plan and says "go", execute ALL phases continuously without stopping to ask at each boundary. Only stop to ask the user when: (a) an unexpected error occurs, (b) a decision is needed that the plan doesn't cover, or (c) the user explicitly asked for phase-by-phase approval. Report progress as you go but keep moving.
8. **Consumer-first deletion is non-negotiable.** Every agent must grep for consumers before deleting any definition. No exceptions.
9. **The exhaustive verification sweep is mandatory.** It cannot be skipped, shortened, or declared "probably fine." Every path in the Mandatory Search Scope must be searched.
10. **Never trust agent self-reporting.** The agent declaring a phase "complete" does not mean it is complete. The verification sweep is the source of truth.
11. **When in doubt, flag for the user.** If a grep hit is ambiguous (could be LOB-related or platform), show it to the user rather than silently skipping it.
12. **Re-read fragile files fresh before every edit.** Do not assume prior LOB removal passes left them correct.
