#!/usr/bin/env bash
# ci.sh — CI-equivalent pipeline with structured harness events.
# Runs smoke + lint + typecheck + test, emitting harness.start/step/finish
# JSON event lines per docs/OBSERVABILITY.md. RUN_ID/TRACE_ID honored from
# env, generated otherwise. Exit code: first failing step's code.
set -euo pipefail
root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$root_dir"
RUN_ID="${RUN_ID:-run-$(date +%s)-$$}"
TRACE_ID="${TRACE_ID:-trace-$(date +%s)-$$}"
t0=$SECONDS
ts() { date -u +%Y-%m-%dT%H:%M:%SZ; }
emit() {
  printf '{"timestamp":"%s","level":"info","event_name":"%s","trace_id":"%s","run_id":"%s","step_id":"%s","component":"harness","status":"%s","duration_ms":%d}\n' \
    "$(ts)" "$1" "$TRACE_ID" "$RUN_ID" "$2" "$3" "$4"
}
emit harness.start ci start 0
for step in smoke lint typecheck test; do
  start=$SECONDS
  emit harness.step.start "$step" start 0
  set +e
  "./scripts/harness/$step.sh"
  code=$?
  set -e
  ms=$(( (SECONDS - start) * 1000 ))
  if [ "$code" -eq 0 ]; then
    emit harness.step.finish "$step" pass "$ms"
  else
    emit harness.step.fail "$step" fail "$ms"
    emit harness.finish ci fail $(( (SECONDS - t0) * 1000 ))
    exit "$code"
  fi
done
emit harness.finish ci pass $(( (SECONDS - t0) * 1000 ))
