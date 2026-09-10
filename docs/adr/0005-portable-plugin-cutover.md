# ADR-0005: Portable plugin cutover

Date: 2026-09-09
Status: Accepted

## Context

`agy agents` lists `agy-minimal` from plugin `agents/` alone (legacy global
copy deleted); forced `grep_search` is denied with the plugin's reason text,
so plugin `hooks.json` executes with cwd = plugin root and `./bin/`
resolves. Plugin hooks are not counted in the log's `loaded N hooks`
line (separate loader) — deny-observed is the proof, not the counter.

## Decision

`plugins/agy-minimal/` is the single source of truth; per-file global
installs removed after plugin proof. Hook commands are `./bin/...`
relative to the plugin root. Install per machine via
`scripts/deploy-global.sh`.

## Consequences

- The bundle is self-contained and community-sharable; no absolute-path
  hack, no `../scripts/` fragility.
- Supersedes the install mechanisms of ADR-0001/0002/0003.
