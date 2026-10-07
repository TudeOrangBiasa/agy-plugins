# AGENTS.md — agy-minimal/wrasse

## Project Overview

- Project: `agy-minimal` (workspace `wrasse`) — single agystack-based project.
- Primary runtime(s): `bash`, `agy` (Antigravity CLI 1.1.27), `python3` (pytest via `make test-py`: `uv run --no-project --with pytest`, offline).
- Main entrypoint(s): `agy` (no flags — base minimal tools), `plugins/agy-minimal/bin/{ffgrep,fffind,hasline,agy-doctor,tfsearch,tffetch}`, `poteto-mode`/`agystack` skills + playbooks (`skills/poteto-mode/`, `skills/agystack/`).

## Harness Commands

Run from repository root:

| Goal | Command |
|---|---|
| Fast sanity check | `make smoke` |
| Static checks | `make check` |
| Full test suite | `make test` |
| Python suite (upstream workflows) | `make test-py` |
| Python lint | `make lint-py` |
| Full stack CI (harness + Python) | `make ci-py` |

## Tooling Overrides

- Wrapper-first: search/edit/diagnose go through plugin wrappers (`ffgrep`/`fffind`, `hasline`, `agy-doctor`); native tools stay denied.
- Search via `run_command`: `ffgrep <pattern> [path]`, `fffind <pattern> [path]` (see `plugins/agy-minimal/skills/ff-search/SKILL.md`).
- Edit via `run_command`: `hasline show`, then `hasline apply` (see `plugins/agy-minimal/skills/hasline-edit/SKILL.md`); stale `#TAG` aborts — re-`show`, never guess.
- Diagnose via `run_command`: `agy-doctor` before touching global config.
- Native search/edit tools and raw-shell bypasses (`rg|fd`, recursive `grep`, `sed -i`/`perl -pi`, unbounded `find`, `tree|locate`, `ls -R`) are denied by plugin hooks with reasons pointing back here; plain `ls`, `ls -d`, bounded `find` stay allowed.
- Hook `command` paths are `$HOME`-anchored to the installed plugin bin in repo source (portable); deploy expands `$HOME` to the literal absolute path (runner env expansion unproven; hook cwd = session launch dir, so relative `./bin/...` resolves nowhere — proven by exit-127 probe).
- Skills: agentic rigor via `skills/agystack/SKILL.md` (framework entry → `skills/poteto-mode/SKILL.md` + 23 playbooks); non-trivial code edits delegate to `poteto-agent` per `rules/AGENTS.md`.

## Minimal Prompt

- Session model: plain `agy` runs general-purpose with no flags — agy-minimal (tools + discipline).
- Keep `AGENTS.md` to hard rules only; move workflows to `skills/<name>/SKILL.md`.
- Pass `--add-dir "$PWD"` only when the workspace has `.agents/` customizations (installed global plugin loads without flags); `-p` is read-only, interactive session executes — deny-scope + nested-Orca notes live in `plugins/agy-minimal/skills/cli-tweaks/SKILL.md`.
- Diagnose CLI state with `agy-doctor` via `run_command` before touching global config.
- Disable unused plugins / idle MCP servers; prefer Lazy over Eager.

## Constraints And Guardrails

- Prefer deterministic scripts over interactive/manual steps.
- Keep command names stable (`smoke`, `check`, `test`, `ci`).
- Update docs and scripts in the same change when workflow behavior changes.
- Avoid side effects outside the repo unless explicitly required.

## Architecture Boundaries

- Parse and validate external data at boundaries.
- Keep internal data models typed and normalized.
- Keep each module focused on one responsibility.
- Document boundary ownership in `docs/ARCHITECTURE.md`.

## Observability Expectations

- Include `trace_id` and `run_id` in long-running workflow logs.
- Emit structured event names for major transitions (start, step, success, failure).
- Keep event fields stable for querying and alerting.
- Maintain field definitions in `docs/OBSERVABILITY.md`.

## Execution Plans

- For tasks expected to exceed ~30 minutes, create/update `PLANS.md` before coding.
- Track scope, constraints, milestones, and verification steps.
- Update status checkpoints during execution and after major decisions.

## Static Analysis And Quality Gates

- Run `make check` before `make test`.
- Run `make ci` before pushing large refactors.
- Treat lint/type failures as blocking.

## Entropy Management

- Remove stale scripts/docs quickly.
- Keep templates and real workflows in sync.
- Run periodic harness audits: `./scripts/audit_harness.sh .` (also enforced as a CI job).

## Glossary

- wrapper: plugin `bin/*` script run via `run_command` (`ffgrep`, `fffind`, `hasline`, `agy-doctor`, `tfsearch`, `tffetch`).
- deny hook: PreToolUse hook answering `deny` + reason (`enforce-custom-search`, `enforce-hasline-edit`, `enforce-wrapper-only`).
- stream rule: named `gate`/`ask`/`inject` entry in `stream-rules.json`, enforced by `stream-gate.sh` or `guidance-inject.sh`.
- guidance notice: one-shot `ephemeralMessage` injected at PreInvocation, once per rule per conversation.
- global config: `~/.gemini` files (`settings.json`, `hooks.json`) — user-owned, diagnose with `agy-doctor`, never mutate silently.
- plugin source of truth: `plugins/agy-minimal/` in this repo; the global install is a deploy target.
- core: `agy-minimal` plugin — the base: owns the tool surface (deny-hooks + wrappers) and base coding discipline; installed, stock `agy` runs general-purpose with no flags.
- `-p` mode: non-interactive `agy` run; read-only, agent emits copy-paste commands.
- `#TAG`: `hasline` snapshot anchor (`[FILE#TAG]`); stale tag aborts, re-`show`.

## Agent skills

### Issue tracker

Issues live as markdown files under `.scratch/` (gitignored runtime dir, created on first use). See `docs/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `docs/adr/` at the repo root (`GLOSSARY.md` created lazily by `/domain-modeling`). See `docs/agents/domain.md`.

### Framework

Agentic rigor: `skills/agystack/SKILL.md` (framework entry) → `skills/poteto-mode/SKILL.md` + playbooks; executor `agents/poteto-agent.md`.
