# agy-minimal

Portable pi-agent-like harness plugins for the Antigravity CLI (`agy`).
Base (`agy-minimal`): minimal tools + discipline (fast `fff` search binaries,
anchored `hasline` edits, deny-hooks for native tools, lazy TinyFish web
tools) — installed, stock `agy` runs general-purpose with no flags.

## Install (any device)

```bash
git clone <this-repo> && cd <this-repo>
./scripts/deploy-global.sh
```

This copies `plugins/agy-minimal/` to `~/.gemini/config/plugins/`
(validating first), then verifies `agy plugin list` shows it.
Re-run to repair.

## Use

Install the plugin, then just run `agy` inside your project — no flags.
Guards, rules, and skills are active by default.

```bash
agy
```

Attach an extra workspace dir: `agy --add-dir <path>`.

Non-interactive is read-only (no `run_command` in `-p`); the agent emits
copy-paste commands instead.

Web (token-cheap, free): `tfsearch <query>`, `tffetch <url>...` — needs
`TINYFISH_API_KEY` in env, never committed.

## Layout

```text
plugins/agy-minimal/       # core: tool surface (deny-hooks + wrappers)
├── plugin.json            # manifest
├── hooks.json             # deny grep_search|find_by_name, write_to_file|replace_file_content
├── rules/AGENTS.md        # portable overrides (travel with the plugin)
├── skills/ff-search/      # ffgrep/fffind runbook
├── skills/hasline-edit/   # anchored-edit runbook
├── skills/context-files/  # workspace context-file slots + aliases
├── skills/tf-web/         # tfsearch/tffetch runbook
├── skills/…               # + cli-tweaks, ts-review, stream-rules, lazy-senior
├── bin/                   # ffgrep fffind hasline agy-doctor tfsearch tffetch stream-gate guidance-inject block-*.sh
└── mcp_config.json        # TinyFish search/fetch (lazy; one-time OAuth)
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


## Decisions

See `PLANS.md` decision log — every structural choice has a live-proven reason.
