---
document: authoring-guide-teaching-new-languages-to-llms
purpose: Explain the design approach used for this reference pack
scope: Maintenance guide, not runtime reference
---

# Authoring Guide: Teaching New Languages to LLM Agents

## Approach used

1. Anchor to a known language.
2. Teach only the deltas first.
3. Separate syntax, runtime, domain APIs, and validation.
4. Keep always-loaded guidance short.
5. Load detailed modules on demand.
6. Use pattern cards for repeated code structures.
7. Teach lookup behavior, not just facts.
8. Mark what must be verified in the project.
9. Use controlled redundancy for high-risk rules.
10. Add a final validation checklist.

## Applied to Gosu

Anchor language: Java.

Deltas:

- syntax differences
- equality semantics
- blocks/closures
- enhancements
- feature literals
- typekeys

Runtime/platform:

- entity metadata
- typelists
- bundles
- PCF
- rules
- validation

Domain API:

- Guidewire Query API
- Query result behavior
- ListView query-backed filters

## Best module shape

Each module should include:

- purpose/scope frontmatter
- trigger list
- mental model
- code patterns
- common mistakes
- verification requirements
- routing notes

## Do not overfit to one model

`CLAUDE.md` is useful for Claude Code, but the design is model-agnostic. For another agent, use `AGENT.md` as the system/router prompt and implement retrieval in the plugin.
