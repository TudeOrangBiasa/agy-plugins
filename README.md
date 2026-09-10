# agy-minimal

Portable pi-agent-like harness plugins for the Antigravity CLI (`agy`).
Core (`agy-minimal`): one lean agent, fast `fff` search binaries, anchored
`hasline` edits, deny-hooks for native tools, lazy TinyFish web tools —
installed, stock `agy` is fast, minimal, and efficient with no flags.
Extension (`agy-frontend`): taste layer for design/frontend work — `better-*`
principles, `design-taste` identity doctrine, on-demand `checklist-design` audits.

## Install (any device)

```bash
git clone <this-repo> && cd <this-repo>
./scripts/deploy-global.sh
```

This copies `plugins/agy-minimal/` and `plugins/agy-frontend/` to
`~/.gemini/config/plugins/` (validating first), then verifies `agy agents`
lists both. Re-run to repair.

## Use

Just run `agy` inside your project — both plugins load by default
(tool guards, rules, skills; no flags needed). Name a persona only to
steer the voice:

```bash
agy --agent agy-minimal    # lean code session
agy --agent agy-frontend   # design/frontend session
```

Attach an extra workspace dir: add `--add-dir <path>` to any of the above.

Non-interactive is read-only (no `run_command` in `-p`); the agent emits
copy-paste commands instead.

Web (token-cheap, free): `tfsearch <query>`, `tffetch <url>...` — needs
`TINYFISH_API_KEY` in env, never committed.

## Layout

```text
plugins/agy-minimal/       # core: tool surface (deny-hooks + wrappers)
├── plugin.json            # manifest
├── agents/agy-minimal.md  # lean persona (no pleasantries, no artifacts)
├── hooks.json             # deny grep_search|find_by_name, write_to_file|replace_file_content
├── rules/AGENTS.md        # portable overrides (travel with the plugin)
├── skills/ff-search/      # ffgrep/fffind runbook
├── skills/hasline-edit/   # anchored-edit runbook
├── skills/context-files/  # workspace context-file slots + aliases
├── skills/tf-web/         # tfsearch/tffetch runbook
├── skills/…               # + cli-tweaks, ts-review, stream-rules, lazy-senior
├── bin/                   # ffgrep fffind hasline agy-doctor tfsearch tffetch stream-gate guidance-inject block-*.sh
└── mcp_config.json        # TinyFish search/fetch (lazy; one-time OAuth)
plugins/agy-frontend/      # extension: taste layer (needs the core)
├── plugin.json            # manifest
├── agents/agy-frontend.md # frontend persona
├── rules/AGENTS.md        # scope + requires-minimal + design routing
├── skills/better-*/       # UI principles (condensed ports, MIT)
├── skills/design-taste/   # DESIGN.md identity doctrine (Apache 2.0)
└── skills/checklist-design/ # 129 bundled verification checklists (MIT)
```

Repo root holds dev harness only: `AGENTS.md`, `CONTEXT.md`, `PLANS.md`, `docs/`
(ARCHITECTURE, OBSERVABILITY, `adr/`), `Makefile.harness`, `scripts/harness/*`,
`scripts/deploy-global.sh`.

## Verify

```bash
make ci   # smoke + lint + typecheck + test, offline
```

## TinyFish auth

First MCP use opens a browser OAuth flow (TinyFish account required).
Search + Fetch are free; Agent/Browser draw from wallet.

## Attribution

Taste/verification knowledge is vendored, not written here:

- `better-*` condense [jakubkrehel/skills](https://github.com/jakubkrehel/skills) (MIT) — principles only, full texts upstream.
- `checklist-design` adapts [checklist-design/skills](https://github.com/checklist-design/skills) @`5de6e83` (MIT) — mode discipline verbatim, all 129 checklists bundled.
- `design-taste` follows [google-labs-code/design.md](https://github.com/google-labs-code/design.md) (Apache 2.0) — doctrine verbatim, spec/examples upstream.

See `plugins/agy-frontend/ATTRIBUTION.md` for per-file detail.


## Decisions

See `PLANS.md` decision log — every structural choice has a live-proven reason.
