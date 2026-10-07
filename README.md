# agy-minimal

Portable pi-agent-like harness plugin for the Antigravity CLI (`agy`).
Base (`agy-minimal`): minimal tools + discipline (fast `ffgrep`/`fffind` search wrappers,
anchored `hasline` edits, deny-hooks for native tools, lazy TinyFish web
tools) — installed, stock `agy` runs general-purpose with no flags.

## Install (any device)

```bash
git clone <this-repo> && cd <this-repo>
./scripts/deploy-global.sh
```

This copies `plugins/agy-minimal/` to `~/.gemini/config/plugins/`
(validating first), then verifies `agy plugin list` shows it.
Re-run to repair. Options: `--dry-run` prints what would change and writes
nothing; `--link-bin` also symlinks user-facing wrappers into
`$HOME/.local/bin` (off by default).

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
plugins/agy-minimal/       # deploy artifact: tool surface (deny-hooks + wrappers)
├── plugin.json            # manifest
├── hooks.json             # deny grep_search|find_by_name, write_to_file|replace_file_content
├── rules/AGENTS.md        # portable overrides (travel with the plugin)
├── skills/ff-search/      # ffgrep/fffind runbook
├── skills/hasline-edit/   # anchored-edit runbook
├── skills/context-files/  # workspace context-file slots + aliases
├── skills/tf-web/         # tfsearch/tffetch runbook
├── skills/…               # + cli-tweaks, ts-review, stream-rules, lazy-senior
├── bin/                   # ffgrep fffind hasline agy-doctor tfsearch tffetch stream-gate guidance-inject block-*.sh
└── mcp_config.json        # TinyFish MCP server (lazy; REST key via `TINYFISH_API_KEY`)
```

```text
repo root                  # dev checkout (deploy ships only plugins/agy-minimal/)
├── AGENTS.md GLOSSARY.md PLANS.md
├── skills/                # agystack framework: poteto-mode + playbooks, agystack/ (hooks.json.example), …
├── rules/AGENTS.md        # workspace dev discipline (subagent delegation); + agystack-models.md
├── agents/                # poteto-agent, comment-sicko
├── tests/ + pyproject.toml
├── docs/                  # ARCHITECTURE, OBSERVABILITY, adr/, guide/, agents/
├── Makefile(.harness) + scripts/harness/* + scripts/deploy-global.sh
└── .scratch/ (gitignored runtime)
```

## Verify

```bash
make ci      # smoke + lint + typecheck + test, offline
make test-py # pytest workflow suite (upstream agystack), offline
make lint-py # ruff on Python
make ci-py   # full stack: harness ci + test-py + lint-py
```

## TinyFish auth

`tfsearch`/`tffetch` call the TinyFish REST API with `TINYFISH_API_KEY` in env
(never committed; get a key at agent.tinyfish.ai/api-keys). No OAuth, no wallet
for REST. MCP discovery (`agy mcp list`) is a different layer and may need
OAuth first — see `scripts/deploy-global.sh`.


## Decisions

See `PLANS.md` decision log — every structural choice has a live-proven reason.
