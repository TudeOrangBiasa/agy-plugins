# PLANS.md — agy-minimal/wrasse

## Objective

- Outcome: portable agy plugin harness — core `agy-minimal` (pi-agent-like minimal: one lean agent, fff search binaries, hashline editor, deny hooks, lazy TinyFish web tools; installed stock agy is fast/minimal/efficient) + extension `agy-frontend` (taste layer: better-* principles, design-taste identity, checklist-design verification). Install = deploy both `plugins/*/` (community-ready).
- Why it matters: every active skill/plugin/MCP schema is injected into the system prompt each turn; native search/edit tools duplicate what `rg`/`fd`/anchored edits do cheaper. Artifacts act as memory (bloat/slowness suspect) → agent is told not to create them unless asked.
- Non-goals: unregistering core tools at binary level (unsupported); global `~/.gemini` hand-edits (deploy script owns installs); `~/AGENTS.md` diet (user's file, out of scope).

## Constraints

- Runtime/tooling constraints: `agy` 1.1.27, `bash`, `rg`, `fd`, `python3` present; `ffgrep`/`fffind`/`hasline` vendored in plugin `bin/`; TinyFish MCP needs one-time OAuth.
- Security/compliance constraints: hooks deny with reason, no silent fallback; no secrets in logs.
- Performance/reliability constraints: smoke < 30s; no network in smoke/check.

## Context Snapshot

- Relevant files/modules: `plugins/agy-minimal/` (`plugin.json`, `agents/`, `hooks.json`, `rules/`, `skills/`, `bin/`, `stream-rules.json`, `mcp_config.json`), `plugins/agy-frontend/skills/checklist-design/` (`SKILL.md` + `references/` with 129 checklists bundled), `AGENTS.md`, `docs/ARCHITECTURE.md`, `docs/OBSERVABILITY.md`, `docs/adr/`, `scripts/harness/*.sh`, `scripts/audit_harness.sh`, `scripts/deploy-global.sh`.
- Existing commands/workflows: `make smoke|check|test|ci` via `Makefile.harness`; audit via `./scripts/audit_harness.sh .` (vendored, also a CI job).
- Known risks: core tools can't be unregistered, only denied; `agy plugin disable`/`agy mcp disable` affect global config, applied manually not in scripts.

## Execution Plan

1. Step: Baseline + bootstrap
   - Expected output: harness files present, `audit_harness.sh` PASS.
   - Verification: audit output + `git status --short`.
2. Step: Minimal agent + tool overrides
   - Expected output: `agy-minimal.md` loads via `agy --agent agy-minimal`; native search denied; `ffgrep`/`fffind` return expected hits.
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

## Decision Log

Decisions live in `docs/adr/` (ADR-0001–ADR-0024, short-form: Context → Decision → Consequences). Do not duplicate them here; append a new ADR per structural choice.

## Final Verification

- Commands run: `make ci` (exit 0), `audit_harness.sh` (PASS), `scripts/deploy-global.sh` (exit 0, verify-before-clean), live `agy agents` (lists `agy-minimal` via plugin alone), live forced `grep_search` (denied with plugin reason text), `agy mcp list` (tinyfish pending OAuth).
- Key outputs: full pipeline green on plugin paths; legacy per-file installs cleaned; `README.md` publish instructions.
- Follow-up tasks: one-time TinyFish OAuth (`agy mcp` UI); `~/AGENTS.md` diet; artifacts/memory trim measurement (`/context` before/after); post-compaction verdict — move `--add-dir` out of always-on (personas + rules) into cli-tweaks skill + README + deploy echo, keep rules to invariants only.
