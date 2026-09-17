#!/usr/bin/env bash
# deploy-global.sh — install agy plugins into agy global config.
# Each plugins/<name>/ dir is the single source of truth; the global install
# under ~/.gemini/config/plugins/ is the target. Idempotent: safe to re-run.
# Validates with `agy plugin validate` before copying (agy-hud parity); fail-fast, never overwrites a good install with invalid source.
set -euo pipefail

# --dry-run prints what would change and writes nothing.
DRY_RUN=0
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=1
fi

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
global_plugins="$HOME/.gemini/config/plugins"
global_agents="$HOME/.gemini/config/agents"
global_hooks="$HOME/.gemini/config/hooks.json"

# Legacy names, listed once here and shared by both the report (--dry-run)
# and clean paths below.
LEGACY_AGENT_FILE="agy-minimal.md"
LEGACY_HOOK_KEYS="enforce-custom-search enforce-hasline-edit"

install_plugin() {
  local name="${1:?plugin name required}"
  : "${root_dir:?}" "${global_plugins:?}"
  local src="$root_dir/plugins/$name"
  [ -f "$src/plugin.json" ] || { echo "plugin source missing: $src" >&2; return 1; }
  if command -v agy >/dev/null 2>&1 && ! agy plugin validate "$src" >&2; then
    echo "plugin invalid: $src (agy plugin validate failed)" >&2; return 1
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] would install $global_plugins/$name (from $src)"
    return 0
  fi
  mkdir -p "$global_plugins"
  rm -rf "${global_plugins:?}/${name:?}"
  cp -r "$src" "$global_plugins/$name"
  rm -rf "${global_plugins:?}/${name:?}/bin/__pycache__"
  if [ -d "$global_plugins/$name/bin" ]; then
    chmod +x "$global_plugins/$name/bin/"* 2>/dev/null || true
  fi
  local b
  if [ -f "$src/bins.list" ]; then
    while IFS= read -r b || [ -n "${b:-}" ]; do
      [ -n "${b:-}" ] || continue
      [ -x "$global_plugins/$name/bin/$b" ] \
        || echo "[warn] installed $name/bin/$b missing or not executable" >&2
    done < "$src/bins.list"
  fi
  echo "[install] $global_plugins/$name"
}

# Installer: validate + copy + exec-bit probe for every bundled plugin.
install_all() {
  install_plugin agy-minimal
  install_plugin agy-frontend
}

# Janitor (part 1): stale sweep (scoped). Drops global `agy-*` plugin dirs
# with no source in this repo (legacy renames in our own namespace only).
# `agy-hud` excluded (third-party statusLine owner). Non-`agy-*` third-party
# entries (flutter, science, ...) never match the glob. Runs before discovery checks.
sweep_stale_plugins() {
  local name
  for d in "$global_plugins"/agy-*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    case "$name" in
      agy-minimal|agy-frontend|agy-hud) continue ;;
    esac
    if [ ! -e "$root_dir/plugins/$name" ]; then
      if [ "$DRY_RUN" -eq 1 ]; then
        echo "[dry-run] would clean stale global plugin $name"
      else
        rm -rf "$d" && echo "[clean] stale global plugin $name"
      fi
    fi
  done
}

# Janitor (part 2): legacy clean, gated on proven plugin discovery.
clean_legacy() {
  local plugin_ok="${1:?plugin_ok required}"
  if [ "$plugin_ok" -eq 1 ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      if [ -e "$global_agents/$LEGACY_AGENT_FILE" ]; then
        echo "[dry-run] would clean legacy $global_agents/$LEGACY_AGENT_FILE"
      else
        echo "[dry-run] legacy $global_agents/$LEGACY_AGENT_FILE already absent"
      fi
      if [ -f "$global_hooks" ]; then
        # shellcheck disable=SC2086
        python3 - "$global_hooks" $LEGACY_HOOK_KEYS <<'EOF'
import json, sys
path = sys.argv[1]
keys = sys.argv[2:]
with open(path) as f:
    glob = json.load(f)
for key in keys:
    if key in glob:
        print(f"[dry-run] would clean legacy global hook {key}")
EOF
      else
        echo "[skip] no global hooks.json, nothing to clean"
      fi
    else
      rm -f "$global_agents/$LEGACY_AGENT_FILE" && echo "[clean] legacy $global_agents/$LEGACY_AGENT_FILE"
      if [ -f "$global_hooks" ]; then
        # shellcheck disable=SC2086
        python3 - "$global_hooks" $LEGACY_HOOK_KEYS <<'EOF'
import json, sys
path = sys.argv[1]
keys = sys.argv[2:]
with open(path) as f:
    glob = json.load(f)
for key in keys:
    if key in glob:
        del glob[key]
        print(f"[clean] legacy global hook {key}")
with open(path, "w") as f:
    json.dump(glob, f, indent=2)
    f.write("\n")
EOF
      else
        echo "[skip] no global hooks.json, nothing to clean"
      fi
    fi
  else
    echo "[hold] legacy installs kept until plugin discovery is proven"
  fi
}

install_all

sweep_stale_plugins

plugin_ok=0
if command -v agy >/dev/null 2>&1; then
  if agy agents 2>/dev/null | grep -q "^agy-minimal$"; then
    echo "[warn] split persona agy-minimal still listed (single persona is agy-frontend)" >&2
  fi
  if agy agents 2>/dev/null | grep -q "^agy-frontend$"; then
    echo "[ok] agy agents lists agy-frontend (via plugin)"
    plugin_ok=1
  else
    echo "[warn] agy agents does not list agy-frontend via plugin" >&2
  fi
  if agy mcp list 2>/dev/null | grep -q "tinyfish"; then
    echo "[ok] tinyfish MCP discovered (via plugin)"
  else
    echo "[warn] tinyfish MCP not listed yet (OAuth may be required first)" >&2
  fi
else
  echo "[skip] agy not on PATH"
fi

clean_legacy "$plugin_ok"

echo "deploy complete."
