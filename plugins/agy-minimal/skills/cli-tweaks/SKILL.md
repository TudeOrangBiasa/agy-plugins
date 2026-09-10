---
name: cli-tweaks
description: Diagnose and apply agy CLI tweaks (settings, hooks, plugin enablement). Use when CLI behavior looks wrong, when changing model/statusline/trustedWorkspaces, or when verifying the agy-minimal install on a new machine.
---

# cli-tweaks

What the plugin CAN vs CANNOT tweak. Plugin bundles travel;
global `~/.gemini` files do not — those need a manual/script step.

## Can (travels with this plugin)

- `agents/` + `rules/AGENTS.md` — invocation defaults (`--add-dir` in rules, read-only `-p` in persona).
- `hooks.json` — deny guards (search/edit).
- `skills/*` — runbooks, including this one.
- `mcp_config.json` — lazy MCP servers.
- `bin/*` — deterministic wrappers + `agy-doctor`.

## Cannot (global-only, manual step)

| Tweak | File | Note |
|---|---|---|
| model, agentMode, colorScheme | `~/.gemini/antigravity-cli/settings.json` | user-owned; never mutated silently |
| statusLine HUD | `settings.json` → points at `agy-hud` script | plugin provides script, settings points at it |
| trustedWorkspaces, permissions | `settings.json` | user-owned |
| global hooks (e.g. orca-status) | `~/.gemini/config/hooks.json` | exactly 1 file loads; merges are manual |
| plugin on/off | `~/.gemini/config/config.json` via `agy plugin enable|disable` | wins over `plugin.json` declaration |

## Steps

1. Diagnose: `agy-doctor` via `run_command` (repo checks must pass; global gaps are `[warn]`).
2. Fix repo gaps: edit files in `plugins/agy-minimal/` (source of truth).
3. Fix global gaps: `./scripts/deploy-global.sh` (plugin copy) + manual
   `settings.json` edit for model/statusline/trust (user confirms first).
4. Pass `--add-dir "$PWD"` when the workspace has `.agents/` customizations
   (workspace hooks load only then; the installed global plugin needs no flags — deny-observed without them).

## Verify

- `agy-doctor` exit 0 in repo; `make ci` green; `agy agents` lists `agy-minimal`.
