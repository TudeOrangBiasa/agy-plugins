# ADR-0001: Global-only agent discovery

Date: 2026-09-08
Status: Accepted (install mechanism superseded by ADR-0005; finding stands)

## Context

`agy agents` listed only `flutter_a11y_agent` until a global copy existed.
Workspace `.agents/agents/` and a workspace-root symlink were ignored: agy
reads agent markdown from its config dir directly.

## Decision

Agent discovery is global-only. Deploy the persona via
`scripts/deploy-global.sh`, never via workspace symlinks.

## Consequences

- Every machine needs a deploy step; the repo alone is not sufficient.
- ADR-0005 later replaced the per-file global copy with plugin packaging,
  keeping the global-only finding.
