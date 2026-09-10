# ADR-0013: TypeScript rules port (condensed + on-demand)

Date: 2026-09-09
Status: Accepted (always-on part reversed by ADR-0014)

## Context

OMP ships 13 `ts-*` builtin review rules (advisory, `interruptMode:
never`). Vendoring 20KB of full texts would bloat every-turn context.

## Decision

Port all 13 as a condensed checklist plus a `ts-review` skill fetching
full upstream texts on demand (MIT attribution included). Advisory-only —
never stream-gate denies.

## Consequences

- Rejected full-text vendoring (context cost) and gate patterns like
  `as any` (legit uses exist; upstream itself never interrupts).
- The always-on half of this decision was reversed the same day
  (see ADR-0014).
