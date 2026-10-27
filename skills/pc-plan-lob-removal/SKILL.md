---
name: pc-plan-lob-removal
description: Plans and runs the removal of a Line of Business (LOB) from a Guidewire PolicyCenter project -- discovers alternate LOB names, generates a phased plan from the template, and after user approval dispatches gw-gosu-agent, gw-pcf-agent, gw-entity-agent, gw-typelist-agent and gw-build-agent one phase at a time with verification gates. Runs in the main session because subagents cannot dispatch other agents. Use only when the user explicitly asks to remove, or plan the removal of, a specific LOB.
---

# Skill: pc-plan-lob-removal

## Purpose

Generate and execute a comprehensive plan for removing a Line of Business (LOB) from an existing Guidewire PolicyCenter project. This skill runs in the **main session**: it produces a structured, phased removal plan, then orchestrates execution by dispatching the specialized agents with the `Agent` tool, with mandatory verification at every phase boundary. It must not be run from inside a subagent (including `gw-planner`) — subagents cannot start other agents.

**This skill was refined from 8 real LOB removals (CP7, CA7, WCM, GL7, CR7, CU, BP7, CPP) where the agent missed 50+ issues the user had to find manually. Every rule below exists because a real failure proved it necessary.**

## When to Activate

- When the user requests removal of a Line of Business from PolicyCenter.
- When LOB removal must be orchestrated across multiple specialized agents (the main session runs this skill; `gw-planner` may be asked to review the generated plan).
- When planning the decommissioning of an LOB that is no longer needed in the project.

---

## Inputs

| Input | Description | Example |
|-------|-------------|---------|
| LOB Code | The short code identifying the Line of Business | `BP7`, `CU`, `UPL` |
| Project Root | The root path of the PolicyCenter project (auto-detected from cwd) | `C:\dev\policycenter` |
| Config Root (`<config_root>`) | The module folder that contains `config/`, `gsrc/` and `gtest/` (auto-detected; normally `modules/configuration`). Every path in the plan is written relative to it. | `modules/configuration` |

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

These rules are NON-NEGOTIABLE. The full text, with the failure each one came from, is in [references/hard-prohibitions.md](references/hard-prohibitions.md). **Load it in Step 0 and re-read it before dispatching any agent.** In short:

1. **Consumer-first deletion.** Grep the whole codebase for consumers, remove them, then delete the definition, then grep again.
2. **Start-boundary grep only.** `\b<code>`, never `\b<code>\b`.
3. **Match key names, not whole lines.** Hash IDs contain LOB letters by coincidence.
4. **Sequential agents, never two on one file.** Re-read any file a prior agent or pass touched.
5. **Never modify platform-owned files.**
6. **Trace subsystems, not individual files.**
7. **Remove dead references; never rename them.**
8. **Verify syntax after every edit.**
9. **Validate XML after any bulk block removal.**
10. **Run `git diff --stat` after all agents finish.**
11. **Bulk edits only under the guarded procedure** (line-oriented files, dry run, control count, checks right after the edit).

---

## Mandatory Search Scope

EVERY LOB removal must search ALL of these paths. Past removals missed files because the search scope was too narrow — the user manually found remnants in 24+ file categories the agent never searched.

All paths in the table are relative to `<config_root>`. Check each one against it during discovery and list the ones that do not exist in the context file.

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

These files aggregate content from multiple LOBs and break easily. Handle with special care.

