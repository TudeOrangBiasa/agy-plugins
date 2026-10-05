# ADR-0027: Portable hook commands, literal at deploy

Date: 2026-09-18
Status: Accepted

## Context

Every tool call in foreign-cwd sessions (Bali-Sea-CMS, conversation
`679fc90e`) failed with `tool call denied by pre-tool hook: ` (empty
reason) — including `list_dir`, `view_file`, `run_command echo test`,
`call_mcp_tool figwright/ping`, `invoke_subagent`. Same-session probe
from the repo root failed identically (conversation `ca9e95be`),
ruling out Orca nesting or workspace trust. Hook scripts run by hand
from any cwd return `{}`/`deny-with-reason` correctly, so the scripts
are fine — the `command` path is not. Direct probe: `sh -c
'./bin/stream-gate.sh'` from Bali-Sea-CMS → exit 127 (no such file);
`sh $HOME/.gemini/config/plugins/agy-minimal/bin/stream-gate.sh` →
`{}` exit 0. Hook cwd = session launch dir, not plugin root — ADR-0005's
`./bin/` assumption was wrong (its "deny-observed" proof was a same-cwd
session). External corroboration: Medium path note (relative hook paths
resolve against the launch terminal's cwd) and the official hooks doc
(plugin `hooks.json` is a packaged file location, with no cwd guarantee
stated for `command`).

## Decision

Repo source keeps `$HOME`-anchored hook `command` values (5 entries in
`plugins/agy-minimal/hooks.json` — portable, machine-independent);
`scripts/deploy-global.sh` expands `$HOME` to the literal absolute
install path when copying to the global plugin dir. `typecheck.sh`
asserts the `$HOME` form on source. Supersedes ADR-0005's `./bin/` form
(and revives ADR-0003's absolute-path finding). Literal-in-source was
considered and rejected: it hardcodes one machine's path into the
shareable repo. `$HOME`-at-runner was considered and rejected: proven
only via shell, never via the hook runner — deploy-time expansion needs
zero runner expansion.

## Consequences

- Gates keep their narrow deny behavior (7 stream rules + wrapper
  denies) but now actually execute from any cwd: allow returns `{}`,
  deny returns reason — no more empty-reason global block.
- Fix is incomplete until redeploy copies the new `hooks.json` to the
  global plugin dir; stale global copy keeps failing.
- Collateral fix in the same change: quoted `description` values in
  `design-taste`/`checklist-design` SKILL.md (unquoted `:` broke YAML
  frontmatter parse per CLI skill loader errors in every session log).

## Amendment 2026-09-20 (allow contract)

Upstream `manaflow-ai/cmux#5358` proves `{}` is rejected as `invalid_args`
on `PreToolUse` by newer runners (their `PreToolUse` hook emitting `{}` —
like ours did — denied every tool call). Same empty-deny symptom as ours.
`stream-gate.sh` + `block-bash-bypass.sh` allow paths now emit
`{"decision":"allow"}` (official docs contract). Deny paths and
`guidance-inject` (`PreInvocation`, `{}`) unchanged.
