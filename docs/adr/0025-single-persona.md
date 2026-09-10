# ADR-0025: Single frontend persona

Date: 2026-09-10
Status: Accepted

## Context

Two personas (`agy-minimal`, `agy-frontend`) forced a per-session
choice for what is one job: frontend work on a minimal tool surface.
The plugin split (tool surface vs taste, ADR-0017) still holds — only
the persona split is merged.

## Decision

`agy-frontend` absorbs the full core tool inventory, guidelines, and
skill routing; `agy-minimal.md` deleted. All references repointed
(deploy verify warns if the split name resurfaces, smoke asserts its
absence, typecheck/doctor/ARCH/AGENTS/README/cli-tweaks/snapshot
updated). Default-agent coverage unchanged (rules carry it).

## Consequences

- `agy --agent agy-minimal` stops resolving; the single voice is
  `agy --agent agy-frontend`, specialized for frontend/design quality.
