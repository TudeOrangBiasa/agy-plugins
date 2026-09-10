---
name: stream-rules
description: Manage TTSR-style named gate rules that block risky tool calls. Use when adding a new deny rule, tuning a false positive, disabling a noisy rule, or auditing what the stream gate blocks.
---

# stream-rules

Named gate and inject rules over tool calls — the portable TTSR subset.
`gate` denies risky PreToolUse calls; `inject` appends a one-shot guidance
notice at the next PreInvocation when the transcript shows the pattern
(agy-native ttsr-injection, deduped per conversation). Agy exposes no
free-text rewrite or session time-travel API, so redact/replace/time-travel
are explicit non-goals (see `docs/ARCHITECTURE.md`).

## Rule file

`plugins/agy-minimal/stream-rules.json`: `{"rules": [...]}`. Fields:

- `name` (unique), `type: "gate"`, `scope: ["pre_tool_use"]`, `enabled`
- `matcher` — regex over the tool name (`^run_command$`, or `.*`)
- `pattern` — regex over the serialized args; `flags` (`i`/`m`/`s`)
- `reason` — shown on deny; start with `[name]` so tests can assert it
- `decision` — `deny` (hard block) or `ask` (prompt user, respects Always Allow cache). Default `deny`; use `ask` when the user may legitimately override (e.g. pushing a protected branch on request).
- `text` — inject notice body (ephemeralMessage); required for `inject` rules.
- `strip_prose` — true ignores quoted/heredoc text (for code-shaped
  patterns); false keeps everything (for secret-shaped values, which
  live inside quotes)

First matching enabled rule (file order) denies.

## Steps

1. Add/edit the rule; enable only with a test in step 3.
2. Validate shape: `python3 -m json.tool` the file, then `make check`
   (typecheck compiles every pattern and flag).
3. Probe without a session:
   `printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"<cmd>"}}}' | plugins/agy-minimal/bin/stream-gate.sh`
   Expect `{"decision":"deny"|"ask","reason":"..."}` or `{}`.
4. Disable with `"enabled": false`, never delete the history.
5. `make test` green, then `./scripts/deploy-global.sh`.

## Verify

- Deny reasons name the rule; `make ci` green end to end.
