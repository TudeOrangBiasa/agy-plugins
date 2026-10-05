# Architecture — agy-minimal/wrasse

## Purpose

Keep `agy` sessions minimal and deterministic: lean agents, fast wrapper binaries, deny hooks, tuning skills, one harness — shipped as a portable plugin. `agy-minimal` replaces the default tool surface (deny-hooks + wrappers) and carries the base coding discipline, so installed stock `agy` runs general-purpose with no flags. No hidden steps, no duplicate search paths. Single agystack-based project: `rules/AGENTS.md` (subagent delegation invariant), `agents/poteto-agent.md`, `skills/poteto-mode/` + playbooks, `skills/agystack/`, `tests/` (pytest), `pyproject.toml`.

## Boundaries

| Boundary | Input | Output | Owner |
|---|---|---|---|
| Tool Override Layer (`plugins/agy-minimal/bin/{ffgrep,fffind,hasline}`, `block-native-*.sh`, `block-bash-bypass.sh`, `hooks.json`) | pattern + path / patch / shell command | `rg`/`fd` line output / deny JSON / edited file / allow-or-deny JSON | plugin bin |
| Shared Match Adapter (`plugins/agy-minimal/bin/lib-runmatch.py`: `strip_prose` + `leaves` + `split_segments` + `segment_head`, imported by both `run_command` gate modules with verbatim inline fallback) | hook payload + rule data | first-match deny / allow verdict, fail-open on bad payload or import failure | plugin bin |
| Shared Arg-Parse (`plugins/agy-minimal/bin/lib-ffargs.sh`: `ff_parse_args`, sourced by `ffgrep`/`fffind`) | `<pattern> [path] [-- <extra>]` args after the usage guard | globals `pattern`, `path`, `extra` (array) | plugin bin |
| Bin Inventory (`plugins/agy-minimal/bins.list`, read by doctor + smoke + deploy post-install probe) | repo tree | one tool-module filename per line, single source for install/check loops | plugin bin |
| Guidance Inject (`plugins/agy-minimal/bin/guidance-inject.sh`: interface parameters `transcriptPath` + tail-range + state-handle; overrides `STREAM_RULES`, `GUIDANCE_STATE_DIR`) | transcript `tool_calls` + inject rules | one `ephemeralMessage` notice per rule per conversation, `{}` otherwise | plugin bin |
| Deploy Installer + Janitor (`scripts/deploy-global.sh`: `install_all` vs `sweep_stale_plugins` + `clean_legacy`, `--dry-run` report interface, shared `LEGACY_*` names) | repo plugins + global `~/.gemini` | installed plugins + stale/legacy cleanup report | harness |
| Doctor (`plugins/agy-minimal/bin/agy-doctor`) | repo tree + global `~/.gemini` | `[ok]/[warn]/[fail]` lines, exit 0/1/2 | plugin bin |
| Web Layer (`plugins/agy-minimal/bin/tfsearch|tffetch` REST first, `mcp_config.json` → TinyFish MCP after OAuth) | query / URLs | compact snippets / clean markdown | plugin web |
| Rules Delegation Invariant (`rules/AGENTS.md`: subagent delegation invariant) | non-trivial engineering task | coordinator plan + `poteto-agent` delegate diffs, verification | agystack rules |
| Executor Agent (`agents/poteto-agent.md`, subagent+mainAgent, `inherit` model) | technical spec + test criteria from coordinator | code diff in isolated context, reads `poteto-mode` SKILL.md first | agystack agents |
| Mode + Playbooks (`skills/poteto-mode/SKILL.md`, `skills/agystack/SKILL.md`, 23 playbooks in `skills/poteto-mode/playbooks/`) | task + matched playbook | `implementation_plan.md` / `walkthrough.md` / report artifacts in `<appDataDir>/brain/<conversation-id>/` | agystack skills |
| Test Contract (`tests/*.py`, `test` extra in `pyproject.toml`: pytest + pytest-mock + pytest-timeout + ruff) | repo working tree | PASS/FAIL per test module | agystack tests |
| Harness Layer (`Makefile.harness`, `scripts/harness/*.sh`) | repo working tree | PASS/FAIL + logs | harness |
| Package Manifest (`pyproject.toml`: `agystack` 0.1.0, hatchling, `agent` + `test` extras) | repo tree | wheel (`skills` package) / installed extras | agystack packaging |

## Data Shape Contracts

