# ADR-0019: Kill redundant plugin rules files

Date: 2026-09-10
Status: Accepted

## Context

Both `rules/AGENTS.md` files held near-identical boilerplate with no
per-plugin specialization; everything they said already lived in the
personas, skills, or hook reasons.

## Decision

Deleted both files; folded the only unique lines into the personas
(`--add-dir` session rule + global-config consent each, frontend-only
scope only in agy-frontend). Doctor now asserts the persona lines
instead of the deleted files.

## Consequences

- One fewer always-on surface per plugin; no duplication to drift.
- Future always-on needs go to the persona (tools/routing) or a skill,
  never a third file.
