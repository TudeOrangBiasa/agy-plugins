# Observability — agy-minimal/wrasse

## Goal

Make agent and harness workflows diagnosable without reproducing locally. Minimal means fewer events, but stable fields.

## Required Event Fields

- `timestamp`
- `level`
- `event_name`
- `trace_id`
- `run_id`
- `step_id`
- `component`
- `status`
- `duration_ms`

## Event Taxonomy

- `harness.start`
- `harness.step.start`
- `harness.step.finish`
- `harness.step.fail`
- `harness.check.pass`
- `harness.check.fail`
- `agy.search.deny` (hook denied `grep_search`/`find_by_name`; reason references `ffgrep`/`fffind`)
- `agy.bypass.deny` (hook denied raw shell search/edit in `run_command`; include trigger token + target wrapper)
- `agy.search.run` (wrapper executed `rg`/`fd`; include `pattern`, `path`, `hit_count`)
- `harness.finish` (pipeline done; `status` pass/fail, total `duration_ms`, `step_id: ci`)
- `agy.stream.deny` (named stream rule denied a tool call; include rule name)
- `agy.guide.inject` (guidance notice injected at PreInvocation; include rule name)

## Logging Rules

- Emit structured logs for machine parsing.
- Keep field names stable over time.
- Include enough context to replay failures (`pattern`, `path`, exit code for search; matcher + decision for deny).
- Redact secrets and personally identifiable values.
- Harness scripts: `echo "[ok|fail] <step>"` to stdout; failures exit non-zero with reason on stderr.

## Metrics

- Smoke-check duration (budget: < 30s, offline, no network)
- Check failure rate (lint/type/test)
- Retry count per run
- Time-to-first-actionable-error
- Deny-hook hit rate (how often agent still tries native search — proxy for prompt-leak)

## Alerting

- Alert on repeated harness failures in CI.
- Alert on missing observability fields in critical events.
- Alert on regression in smoke-check runtime budget.