- Parse and validate external data at boundaries.
- `ffgrep` output contract: `path:line:content`, `--color=never`, exit 0 on hit / 1 on no hit (rg semantics preserved).
- `fffind` output contract: one path per line, exit 0 always on success.
- Deny hook output contract: exactly `{"decision":"deny","reason":"..."}` on stdout, exit 0; stdin payload drained and ignored. Allow contract (PreToolUse): exactly `{"decision":"allow"}` — bare `{}` is rejected as `invalid_args` by newer runners (cmux#5358), so gates never emit bare `{}` on tool-gating paths. `guidance-inject` (PreInvocation) keeps `{}` — different event, no decision schema.
- `agy-doctor` output contract: exit 0 repo-ok / 1 repo gaps / 2 usage error; global gaps are `[warn]` only (fixed by deploy/manual `settings.json` step, never silently).
- `hooks.json` contract: matchers `grep_search|find_by_name` and `write_to_file|replace_file_content` → `PreToolUse` → `$HOME/.../block-native-*.sh`; matcher `run_command` → `$HOME/.../block-bash-bypass.sh`; matcher `*` → `$HOME/.../stream-gate.sh`; flat `PreInvocation` → `$HOME/.../guidance-inject.sh` (repo source portable; deploy expands `$HOME` to the literal absolute install path — hook cwd = session launch dir per exit-127 probe, runner env expansion unproven, no relative forms).
- Bypass hook output contract: skips wrapper-headed segments (`ffgrep|fffind|hasline|agy-doctor|tfsearch|tffetch`), strips quoted strings + heredoc bodies as prose, then denies raw `rg|fd|ripgrep`, recursive `grep`, `sed -i|perl -i`, unbounded `find` (no `-maxdepth 0/1`), `tree|locate`, `ls -R` in `CommandLine`; `{"decision":"allow"}` (fail-open) otherwise. Single-level listing (`ls`, `ls -d`, bounded `find`), pipe-filter `grep`, redirection, heredoc writes stay allowed.
- Shared match adapter contract: `lib-runmatch.py` exposes `strip_prose` (heredoc-body + quote removal, `$(...)` kept), `leaves` (string leaves of nested args), `split_segments`, `segment_head` (sudo-strip + basename); both gate modules import via `importlib` and fall back to verbatim inline logic on any import failure — fail-open preserved.
- Shared arg-parse contract: `lib-ffargs.sh` `ff_parse_args` consumes args after the caller's exit-2 usage guard and sets `pattern` / `path` (default `.`) / `extra` (array); sourced only, no exec bit, `here`-resolved.
- Bin inventory contract: `bins.list` holds one tool-module filename per line (11 entries); doctor + smoke iterate it for executable checks, deploy probes installed exec bits from it post-copy — adding a wrapper means one list edit.
- Guidance-inject interface contract: `transcriptPath` (missing/unreadable → `{}`), tail-range (one 262144-byte chunk from the stored offset, reset on shrink), state-handle (`agy-guidance-<safe-cid>.json` storing offset + fired set); matching stays inline (JSON-blob regex, not shell segments — lib-runmatch deliberately not reused). Model-context inject IS supported — this retracts the earlier non-goal claim.
- Convert to internal typed models before crossing module boundaries (shell: validate args before exec; see usage guards in plugin `bin/*`).
- Keep boundary transformation logic centralized and testable (wrappers only add ignore-globs, never reformat).

## Module Ownership Rules

- One primary responsibility per module (`ffgrep` = text search; `fffind` = file search; `hasline` = anchored edits; block scripts = deny; `rules/AGENTS.md` = delegation invariant; `poteto-agent` = code execution; `poteto-mode`/`agystack` = rigor + playbooks; `tests/` = pytest contract; `pyproject.toml` = packaging).
- No cross-layer shortcuts without explicit architecture update (agent MUST NOT call `rg`/`fd` directly; go through wrappers).
- New modules require ownership and boundary documentation (add row above + contract line).

## Execution Flow

1. Entry: `agy` (interactive, no flags) or `-p "<q>" --disable-slash-commands --effort low` (read-only script). Add `--add-dir <path>` only for `.agents/` customizations or an extra workspace dir.
2. Boundary parse/validate: wrapper checks `$# >= 1`, hook drains stdin.
3. Core execution: `exec rg…` / `exec fd…` / emit deny JSON.
4. Persistence/output: stdout lines (search) or deny reason (hook); no files written.
5. Event/log emission: harness scripts log `harness.*` events per `docs/OBSERVABILITY.md`.

## Refactor Checklist

- [ ] Boundary contracts unchanged or versioned.
- [ ] Ownership map still accurate.
- [ ] Integration tests cover boundary paths (`scripts/harness/test.sh` covers hit/no-hit/deny).
- [x] Documentation updated in same change.
