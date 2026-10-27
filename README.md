# Guidewire Lift-and-Shift — Agent Knowledge Base

Knowledge base for Claude Code agents supporting Guidewire InsuranceSuite development. Each agent specializes in a domain (UI, logic, data model, typelists, build, planning). Work that crosses domains is handed back to the main session, which dispatches the next agent.

## Installation

- Clone this repo **as** the project's `.claude/` directory (e.g. `PC-AI-Test/.claude/`). Claude Code loads agents only from `.claude/agents/`, skills only from `.claude/skills/<name>/SKILL.md` and rules from `.claude/rules/`.
- Launch Claude Code from the project root (the directory containing `gwb.bat`). All knowledge-base paths in this repo are written relative to it, as `.claude/...`.
- **Prerequisite:** install the `pc-appguide-palisades` skill from Helix (user-level, e.g. `~/.claude/skills/pc-appguide-palisades/`). The PCF, Gosu, entity, typelist and planner agents use it for Guidewire reference material; without it they say so and fall back to `context/`.

## Agents

| Agent | Domain | File |
|-------|--------|------|
| `gw-pcf-agent` | PCF (Page Configuration Format) — XML-based UI definitions | `agents/gw-pcf-agent.md` |
| `gw-gosu-agent` | Gosu — business logic, enhancements, queries, integrations | `agents/gw-gosu-agent.md` |
| `gw-entity-agent` | Entities — data model, extensions, foreign keys | `agents/gw-entity-agent.md` |
| `gw-typelist-agent` | Typelists — type keys, categories, filters | `agents/gw-typelist-agent.md` |
| `gw-build-agent` | Build & deployment — compilation, server, troubleshooting | `agents/gw-build-agent.md` |
| `gw-planner` | Planning — task decomposition, story analysis, phased plans (writes plans only) | `agents/gw-planner-agent.md` |

## Directory Structure

```
agents/          — Agent definitions only (one .md per agent, with frontmatter)
context/         — Background knowledge, organized by domain (read on demand by path)
  pcf/           — 22 numbered context files, basic-pcf, README, open-questions
  gosu/          — Language, platform, OOP, queries, integrations, cross-cutting
  entity/        — Entity/data model basics
  typelist/      — Typelist basics
  policycenter/  — PolicyCenter product context
  columbia/      — Columbia project conventions
rules/           — Firm conventions ("always/never" statements), path-scoped
  gw-gosu-agent-rules/ — 8 rules; load when Gosu files are touched
  pcf-agent-rules/     — 9 rules; load when .pcf files are touched
skills/          — Step-by-step task workflows (each folder has a SKILL.md with frontmatter)
  pcf-agent-skills/     — Router + 10 PCF task recipes
  pcf-find-usages/      — Find PCF references across the codebase
  gosu-find-usages/     — Find Gosu class/enhancement/rule references
  entity-find-usages/   — Find entity references in Gosu
  typelist-find-usages/ — Find typelist references
  typelist-removal-skill/ — Remove a typelist and its references (destructive)
  pc-current-state/     — Snapshot the PolicyCenter dev environment
  pc-plan-lob-removal/  — LOB removal plan + orchestration (runs in the main session)
  grill-me/             — Interview the user to stress-test a plan
tools/           — Debugging/inspection aids
  pcf/           — PCF inspection and debugging
  python/        — Python tooling instructions
  typescript/    — TypeScript tooling instructions
scripts/         — Automation scripts
contributing/    — Construction guides for agents, rules and skills
test_plan/       — Agent test plans
```

## How Knowledge Is Organized

Each agent's knowledge follows four layers:

| Layer | Purpose | How it loads | Example |
|-------|---------|--------------|---------|
| **Context** | What things are and how they work conceptually | Agent reads by path, per its trigger map | `.claude/context/pcf/01-pcf-overview.md` |
| **Rules** | Checkable conventions — violating these causes real problems | Auto-loaded when a matching file is read (`paths:` frontmatter); agents also read them up front | `.claude/rules/pcf-agent-rules/01-naming-and-organization.md` |
| **Skills** | Repeatable task recipes with worked examples | `Skill` tool, or Read of the `SKILL.md` path | `.claude/skills/pcf-agent-skills/SKILL.md` |
| **Tools** | Debugging aids and inspection techniques | Agent reads by path | `.claude/tools/pcf/01-inspection-and-debugging.md` |

Agents load context on demand via trigger-based routing (see `.claude/context/gosu/00-agent-routing.md` for the pattern).

## Cross-Agent Work

Subagents cannot start other subagents, so all dispatching happens in the main session:

1. The main session dispatches an agent for the file type it owns.
2. The agent finishes its own part. If another file type needs changing, it ends its reply with a **Handoff** block (target agent, files, change needed, what it already did).
3. The main session dispatches each Handoff, one at a time when they touch shared files.

| File Type | Owner | Typical handoffs |
|-----------|-------|------------------|
| `.pcf` (XML UI) | `gw-pcf-agent` | Gosu helpers → `gw-gosu-agent` |
| `.gs`, `.gsx`, `.gr`, `.gst` (Gosu) | `gw-gosu-agent` | Entity schema → `gw-entity-agent`, typelists → `gw-typelist-agent`, UI → `gw-pcf-agent` |
| `.eti`, `.etx`, `.eix` (Entities) | `gw-entity-agent` | Typelists → `gw-typelist-agent`, Gosu → `gw-gosu-agent`, UI → `gw-pcf-agent` |
| `.tti`, `.ttx` (Typelists) | `gw-typelist-agent` | Typekey columns → `gw-entity-agent` |
| Build/server issues | `gw-build-agent` | Code fixes → the owning agent |

`gw-planner` writes plans that name the responsible agent for each step; the main session executes them. LOB removal runs through the `pc-plan-lob-removal` skill in the main session.

## Provenance

Content is drawn from three tiers of source, in descending order of trust:

1. **Real project code** — highest confidence, used to resolve conflicts
2. **Guidewire Education modules** — high confidence, structured course material
3. **Public Guidewire documentation** — lower confidence; conflicts flagged inline

Where sources conflicted, resolution notes are preserved inline in the relevant file. Unconfirmed PCF facts are tracked in `context/pcf/open-questions.md`.

## Contributing

- Follow the construction guides in `contributing/` (`agent-construction-instruction.md`, `skills-construction-instruction.md`, `rules-construction-instructions.md`) and `scripts/scripts-construction-instruction.md`
- Keep `agents/` for agent definitions only; every skill needs a `SKILL.md` with `name` (= folder name) and `description` frontmatter; every rule file needs `paths:` frontmatter
- Write knowledge-base links as `.claude/...` paths from the project root, never `/context/...`
- Name agents exactly as in the table above in delegation tables and Handoff blocks
- Use `_Ext` suffix conventions for all custom identifiers
- Prefer modifying existing base files over creating new ones when possible
- Keep context factual, rules checkable, and skills task-shaped
