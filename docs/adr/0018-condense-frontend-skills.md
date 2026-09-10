# ADR-0018: Condense vendored frontend skills

Date: 2026-09-10
Status: Accepted

## Context

ADR-0017 vendored seven `better-*` skills verbatim (28 files, ~70KB).
That contradicts the minimal-token goal the same way the reverted
`rules/typescript.md` did (ADR-0014) — vendored depth is repo weight that
invites full reads.

## Decision

Condense each skill to its enforceable core (principles with exact values,
mistake tables, reporting discipline) with deep-shelf links fetching one
upstream file on demand — the ts-review pattern. Deleted all 21 subfiles.

## Consequences

- Skill bodies stay load-cheap; depth costs one fetch when needed.
- Upstream drift is now a link-rot risk instead of a sync burden;
  re-vendor passively on findings, never on schedule.
