# ADR-0017: Frontend tuning as a separate plugin

Date: 2026-09-10
Status: Accepted

## Context

Interface-quality principles (layout, typography, color, accessibility,
UI, writing, review) were chosen from jakubkrehel/skills after grilling:
copy-adapt over full fork, markdown over TS conversion, separate plugin
over merging into agy-minimal.

## Decision

New `agy-frontend` plugin: `agy-frontend` persona, seven vendored-verbatim
`better-*` skills (+ATTRIBUTION.md, MIT), no bins/hooks of its own —
tooling reuses agy-minimal wrappers. Deploy script installs both plugins.

## Consequences

- Rejected full fork (permanent sync burden), TS conversion of prose
  (guidance is not executable; TS only fits computable checkers), and
  merging into agy-minimal (keeps the core plugin minimal; one extra
  deploy line instead).
- Browser-dependent recipes stay vendored but report `Not verified`
  without a browser, per the skills' own reporting discipline.
