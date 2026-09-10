#!/usr/bin/env bash
# deploy-global.sh — install agy plugins into agy global config.
# Each plugins/<name>/ dir is the single source of truth; the global install
# under ~/.gemini/config/plugins/ is the target. Idempotent: safe to re-run.
# Validates with `agy plugin validate` before copying (agy-hud parity); fail-fast, never overwrites a good install with invalid source.
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
global_plugins="$HOME/.gemini/config/plugins"
global_agents="$HOME/.gemini/config/agents"
global_hooks="$HOME/.gemini/config/hooks.json"

install_plugin() {
  local name="${1:?plugin name required}"
  : "${root_dir:?}" "${global_plugins:?}"
  local src="$root_dir/plugins/$name"
  [ -f "$src/plugin.json" ] || { echo "plugin source missing: $src" >&2; return 1; }
  if command -v agy >/dev/null 2>&1 && ! agy plugin validate "$src" >&2; then
    echo "plugin invalid: $src (agy plugin validate failed)" >&2; return 1
  fi
  mkdir -p "$global_plugins"
  rm -rf "${global_plugins:?}/${name:?}"
  cp -r "$src" "$global_plugins/$name"
  rm -rf "${global_plugins:?}/${name:?}/bin/__pycache__"
  if [ -d "$global_plugins/$name/bin" ]; then
    chmod +x "$global_plugins/$name/bin/"* 2>/dev/null || true
  fi
  echo "[install] $global_plugins/$name"
}

install_plugin agy-minimal
install_plugin agy-frontend

plugin_ok=0
if command -v agy >/dev/null 2>&1; then
  if agy agents 2>/dev/null | grep -q "^agy-minimal$"; then
    echo "[ok] agy agents lists agy-minimal (via plugin)"
  else
    echo "[warn] agy agents does not list agy-minimal via plugin" >&2
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

if [ "$plugin_ok" -eq 1 ]; then
  rm -f "$global_agents/agy-minimal.md" && echo "[clean] legacy $global_agents/agy-minimal.md"
  if [ -f "$global_hooks" ]; then
    python3 - "$global_hooks" <<'EOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    glob = json.load(f)
for key in ("enforce-custom-search", "enforce-hasline-edit"):
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
else
  echo "[hold] legacy installs kept until plugin discovery is proven"
fi

echo "deploy complete."
