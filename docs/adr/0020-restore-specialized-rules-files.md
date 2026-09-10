# ADR-0020: Restore specialized rules files

Date: 2026-09-10
Status: Accepted (supersedes ADR-0019)

## Context

ADR-0019 deleted both `rules/AGENTS.md` files as duplication. That was
wrong on coverage: plugin rules load whenever the plugin is enabled —
even under the default agent — while the persona loads only when its
agent is selected. Deletion dropped default-agent coverage.

## Decision

Restored both files, specialized instead of duplicated: agy-minimal keeps
`--add-dir` + settings consent (its hooks depend on the former); dropped
its mislabeled Frontend-only line (minimal is general). Frontend keeps
scope + requires-minimal note, dropping the duplicated session/consent
lines. Folded persona lines reverted; stale pointers (bypass reason,
cli-tweaks skill) retargeted or made self-contained.

## Consequences

- ADR-0019 stands as history of the over-deletion, not as guidance.
- Coverage rule going forward: always-on knowledge needs a home that
  loads without agent selection.