The file names below come from the project the kit was refined on. Treat them as examples of the shape to look for (a file that lists or switches over every LOB's constants, typecodes or keys): confirm each exists in your project, and use the Phase 2 inventory to find the equivalents.

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

## Approval Modes

The user chooses **one** approval mode at the start (Step 0, item 10). It decides when the run waits for the user. It never changes what is checked: every phase's exit criteria are verified and logged in every mode.

| Mode | The run waits for the user… | Use it for |
|---|---|---|
| **Checkpoints** (default) | (1) after Phase 2, to approve the plan and the discovery inventory; (2) before Phase 11, the first phase that deletes entity and typelist definitions; (3) before Phase 16, the full compile; (4) after Phase 19, for sign-off | Normal runs |
| **Every phase** | at every phase boundary | The first run on a new repo, or when training someone |
| **Continuous** | after Phase 2 only | Re-running on a repo you already know |

Phases 1 and 2 only read the project (Phase 1 also builds it), so in every mode the plan is approved after Phase 2, with the inventory in hand. **No project file is edited or deleted before that approval.**

**Stops no mode can skip.** Stop and ask the user when:
- an unexpected error occurs, or a build or server failure does not match the startup-error table;
- a grep hit cannot be classified as LOB-owned or platform/shared;
- a whole shared file would be deleted;
- `git diff --stat` shows an unexpected file or a zero-size file (Iron Rule 10);
- a decision is needed that the plan does not cover.

Record the chosen mode in the plan header and in the context file. Changing the mode mid-run is allowed only at a stop, and is logged.

---

## Workflow

### Step 0: Load Resources, Discover Names, and Validate Prerequisites

1. **Load the plan template** from `references/lob-removal-plan-template.md`.
2. **Load lessons learned** from `references/lob-removal-lessons.md` **and the full Iron Rules** from `references/hard-prohibitions.md`.
3. **Accept the LOB code** from the user (passed as argument or asked via single question).
4. **Auto-detect the project root** from the current working directory (look for `modules/configuration/` or `gwb.bat`), then **resolve `<config_root>`**: the module folder that contains `config/`, `gsrc/` and `gtest/` (normally `modules/configuration`). Use it for every path in the plan; never assume a fixed prefix.
5. **Verify agent definitions exist.** Check that `.claude/agents/` (the only project location Claude Code loads agents from) contains these files:
   - `gw-gosu-agent.md`
   - `gw-pcf-agent.md`
   - `gw-entity-agent.md`
   - `gw-typelist-agent.md`
   - `gw-build-agent.md`
   - `gw-planner-agent.md`
   
   If missing, WARN the user: "Agent definitions not found — subagent delegation will not work. Install the kit as the project's `.claude/` directory (see the Installation section of the kit's README), or run without delegation (single agent mode)."
6. **Run the Alternate Name Discovery procedure** (see Inputs section above):
   a. Grep the codebase for the LOB code across entity files, typelists, product model, Gosu, display properties, and InstalledPolicyLine.
   b. Extract candidate alternate names/prefixes from grep results.
   c. Present candidates as a multi-select question using `AskUserQuestion` — the user picks which are real LOB names.
7. **Build the final grep pattern list** from the LOB code + user-confirmed alternates.
8. **Generate the removal plan** by substituting `[lob_code]` placeholders with the actual LOB code.
9. **Save the plan** at `.pwc/agent/plans/lob-removal-[lob_code].md` and **create the context file** `.pwc/agent/plans/lob-removal-[lob_code]-context.md` (see The Context File).
10. **Present the plan** and ask the user to choose the approval mode (see Approval Modes) with `AskUserQuestion`. Then run Phases 1 and 2, which only read the project. **The plan is approved after Phase 2**, once the inventory is on the table. No project file is edited or deleted before that approval.

### The Context File

Discovery results are written down, not left in the conversation, so every phase prompt and any resumed session starts from the same facts. Create `.pwc/agent/plans/lob-removal-[lob_code]-context.md` at the end of Step 0 and complete it in Phase 2:

| Section | Contents |
|---|---|
| Config root | The resolved `<config_root>`, and the paths from the Mandatory Search Scope that do not exist in this project |
| Names | The LOB code, the confirmed alternate names, and every candidate the user rejected, with the reason |
| Kept lines | Other LOBs and shared code that must survive this removal, with a control pattern for each kept LOB (its code) that must read non-zero in every sweep |
| Approval mode | The chosen mode and its stop points |
| Inventory | The Phase 2 inventory grouped by subsystem: the files and folders each subsystem owns |
| Progress | The last completed phase and its date, updated at every phase boundary |

Every agent task prompt carries the path to this file. Agents read it for the config root, the confirmed names and their part of the inventory instead of rediscovering them. **When a context file for this LOB already exists at the start of Step 0, read it, tell the user the last completed phase, and resume from there instead of re-running discovery.**

### Step 1: Execute Phases Sequentially

Execute the phases defined in the plan template. At each phase boundary:
- Verify exit criteria are met
- Log all actions to the work log
- Update the Progress section of the context file
- Wait for the user only where the approval mode says to (see Approval Modes); otherwise continue to the next phase

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

**Every zero needs a control.** A grep that finds nothing proves nothing until the same command has found something in the same run: a wrong path, a missing `modules/` prefix or a mistyped flag all print "no matches". Before reading any zero as clean, run the identical command and path set for a **kept** LOB (its control pattern is in the context file's Kept lines) and confirm it is **non-zero**. If the control reads zero, the scan is broken, not the repo clean: fix the scan and rerun the whole sweep. Report every zero together with its control count. If no LOB is being kept, use a string you know is present in the same files, such as a platform typelist name.

Then answer every question in [references/known-answer-checklist.md](references/known-answer-checklist.md). Each must be YES; a NO is a finding.

Any remaining hits are cleaned up. Then re-run the sweep. Only when the sweep returns ZERO customer-owned hits is the verification phase complete.

### Step 3: Compile and Server Gates

1. **Delete the H2 database** — `<config_root>/tmp/pc.mv.db` and `<config_root>/tmp/pc.lock.db`. The server opens the file named by `jdbc-url` in `<config_root>/config/database-config.xml`, so confirm that path first. Deleting a same-named file in another `tmp/` folder leaves the server's database in place, and the same error comes back.
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
6. **Run final grep sweep** — fixes can introduce new orphans. Include its control and the known-answer checklist.
7. **Only declare LOB removal complete** when: compile is clean, server starts, AND final sweep shows zero LOB references in customer-owned files.

### Step 4: Evaluate the Run (optional, separate session)

To grade a finished removal from outside, use [references/evaluation.md](references/evaluation.md) and `scripts/eval-census.sh`. The baseline census is the one step that is hard to recover later, so offer it in Phase 1, before any edit. The result census and the comparison run in a fresh session that does not reuse this run's name list.

To test the kit itself without a PolicyCenter install, run it on the fixture project described in [evals/README.md](evals/README.md): a fake project with a made-up LOB, traps, and a scorer.

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
   - The path to the context file (agents read it for the config root, confirmed names and inventory).
   - Do NOT repeat Iron Rules or LOB Removal Protocol — the agent `.md` system prompt already has them.
6. Log all actions to `.pwc/agent/work-logs` following the format defined in `references/log-format-spec.md`. Every action must be tagged with a category and outcome. The fallout summary section must be built incrementally.
7. Before troubleshooting any issues, check `.pwc/agent/lessons` AND `references/lob-removal-lessons.md` for known solutions.
8. LOB code matching is case insensitive, but grep patterns should cover both cases.
9. When dispatching subagents, identify shared files (display.properties, CommonConstants_Ext.gs, UnderwriterEvaluatorTriggeringPoint_Ext.gs) and ensure only ONE agent touches each shared file at a time. Tell each agent which files are off-limits.
10. After each subagent completes, verify its work before dispatching the next phase — do not trust self-reporting.

---

## Agent Delegation Map

### How Agent Delegation Works

When you call `Agent(subagent_type: "gw-gosu-agent", prompt: "...")`, Claude Code:
1. Finds the `.md` file in `.claude/agents/` whose `name:` frontmatter matches `gw-gosu-agent`
2. Loads the `.md` body (everything after the YAML `---` block) as the subagent's **system prompt**
3. Applies the `tools:` and `model:` from the frontmatter
4. Delivers your `prompt` as the first user message

The agent cannot start other agents. When its work needs another agent, it ends its reply with a **Handoff** block (target agent, files, change needed). Dispatch each Handoff yourself, sequentially, respecting Rule 4 (no parallel edits to shared files).

Every agent ends its reply with a status word. Use it to route, then verify the work yourself (Behavioral Rule 10): `DONE` → verify, then continue; `NEEDS-GOSU` / `NEEDS-PCF` / `NEEDS-ENTITY` / `NEEDS-TYPELIST` / `NEEDS-BUILD` → dispatch that agent with the Handoff block; `BLOCKED` → stop and ask the user; `NOT-FOUND` (an expected artifact does not exist) and `AMBIGUOUS` (cannot classify as LOB-owned or platform) → stop and ask the user, never guess.

**This means each subagent already has its LOB Removal Protocol rules, delegation boundaries, and domain knowledge loaded.** Do NOT repeat the Iron Rules or LOB removal procedures in the task prompt — the agent `.md` already contains them. Task prompts should be concise: LOB code, phase number, specific files/directories to work on, and exit criteria.

**Example — good task prompt:**
```
Phase 5: Remove CR7 references from shared Gosu files.
LOB code: CR7. Alternate names: Crime.
Config root: <config_root>
Context file: .pwc/agent/plans/lob-removal-CR7-context.md
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
| 1. Establish Baseline | main session | Runs `pc-current-state` skill, coordinates build verification |
| 2. Discovery & Subsystem Tracing | main session + all agents | Each agent searches its domain for LOB references |
| 3. Remove LOB PCF Files | gw-pcf-agent | Runs `pcf-find-usages` first, deletes LOB folder/files, cleans broken references |
| 4. Remove Gosu Files | gw-gosu-agent | Deletes LOB Gosu source folders and files |
| 5. Refactor Shared Gosu Files | gw-gosu-agent | Removes LOB references from shared files. Consumer-first: grep before every deletion |
| 6. BizRules Bootstrap Updates | gw-entity-agent | Removes gwrules files and entity references |
| 7. Update Configuration Files | main session | Coordinates config cleanup — ALL locale variants, ALL properties files |
| 8. Remove Display Properties | main session | Sweeps ALL properties files including locale variants, schema display, productmodel display |
| 9. Ratebook Removal | main session | Deletes ratebook folders and SBT zip artifacts |
| 10. Cleanup API Enablement Config | main session | Removes API YAML files, REST schema references, runs static checks (codegen runs after Phases 11 and 12) |
| 11. Remove Entity Extensions | gw-entity-agent | Removes entity extension files, runs `entity-find-usages` first |
| 12. Cleanup Typelists | gw-typelist-agent | Removes typelist entries and files, runs `typelist-find-usages` first |
| 13. Remove Templates & Test Files | gw-gosu-agent | Removes `.gst` templates, gtest files, mock data, sample data |
| 14. Handle Fragile Files | gw-gosu-agent | Reads and verifies `UnderwriterEvaluatorTriggeringPoint_Ext.gs`, `EntityMetadataUtil.gs`, `CommonConstants_Ext.gs` |
| 15. Exhaustive Verification Sweep | main session | Full codebase grep across ALL mandatory search paths. ZERO hits required. |
| 16. Milestone Check | gw-gosu-agent, gw-pcf-agent | Compile errors resolved, codegen clean |
| 17. Server Startup Verification | gw-build-agent | Server starts to MULTIUSER, startup errors resolved |
| 18. GUnit Test Updates | gw-gosu-agent | Fixes broken unit tests |
| 19. Final Verification Sweep | main session | Post-fix grep sweep — fixes can introduce new orphans |

---

## Output Format

The generated plan must follow this structure:

```markdown
# LOB Removal Plan: [LOB Code] — [LOB Name]

> Generated: {{timestamp}}
> LOB Code: {{lob_code}}
> Alternate Names/Prefixes: {{alternate_names}}
> Project Root: {{project_root}}
> Config Root: {{config_root}}
> Approval Mode: {{approval_mode}}

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

1. **Never edit or delete project files before the plan is approved.** Phases 1–2 only read the project (and build it); the user approves the plan and the inventory after Phase 2. After that, the approval mode decides where the run waits (see Approval Modes).
2. **Always confirm the LOB code, ALL alternate names, AND all related prefixes** before generating the plan.
3. **Preserve the sequential ordering** of phases. Later phases depend on earlier phases completing successfully.
4. **Exit criteria are mandatory checkpoints.** No phase proceeds until its exit criteria are verified and logged; where the approval mode says so, the user also confirms.
5. **Log everything.** Every file removed, added, or modified must be recorded with category and outcome.
6. **Check lessons learned first.** Before troubleshooting, consult `.pwc/agent/lessons` AND `references/lob-removal-lessons.md`.
7. **User confirmation model:** follow the approval mode chosen at the start (see Approval Modes). In every mode, stop for the stops that no mode can skip. Report progress as you go; between stops, keep moving.
8. **Consumer-first deletion is non-negotiable.** Every agent must grep for consumers before deleting any definition. No exceptions.
9. **The exhaustive verification sweep is mandatory.** It cannot be skipped, shortened, or declared "probably fine." Every path in the Mandatory Search Scope must be searched.
10. **Never trust agent self-reporting.** The agent declaring a phase "complete" does not mean it is complete. The verification sweep is the source of truth.
11. **When in doubt, flag for the user.** If a grep hit is ambiguous (could be LOB-related or platform), show it to the user rather than silently skipping it.
12. **Re-read fragile files fresh before every edit.** Do not assume prior LOB removal passes left them correct.
