# ADR-0012: OMP agent-rules git port

Date: 2026-09-09
Status: Accepted

## Context

`~/.omp/agent/rules/` holds five rules. Only text-scope rules map to agy
`run_command` gates; OMP-edit-specific and workflow rules have no agy
mapping.

## Decision

Ported `git-guardrails` as four stream rules (force-push/hard-reset/discard
deny, protected-branch push `ask`); engine gained `decision: deny|ask`.
Skipped `bash-no-ls` (conflicts with mined evidence: plain ls cheap+legit),
OMP-edit-specific rules, and browser-verify.

## Consequences

- File order makes force-match win over protected-match deterministically.
- Rejected porting all five verbatim and the sentinel-file merge flow
  (agy `ask` covers it).
