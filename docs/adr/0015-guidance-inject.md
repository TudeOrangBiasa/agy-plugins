# ADR-0015: Guidance-inject via transcriptPath

Date: 2026-09-09
Status: Accepted

## Context

The "structurally impossible" verdict on condition-triggered context
injection was wrong: every hook payload carries `transcriptPath`, and
PreInvocation supports `injectSteps`/`ephemeralMessage`. The transcript
schema (JSONL `tool_calls[].name/args`) was verified live.

## Decision

Built `bin/guidance-inject.sh` (PreInvocation): tails transcript tool
calls since the last stored offset (state in `/tmp` per conversation,
256KB new-byte cap), `inject` rules match serialized args, one
`ephemeralMessage` notice per rule per conversation. Seeded with
`guide-ts-no-any`.

## Consequences

- Retracts the impossibility claim; skill-only TS guidance stays as the
  complement (unconditional knowledge vs reactive notices).
- Rejected matching the full transcript each turn (offset state keeps it
  O(new bytes)).
