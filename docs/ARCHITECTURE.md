# Architecture — agy-minimal/wrasse

## Purpose

Keep `agy` sessions minimal and deterministic: lean agents, fast wrapper binaries, deny hooks, tuning skills, one harness — shipped as portable plugins. `agy-minimal` is the core: it replaces the default tool surface (deny-hooks + wrappers) so installed stock `agy` behaves fast, minimal, and efficient with no flags. `agy-frontend` is an extension of that core: taste layer + UI/UX principles (`better-*`) + on-demand verification checklists (`checklist-design`) for frontend/design work. No hidden UI steps, no duplicate search paths.

## Boundaries

| Boundary | Input | Output | Owner |
|---|---|---|---|
| Agent Layer (`plugins/agy-frontend/agents/agy-frontend.md`) | user prompt + AGENTS.md rules | `run_command` calls to plugin `bin/*` + frontend skills | agent config |
| Frontend Layer (`plugins/agy-frontend/agents/agy-frontend.md`, `skills/better-*`, `skills/design-taste/`, `skills/checklist-design/`) | user prompt + interface code | review findings (Block/Approve) + audit tables / critique + fixes in project idiom | plugin skills |
| Tool Override Layer (`plugins/agy-minimal/bin/{ffgrep,fffind,hasline}`, `block-native-*.sh`, `block-bash-bypass.sh`, `hooks.json`) | pattern + path / patch / shell command | `rg`/`fd` line output / deny JSON / edited file / allow-or-deny JSON | plugin bin |
| Doctor (`plugins/agy-minimal/bin/agy-doctor`) | repo tree + global `~/.gemini` | `[ok]/[warn]/[fail]` lines, exit 0/1/2 | plugin bin |
| Web Layer (`plugins/agy-minimal/bin/tfsearch|tffetch` REST first, `mcp_config.json` → TinyFish MCP after OAuth) | query / URLs | compact snippets / clean markdown | plugin web |
| Harness Layer (`Makefile.harness`, `scripts/harness/*.sh`) | repo working tree | PASS/FAIL + logs | harness |

## Data Shape Contracts

- Parse and validate external data at boundaries.
- `ffgrep` output contract: `path:line:content`, `--color=never`, exit 0 on hit / 1 on no hit (rg semantics preserved).
- `fffind` output contract: one path per line, exit 0 always on success.
- Deny hook output contract: exactly `{"decision":"deny","reason":"..."}` on stdout, exit 0; stdin payload drained and ignored.
- `agy-doctor` output contract: exit 0 repo-ok / 1 repo gaps / 2 usage error; global gaps are `[warn]` only (fixed by deploy/manual `settings.json` step, never silently).
- `hooks.json` contract: matchers `grep_search|find_by_name` and `write_to_file|replace_file_content` → `PreToolUse` → `./bin/block-native-*.sh`; matcher `run_command` → `./bin/block-bash-bypass.sh`; matcher `*` → `./bin/stream-gate.sh`; flat `PreInvocation` → `./bin/guidance-inject.sh` (hook cwd = plugin root, so the bundle is self-contained on any machine).
- Bypass hook output contract: skips wrapper-headed segments (`ffgrep|fffind|hasline|agy-doctor|tfsearch|tffetch`), strips quoted strings + heredoc bodies as prose, then denies raw `rg|fd|ripgrep`, recursive `grep`, `sed -i|perl -i`, unbounded `find` (no `-maxdepth 0/1`), `tree|locate`, `ls -R` in `CommandLine`; `{}` (allow, fail-open) otherwise. Single-level listing (`ls`, `ls -d`, bounded `find`), pipe-filter `grep`, redirection, heredoc writes stay allowed.
- Stream-gate contract: `stream-rules.json` named `gate` rules apply in file order over tool name + serialized args; first match denies with `[name]`-prefixed reason; fail-open otherwise. Non-goals (no agy API): free-text redact/replace, session time-travel.
- Guidance-inject contract: PreInvocation hook tails transcript `tool_calls` since the last stored offset (state in `/tmp` per conversation); `inject` rules match serialized args and emit one `ephemeralMessage` notice per rule per conversation; `{}` otherwise. Model-context inject IS supported — this retracts the earlier non-goal claim.
- Convert to internal typed models before crossing module boundaries (shell: validate args before exec; see usage guards in plugin `bin/*`).
- Keep boundary transformation logic centralized and testable (wrappers only add ignore-globs, never reformat).

## Module Ownership Rules

- One primary responsibility per module (`ffgrep` = text search; `fffind` = file search; `hasline` = anchored edits; block scripts = deny; minimal agent = persona).
- No cross-layer shortcuts without explicit architecture update (agent MUST NOT call `rg`/`fd` directly; go through wrappers).
- New modules require ownership and boundary documentation (add row above + contract line).

## Execution Flow

1. Entry: `agy --add-dir "$PWD" --agent agy-frontend` (interactive) or `-p "<q>" --disable-slash-commands --effort low` (read-only script).
2. Boundary parse/validate: wrapper checks `$# >= 1`, hook drains stdin.
3. Core execution: `exec rg…` / `exec fd…` / emit deny JSON.
4. Persistence/output: stdout lines (search) or deny reason (hook); no files written.
5. Event/log emission: harness scripts log `harness.*` events per `docs/OBSERVABILITY.md`.

## Refactor Checklist

- [ ] Boundary contracts unchanged or versioned.
- [ ] Ownership map still accurate.
- [ ] Integration tests cover boundary paths (`scripts/harness/test.sh` covers hit/no-hit/deny).
- [ ] Documentation updated in same change.
