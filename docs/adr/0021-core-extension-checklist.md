# ADR-0021: Core-extension vocabulary + Checklist Design verification

Date: 2026-09-10
Status: Accepted (bundling consequence superseded by ADR-0022)

## Context

Domain language never named the plugin relationship: `agy-minimal`
replaces the default tool surface (deny-hooks + wrappers, deny-observed
without flags), while `agy-frontend` only adds interface knowledge
(ADR-0017). Design/frontend work additionally needs itemized
verification, not just principles: [checklist-design/skills](https://github.com/checklist-design/skills)
(MIT, 129 checklists, audit vs critique modes). Constraints: always-on
budget (every skill injects per turn — 129 files can never be bundled),
code-first review with browser second, complements (not replaces)
`better-*`.

## Decision

Vocabulary: `agy-minimal` is the **core**, `agy-frontend` its
**extension (taste layer)**. Vendor `skills/checklist-design/` as
`SKILL.md` (condensed agy port: code-first order, on-demand fetch) plus
`references/audit.md` + `references/critique.md` verbatim as mode
discipline; checklist content stays upstream, fetched via `tffetch`
(index → match → file) only when an audit matches. Docs updated in the
same change: `ARCHITECTURE.md` purpose + Frontend Layer row, `AGENTS.md`
glossary, frontend persona/rules/`plugin.json`/ATTRIBUTION, `PLANS.md`
snapshot, smoke coverage.

## Consequences

- Audits need network at runtime (web layer); offline harness unaffected.
- No sync burden: upstream refreshes daily, we fetch live so checklists
  are always current (unlike the full fork rejected in ADR-0017).
- Unseen/unrun checks report `Not verified`, per repo discipline.
