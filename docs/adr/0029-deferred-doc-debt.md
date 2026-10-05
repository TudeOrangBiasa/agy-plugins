# ADR-0029: Deferred doc debt (items 11–20)

Date: 2026-10-05
Status: Accepted (deferral log)

## Context

Post PR #4 merge (`0c030c3`), ADR-0028 landed the upstream agystack base additively (top-level `skills/`, `rules/`, `agents/`, `tests/`, `docs/guide/`) alongside the local plugin tree (`plugins/agy-minimal/`). A follow-up doc audit surfaced ten known inconsistencies worth recording but not worth blocking the merge: each was read back against its cited file, each has a known fix, and none breaks agents today.

## Decision

Log all ten as deferred debt below, one paragraph each (status + fix + reason for deferral). Fix opportunistically on the next touch of the owning file; do not batch a cleanup PR for these alone.

## Consequences

- Docs knowingly carry the ten warts below until fixed; each item names its fix so any edit can close it without re-investigation.
- No behavior, hook, harness, or test change in this ADR.
- A later ADR may record items 1–10 if an earlier audit logged them; numbering here continues at 11 per the audit ticket.

### (11) Playbook matrix names vs `playbooks/` filenames

Status: live mismatch, harmless. Display labels in `docs/guide/02-poteto-mode.md` ("perf", "bug fix", "opening a pr", "session pickup", …) and `skills/poteto-mode/SKILL.md` ("Perf issue", "Authoring or modifying a skill", "Multi-phase or multi-PR plan", …) do not equal the `skills/poteto-mode/playbooks/` stems they describe (`perf-issue.md`, `authoring-a-skill.md`, `multi-phase-plan.md`, …). Fix: rename matrix labels to exact stems or add an alias map. Deferred because every matrix entry already links the correct file, so click-through lookup still works and no agent breakage has been observed.

### (12) `scratch/` vs `.scratch/`

Status: two upstream-merged lines say undotted `scratch/` — `skills/poteto-mode/SKILL.md:22` and `rules/AGENTS.md:11` ("scratch scripts in `scratch/`") — while repo truth is dotted `.scratch/` (`.gitignore:7`, root `README.md` layout, `docs/agents/issue-tracker.md`, root `AGENTS.md:93`). Fix: edit both lines to the dotted form. Deferred because it is a two-line word fix with zero functional impact; queue it with the next touch of either file.

### (13) Two hook systems unreconciled

Status: decided-but-undocumented. Live authority is the plugin deny system (`plugins/agy-minimal/hooks.json` + `bin/block-*.sh`, `deny`/`allow` contract), while `skills/poteto-mode/scripts/hooks/` (`pre_tool_delegation.py`, `pre_tool_safety.py`, `post_tool_lint.py` — `{}`-on-allow plus `reject`/`force_ask` verdicts outside the local runner contract) sits in-tree advisory and unchained, covered by `tests/test_hooks.py`; the ADR-0028 amendment already records why chaining was rejected. Fix: a short authority doc stating plugin hooks gate and upstream hooks advise (port later via a `force_ask`→`ask` adapter or by reusing safety patterns). Deferred because the amendment captures the rationale and there is no runtime conflict while the upstream hooks stay unwired.

### (14) `-p` flags in ARCHITECTURE:50 appear nowhere else

Status: unverified singleton. `docs/ARCHITECTURE.md:50` names `--disable-slash-commands --effort low` on the `-p` entry path, but a repo-wide grep finds no other occurrence and no harness script or test pins either flag. Fix: verify against `agy` 1.1.27 CLI help — keep if real, delete if invented. Deferred because the entry contract (interactive executes, `-p` is read-only) is understood independently of the exact flags; cosmetic until someone copies the line into a script.

### (15) Three AGENTS.md files with overlapping authority

Status: overlap without precedence. Root `AGENTS.md` (workspace discipline), `rules/AGENTS.md` (upstream subagent-delegation invariant), and `plugins/agy-minimal/rules/AGENTS.md` (portable tool-surface overrides) each issue must-style directives with no statement of which wins a conflict. Fix: one precedence note (e.g. plugin rules travel with the install, root wins in-repo, the upstream invariant governs delegation). Deferred because current readers cope in practice and no contradictory instruction has been reported.

### (16) CONTEXT.md frozen pre-merge

Status: accurate but stale glossary. `CONTEXT.md` defines the pre-merge vocabulary (core, wrapper, deny hook, stream rule, guidance notice) yet has no entries for the ADR-0028 arrivals: `poteto-agent`, playbook, or the delegation invariant. Fix: add the three entries in the existing term/avoid shape. Deferred because every existing entry is still correct; the additions are purely additive glossary work for a later docs touch.

### (17) OBSERVABILITY.md aspirational events and metrics

Status: taxonomy without emitters. `docs/OBSERVABILITY.md` lists agent-side events (`agy.search.run`, `agy.search.deny`, `agy.bypass.deny`, `agy.stream.deny`, `agy.guide.inject`) that nothing emits — `plugins/agy-minimal/bin/` contains zero event emission; only `scripts/harness/ci.sh` emits structured events (`harness.*`) — plus metrics (deny-hit rate, retry count, time-to-first-actionable-error) with no collector. Fix: emit from hooks/wrappers or explicitly mark the agent-side section aspirational. Deferred because the harness pipeline is observable today via `ci.sh` JSON events plus `[ok|fail]` lines; agent telemetry is non-blocking.

### (18) `wrasse` codename unexplained

Status: undefined token in four titles. `AGENTS.md`, `PLANS.md`, `docs/ARCHITECTURE.md`, and `docs/OBSERVABILITY.md` all carry `agy-minimal/wrasse`, yet a repo-wide grep finds no definition of `wrasse` anywhere. Fix: one-line definition or drop it from the titles. Deferred as purely cosmetic with zero functional impact.

### (19) `docs/guide/` has no backlink to root docs or harness

Status: self-contained to a fault. `docs/guide/README.md` teaches the full poteto-mode habit but never links the root `README.md` (install), `docs/ARCHITECTURE.md` (boundaries), or the harness (`Makefile`, `make ci`), so a guide-only reader never learns the install/verify paths. Fix: a short bridge paragraph with those three links. Deferred because the guide serves its audience standalone and the root docs remain discoverable from the repo root.

### (20) `-p` mechanism accounts incompatible

Status: three un-cross-referenced accounts of the same contract. Root `README.md` states a blanket platform rule (no `run_command` in `-p`; agent emits copy-paste), `plugins/agy-minimal/skills/cli-tweaks/SKILL.md` gives the hook version (nested-Orca `orca-status` ask-hook denies what `-p` cannot approve, sometimes surfacing as `failed to execute`), and ADR-0004 gives the toolset-probe version (`run_command` absent and `write_to_file` unregistered in `-p`; hook payloads carry no mode flag). Fix: reconcile into one account with cross-refs — platform toolset absence as the base rule, nested approval-gating as the special case. Deferred because all three agree on the observable contract (never execute in `-p`; emit copy-paste), so the dispute only matters when debugging a `-p` failure.

## Known issue (2026-10-05, post-merge note)

`tests/test_hooks.py` `TestPreToolSafetyHook` bare-force-push cases (7 subtests) pass on `main`/`master` and fail on feature branches by design: `is_trunk_force_push` allows force-push on feature branches, while the tests assume bare force-push is always destructive. Record only — do not fix the hook or the tests here.
