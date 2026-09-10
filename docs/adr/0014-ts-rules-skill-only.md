# ADR-0014: TypeScript rules skill-only

Date: 2026-09-09
Status: Accepted

## Context

ADR-0013 shipped the checklist as an always-on `rules/typescript.md`
(~2KB every turn). Multi-file `rules/` loading is unproven — the official
docs recommend a single consolidated `AGENTS.md`.

## Decision

Deleted the always-on file; checklist consolidated into
`skills/ts-review/SKILL.md`, one pointer bullet in `rules/AGENTS.md`.

## Consequences

- Skill progressive disclosure is the designed mechanism for advisory
  knowledge; always-on stays reserved for backstop rules.
