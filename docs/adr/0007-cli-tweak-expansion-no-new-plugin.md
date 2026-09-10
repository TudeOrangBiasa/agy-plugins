# ADR-0007: CLI-tweak expansion without a new plugin

Date: 2026-09-09
Status: Accepted

## Context

CLI tweaks split across two owners: plugin-bundlable surface
(skills/rules/hooks/mcp/bin) vs global-owned files (`settings.json`,
global `hooks.json`, `config.json` plugin flags) needing manual steps.

## Decision

Expand `agy-minimal`, no new plugin: `skills/cli-tweaks/SKILL.md` (can vs
cannot-tweak table) + read-only `bin/agy-doctor` (repo FAIL vs global
WARN) + `rules/AGENTS.md` CLI Invocation section.

## Consequences

- Rejected a separate `agy-tweak` plugin (splits ownership, doubles deploy
  surface) and silent `settings.json` mutation (user-owned file).
- The doctor makes the ownership split observable instead of tribal
  knowledge.
