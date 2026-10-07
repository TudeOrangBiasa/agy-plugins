# PLANS.md — agy-minimal/wrasse

## Objective

- Outcome: portable agy plugin harness — single plugin `agy-minimal` (minimal tools + discipline: lean agent surface, fff search binaries, hashline editor, deny hooks, lazy TinyFish web tools; installed stock `agy` runs general-purpose with no flags). Install = deploy `plugins/agy-minimal/` (community-ready).
- Why it matters: every active skill/plugin/MCP schema is injected into the system prompt each turn; native search/edit tools duplicate what `rg`/`fd`/anchored edits do cheaper. Artifacts act as memory (bloat/slowness suspect) → agent is told not to create them unless asked.
- Non-goals: unregistering core tools at binary level (unsupported); global `~/.gemini` hand-edits (deploy script owns installs); `~/AGENTS.md` diet (user's file, out of scope).

## Constraints

- Runtime/tooling constraints: `agy` 1.1.27, `bash`, `rg`, `fd`, `python3` present; `ffgrep`/`fffind`/`hasline` vendored in plugin `bin/`; TinyFish REST needs `TINYFISH_API_KEY` in env.
- Security/compliance constraints: hooks deny with reason, no silent fallback; no secrets in logs.
- Performance/reliability constraints: smoke < 30s; no network in smoke/check.

## Context Snapshot

- Relevant files/modules: `plugins/agy-minimal/` (`plugin.json`, `hooks.json`, `rules/`, `skills/`, `bin/`, `stream-rules.json`, `mcp_config.json`), `AGENTS.md`, `docs/ARCHITECTURE.md`, `docs/OBSERVABILITY.md`, `docs/adr/`, `scripts/harness/*.sh`, `scripts/audit_harness.sh`, `scripts/deploy-global.sh`.
- Existing commands/workflows: `make smoke|check|test|ci` via `Makefile.harness` (shell harness); `make test-py|lint-py|ci-py` for the Python workflow suite (CI `python` job).
- Known risks: core tools can't be unregistered, only denied; `agy plugin disable`/`agy mcp disable` affect global config, applied manually not in scripts.

## Execution Plan

1. Step: Baseline + bootstrap
   - Expected output: harness files present, `audit_harness.sh` PASS.
   - Verification: audit output + `git status --short`.
2. Step: Minimal agent + tool overrides
   - Expected output: stock `agy` runs general-purpose with no flags; native search denied; `ffgrep`/`fffind` return expected hits.
   - Verification: `scripts/harness/smoke.sh` + `test.sh` green.
3. Step: Docs + harness wiring (ARCHITECTURE/OBSERVABILITY, lint/typecheck)
   - Expected output: boundaries + event fields documented; `make check` green offline.
   - Verification: `make ci` green; audit PASS.

## Checkpoints

- [x] Baseline captured
- [x] Bootstrap + audit PASS (template defaults)
- [x] Minimal agent + ffgrep/fffind + deny hook wired
- [x] Static checks passed (`make check` green)
- [x] Tests passed (`make test` green, 8/8 contracts)
- [x] CLI-tweak expansion (no new plugin): `skills/cli-tweaks/`, `bin/agy-doctor`, rules CLI section, harness coverage
- [x] Playbook gap closure: vendored audit + CI audit job, `ci.sh` structured events (practices 4+9 real)
- [x] Frontend deletion: `plugins/agy-frontend/` removed; all live refs cleared (docs/adr/* historical only) (d1a0466)
- [x] Base landing: single agystack-based project (`rules/`, `agents/poteto-agent.md`, `skills/poteto-mode/` + playbooks, `skills/agystack/`, `tests/`, `pyproject.toml`) (d1a0466)
- [x] ADR-0029 deferred debt log (items 11–20, branch-dependent test note) (PR #5)
- [x] Glossary rename: `CONTEXT.md` → `GLOSSARY.md` + stale frontend-skill ref fix (PR #6)
- [x] Deploy registration: `agy plugin install` after copy in `scripts/deploy-global.sh` (PR #7, 99e7278)

## Decision Log

Decisions live in `docs/adr/` (ADR-0001–ADR-0029, short-form: Context → Decision → Consequences). Do not duplicate them here; append a new ADR per structural choice.

## Final Verification

- Commands run: `make ci` (exit 0), `audit_harness.sh` (PASS), `scripts/deploy-global.sh` (exit 0, verify-before-clean), live forced `grep_search` (denied with plugin reason text), `tfsearch` without key (exit 2 missing-key guard).
- Key outputs: full pipeline green on plugin paths; legacy per-file installs cleaned; `README.md` publish instructions.
- Follow-up tasks: `~/AGENTS.md` diet; artifacts/memory trim measurement (`/context` before/after); post-compaction verdict — move `--add-dir` out of always-on (personas + rules) into cli-tweaks skill + README + deploy echo, keep rules to invariants only.
