# ADR-0026: Base-default session, conditional frontend

Date: 2026-09-16
Status: Accepted

## Context

Single-persona cutover (ADR-0025) left plain `agy` reading as
frontend-specialized, forcing UI/UX guidelines onto every session. The
wanted model: `agy-minimal` is the base (tools + discipline),
`agy-frontend` contributes guidelines that activate only for UI/UX/FE
design work, plus an opt-in specialist persona. Install must stay
flag-free: deploy both plugins, run plain `agy`.

## Decision

Session default is base minimal, general-purpose, no flags. Frontend
rules/skills gate on task scope (interface code, styles, layout,
typography, colors, accessibility, copy, DESIGN.md, explicit design
review); outside that scope the agent stays on base discipline.
`--agent agy-frontend` forces the specialist. Docs updated in the same
change: core rules (base + routing), frontend rules (conditional
activation), persona (base-first opener + stay-base guideline),
ARCHITECTURE purpose/layers/entry, README use, AGENTS entry + glossary,
PLANS outcome.

## Consequences

- No new plugin, no bins/hooks moved; routing lives in always-on rules.
- Other agents installing get flag-free `agy` with frontend on demand.
