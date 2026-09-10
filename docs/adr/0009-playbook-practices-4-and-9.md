# ADR-0009: Harness practices 4 and 9 made real

Date: 2026-09-09
Status: Accepted

## Context

The harness audit passed 21/21 but only checked file existence; the
observability taxonomy listed events nothing emitted; the audit script lived
outside the repo.

## Decision

Vendored `scripts/audit_harness.sh` (template copy); `make ci` routes
through `scripts/harness/ci.sh` emitting `harness.start/step/finish` JSON
events with `RUN_ID`/`TRACE_ID`; CI runs audit as a separate job.

## Consequences

- Rejected per-script event emission (noise over 80 `[ok]` lines) and
  plugin assertions in audit (`agy-doctor` owns repo checks, no duplication).
- Step output still passes through (not swallowed); fail-fast keeps the
  first failing step's exit code.
