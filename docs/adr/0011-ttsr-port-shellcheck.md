# ADR-0011: TTSR port (gate subset) and shellcheck enforcement

Date: 2026-09-09
Status: Accepted

## Context

OMP's TTSR (named stream rules, deterministic order, skip-broken) maps to
agy PreToolUse gates; redact/replace/time-travel have no agy API. Shell
scripts had never been statically checked (`shellcheck` skipped when absent).

## Decision

Ported TTSR as `stream-rules.json` + `bin/stream-gate.sh` (gate-only
subset) with `rm -rf /` and secret-value seed rules. Shellcheck mandatory
via binary → `nix run` → CI apt. Fixed SC2181 for real; file-level-disabled
SC2015 (helpers provably exit 0) and intentional-literal SC2016.

## Consequences

- The port caught a real bug: prose-strip must run per value-leaf, not on
  serialized JSON (which is all quotes).
- Rejected migrating bypass patterns into stream rules (segmentation logic
  too specialized) and a full engine with inject (then unproven —
  see ADR-0015).
