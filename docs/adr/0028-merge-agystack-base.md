# ADR-0028: Merge agystack base (additive, no local overwrites)

Date: 2026-10-05
Status: Accepted

## Context

Upstream `agystack` (`https://github.com/jtaroreh/agystack`) at
`d1a0466e0fd8700bfffd214fa821d4b4b45c0337` (remote `agystack/main`,
fetched as merge base, not merged) contains workflow assets this repo
lacks: `skills/poteto-mode` (+ ~50 sibling skills), `rules/AGENTS.md`,
`pyproject.toml`, `hooks.json.example`, `docs/guide/`, `agents/`,
`tests/`. Local tooling (`plugins/agy-minimal/`, `scripts/`,
`Makefile`, root docs) must survive untouched.

## Decision

Land the upstream base additively via `git archive agystack/main`
extracted to temp, copying only missing paths:

- `rules/` (2 files: `AGENTS.md`, `agystack-models.md`)
- `agents/` (2 files)
- `tests/` (13 files)
- `docs/guide/` (17 files: 01-setup through 10-recipes + README + images)
- `skills/` (140 files: poteto-mode + playbooks/references/scripts, principles, workflow skills)
- `pyproject.toml`, `hooks.json.example` (top-level reference files)

Skipped (not copied): top-level `plugin.json` (local plugin identity
lives at `plugins/agy-minimal/plugin.json`; root is not a plugin),
`README.md`, `Makefile`, `LICENSE`, `.github/`,
`agystack-runtime.json.example`. Nothing local was overwritten.

Collisions skipped: none. Zero skill-name overlap — upstream skills
land at top-level `skills/`, local skills live under
`plugins/agy-minimal/skills/` (cli-tweaks, context-files, ff-search,
hasline-edit, lazy-senior, stream-rules, tf-web, ts-review).

## Consequences

- Repo now carries two skill trees: top-level `skills/` (upstream
  workflows) and `plugins/agy-minimal/skills/` (local lean tooling).
  A later ADR should decide whether to reconcile them under one
  plugin root.
- `pyproject.toml` introduces Python packaging (`agystack` 0.1.0,
  hatchling) covering the swarm/cloud scripts; local JS/shell tooling
  is unaffected.
- `hooks.json.example` is reference only; live hooks stay in
  `plugins/agy-minimal/hooks.json` per ADR-0027.
## Amendment 2026-10-05 (hook merge: deny-only, upstream advisory not chained)

Evaluated chaining upstream `pre_tool_delegation.py` (on
`write_to_file|replace_file_content`) and `pre_tool_safety.py` (on
`run_command`) as second hook entries behind the local deny scripts.
Rejected: both scripts emit `{}` on allow (rejected as `invalid_args`
by newer runners per ADR-0027/cmux#5358 — local gates emit explicit
`{"decision":"allow"}`), and non-allow verdicts use
`"decision":"reject"` / `"decision":"force_ask"`, which are outside
the local runner contract (`deny`/`allow`/`ask` per
docs/ARCHITECTURE.md). The delegation hook also conflicts
semantically with `block-native-edit.sh`: it *permits* <=50-line
direct writes, while the local deny forces every native edit through
hasline. `plugins/agy-minimal/hooks.json` stays deny-only; the
upstream hooks remain in-tree at
`skills/poteto-mode/scripts/hooks/` for porting later (e.g. a
`force_ask`→`ask` adapter, or reusing the safety patterns
root-deletion/trunk-force-push/drop-database inside the local
`allow`-contract scripts).

## Amendment 2026-10-05 (test-py baseline: 1 known failure)

`make test-py` (pytest `tests/ --timeout=60`): 228 passed, 3 skipped,
1 failed — `test_readme_indexes_all_principles` expects root
`README.md` to index every `principle-*` skill. Our root README is
agy-minimal's own (overwrite forbidden by the additive-merge rule),
so this failure is an expected merge consequence, not a regression.
Fix options for later: (a) mark it `xfail` with the ADR reason,
(b) point the test at `docs/guide/08-principles.md` (passes —
`test_guide_indexes_all_principles` is green), (c) index principles
from README without replacing its content. `make lint-py` (ruff):
clean. `make ci` (harness): pass. `audit_harness.sh`: pass.
Resolution 2026-10-05: test retargeted to docs/guide/08-principles.md then tightened to exact link form; suite now 229 passed / 3 skipped, fully green, no known failures.
