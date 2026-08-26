# Guidewire Lift-and-Shift — Agent Knowledge Base

Knowledge base for Claude Code agents supporting Guidewire InsuranceSuite development. Each agent specializes in a domain (UI, logic, data model, typelists, build, planning) and delegates across boundaries to peer agents.

## Agents

| Agent | Domain | File |
|-------|--------|------|
| `gw-pcf-agent` | PCF (Page Configuration Format) — XML-based UI definitions | `agents/gw-pcf-agent.md` |
| `gw-gosu-agent` | Gosu — business logic, enhancements, queries, integrations | `agents/gw-gosu-agent.md` |
| `gw-entity-agent` | Entities — data model, extensions, foreign keys | `agents/gw-entity-agent.md` |
| `gw-typelist-agent` | Typelists — type keys, categories, filters | `agents/gw-typelist-agent.md` |
| `gw-build-agent` | Build & deployment — compilation, server, troubleshooting | `agents/gw-build-agent.md` |
| `gw-planner-agent` | Planning — task decomposition, story analysis, delegation | `agents/gw-planner-agent.md` |

Supporting reference: `agents/agent-construction-instruction.md`

## Directory Structure

```
agents/          — Agent definitions (one .md per agent)
context/         — Background knowledge, organized by domain
  pcf/           — 22 context files + README (UI layer)
  gosu/          — Language, platform, OOP, queries, integrations, cross-cutting
  entity/        — Entity/data model basics
  typelist/      — Typelist basics
  policycenter/  — PolicyCenter product context
  columbia/      — Columbia project conventions
rules/           — Firm conventions ("always/never" statements)
  pcf-agent-rules/  — 9 rules for PCF development
skills/          — Step-by-step task workflows
  pcf-agent-skills/ — 10 PCF task recipes
  pcf-find-usages/  — Find PCF references across the codebase
  entity-find-usages/ — Find entity references
  typelist-find-usages/ — Find typelist references
  pc-current-state/   — Analyze current PolicyCenter state
  pc-plan-lob-removal/ — LOB removal planning workflow
  grill-me/           — Knowledge verification drill
tools/           — Debugging/inspection aids
  pcf/           — PCF inspection and debugging
  python/        — Python tooling instructions
  typescript/    — TypeScript tooling instructions
scripts/         — Automation scripts
extras/          — External tools (PwCGosuAssistant, data builders)
pc-appguide-palisades/ — Guidewire reference documentation
```

## How Knowledge Is Organized

Each agent's knowledge follows four layers:

| Layer | Purpose | Example |
|-------|---------|---------|
| **Context** | What things are and how they work conceptually | `context/pcf/01-pcf-overview.md` |
| **Rules** | Checkable conventions — violating these causes real problems | `rules/pcf-agent-rules/01-naming-and-organization.md` |
| **Skills** | Repeatable task recipes with worked examples | `skills/pcf-agent-skills/06-adding-fields-to-detail-view.md` |
| **Tools** | Debugging aids and inspection techniques | `tools/pcf/01-inspection-and-debugging.md` |

Agents load context on-demand via trigger-based routing (see `context/gosu/00-agent-routing.md` for the pattern).

## Cross-Agent Delegation

Agents own exclusive file types and delegate when work crosses boundaries:

| File Type | Owner | Delegates to |
|-----------|-------|-------------|
| `.pcf` (XML UI) | `gw-pcf-agent` | Gosu logic → `gw-gosu-agent` |
| `.gs`, `.gsx` (Gosu) | `gw-gosu-agent` | Entity schema → `gw-entity-agent` |
| `.eti`, `.etx` (Entities) | `gw-entity-agent` | Typelists → `gw-typelist-agent` |
| `.tti`, `.ttx` (Typelists) | `gw-typelist-agent` | — |
| Build/server issues | `gw-build-agent` | — |

## Provenance

Content is drawn from three tiers of source, in descending order of trust:

1. **Real project code** — highest confidence, used to resolve conflicts
2. **Guidewire Education modules** — high confidence, structured course material
3. **Public Guidewire documentation** — lower confidence; conflicts flagged inline

Where sources conflicted, resolution notes are preserved inline in the relevant file.

## Contributing

- Follow the construction instructions in each directory (`agent-construction-instruction.md`, `skills-construction-instruction.md`, `rules-construction-instructions.md`, `scripts-construction-instruction.md`)
- Use `_Ext` suffix conventions for all custom identifiers
- Prefer modifying existing base files over creating new ones when possible
- Keep context factual, rules checkable, and skills task-shaped
