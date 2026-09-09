# Skill: pc-plan-lob-removal

## Purpose

Generate a comprehensive plan for removing a Line of Business (LOB) from an existing Guidewire PolicyCenter project. This skill is invoked by the `gw-planner` agent to produce a structured, phased removal plan based on the LOB removal workflow template.

## When to Activate

- When the user requests removal of a Line of Business from PolicyCenter.
- When the `gw-planner` agent needs to orchestrate LOB removal across multiple specialized agents.
- When planning the decommissioning of an LOB that is no longer needed in the project.

---

## Inputs

Before generating the plan, collect the following from the user:

| Input | Description | Example |
|-------|-------------|---------|
| LOB Code | The short code identifying the Line of Business | `BP7`, `CU`, `UPL` |
| Alternate Names | Any alternate names or long-form names for the LOB | `Business Owners Policy`, `Customer Umbrella` |
| Project Root | The root path of the PolicyCenter project | `C:\dev\policycenter` |

---

## Workflow

1. **Load the plan template** from `resources/lob-removal-plan-template.md`.
2. **Ask the user** which LOB code will be removed. Follow up to confirm any alternate names (e.g., for LOB code "CU" the alternate name might be "Customer Umbrella").
3. **Generate the removal plan** by substituting the `[lob_code]` placeholder in the template with the actual LOB code provided by the user.
4. **Save the plan** as a markdown file for user review at `.pwc/agent/plans/lob-removal-[lob_code].md`.
5. **Present the plan** to the user and ask for approval before any execution begins.

---

## Plan Generation Rules

When generating the plan from the template:

1. Replace all `[lob_code]` placeholders with the actual LOB code (preserving case as used in the template context).
2. Include all phases from the template in sequential order.
3. Preserve the exit criteria for each phase — these are checkpoints that must be verified before proceeding.
4. Identify which specialized agents are responsible for each phase:
   - **gw-planner** — Orchestrates the overall workflow and user interactions.
   - **gw-gosu-agent** — Handles Gosu file refactoring and compile error resolution.
   - **gw-entity-agent** — Handles entity file modifications (`.eti`, `.etx`, `.eix`).
   - **gw-typelist-agent** — Handles typelist modifications (`.ttx`).
   - **gw-pcf-agent** — Handles PCF file operations.
5. Each phase must include:
   - A clear description of intent.
   - The specific tasks to execute.
   - Exit criteria that must be met before proceeding.
   - The responsible agent for each task.
6. Log all actions to `.pwc/agent/work-logs` with timestamps.
7. Before troubleshooting any issues, check `.pwc/agent/lessons` for known solutions.
8. Before any PCF deletion phase, instruct `gw-pcf-agent` to run the `pcf-find-usages` skill against each PCF file in the target folder. The resulting reference map drives cleanup sub-tasks in the same phase — broken references should be resolved before running `gwb codegen`, not deferred to the Milestone Check.

---

## Agent Delegation Map

| Phase | Primary Agent | Notes |
|-------|--------------|-------|
| 1. Establish Baseline | gw-planner | Runs `pc-current-state` skill, coordinates build verification |
| 2. Remove LOB PCF Files | gw-pcf-agent | Runs `pcf-find-usages` to map references, deletes LOB folder/files, cleans broken references in base PCFs |
| 3. Remove Gosu Files | gw-gosu-agent | Deletes Gosu source folders and files |
| 4. Refactor Gosu Files | gw-gosu-agent | Edits Gosu files to remove LOB references |
| 5. BizRules Bootstrap Updates | gw-entity-agent | Removes gwrules files and entity references |
| 6. Update Configuration Files | gw-planner | Coordinates config cleanup across multiple file types |
| 7. Ratebook Removal | gw-planner | Deletes ratebook folders |
| 8. Cleanup API Enablement Config | gw-planner | Removes API YAML files, runs codegen |
| 9. Remove Entity Extensions | gw-entity-agent | Removes entity extension files |
| 10. Cleanup Typelist | gw-typelist-agent | Removes typelist entries and files |
| 12. Milestone Check | gw-gosu-agent, gw-pcf-agent | gw-gosu-agent resolves compile errors; gw-pcf-agent resolves PCF reference errors from codegen |
| 13. GUnit Test Updates | gw-gosu-agent | Fixes broken unit tests |

---

## Output Format

The generated plan must follow this structure:

```markdown
# LOB Removal Plan: [LOB Code] — [LOB Name]

> Generated: {{timestamp}}
> LOB Code: {{lob_code}}
> Alternate Names: {{alternate_names}}
> Project Root: {{project_root}}

## Overview

Removal of the [LOB Name] ([LOB Code]) Line of Business from the PolicyCenter project.
This plan follows the phased approach to safely remove all LOB artifacts while maintaining
project integrity at each checkpoint.

## Pre-Conditions
- PolicyCenter project compiles successfully.
- The APD / Iapd Service Plugin is disabled.
- The `.pwc/agent/work-logs` folder exists.

## Phase 1: Establish the Baseline
...

## Phase 2: Remove LOB PCF Files
...

[Remaining phases from template]

## Success Criteria
- All phases completed with exit criteria met.
- `gwb codegen` completes successfully.
- `gwb compile` completes successfully.
- All GUnit tests pass.
```

---

## Behavioral Rules

1. **Never execute removal tasks without user approval.** This skill only generates the plan — execution is a separate step.
2. **Always confirm the LOB code and alternate names** before generating the plan to avoid accidental removal of the wrong LOB.
3. **Preserve the sequential ordering** of phases. Later phases depend on earlier phases completing successfully.
4. **Exit criteria are mandatory checkpoints.** The plan must clearly indicate that no phase proceeds until its exit criteria are verified and the user confirms.
5. **Log everything.** The plan must instruct agents to log all actions with timestamps to `.pwc/agent/work-logs`.
6. **Check lessons learned first.** Before troubleshooting, the plan must direct agents to consult `.pwc/agent/lessons`.
7. **User confirmation required** at each phase boundary — do not auto-proceed between phases.
