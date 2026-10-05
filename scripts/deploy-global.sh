#!/usr/bin/env bash
# deploy-global.sh — install agy plugins into agy global config.
# Each plugins/<name>/ dir is the single source of truth; the global install
# under ~/.gemini/config/plugins/ is the target. Idempotent: safe to re-run.
# Validates with `agy plugin validate` before copying (agy-hud parity); fail-fast, never overwrites a good install with invalid source.
set -euo pipefail

# --dry-run prints what would change and writes nothing.
# --link-bin opts into $HOME/.local/bin wrapper symlinks (off by default;
# PATH target is user-owned, needs explicit confirm per rules/AGENTS.md:5).
DRY_RUN=0
LINK_BIN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --link-bin) LINK_BIN=1 ;;
  esac
done

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
  # Portable source uses $HOME-anchored hook commands (repo stays
  # machine-independent); expand to the literal absolute install path at
  # deploy time — the hook runner is not proven to expand env vars, and
  # relative ./bin/ resolves nowhere (hook cwd = session launch dir).
  if [ -f "${global_plugins:?}/${name:?}/hooks.json" ]; then
    HOOK_SRC="${global_plugins:?}/${name:?}/hooks.json" python3 - <<'EOF'
import json, os
path = os.environ["HOOK_SRC"]
home = os.environ["HOME"]
with open(path) as f:
    d = json.load(f)
def walk(o):
    if isinstance(o, dict):
        for k, v in o.items():
            if k == "command" and isinstance(v, str) and v.startswith("$HOME/"):
                o[k] = home + v[len("$HOME"):]
            else:
                walk(v)
    elif isinstance(o, list):
        for v in o:
            walk(v)
walk(d)
with open(path, "w") as f:
    json.dump(d, f, indent=2)
    f.write("\n")
EOF
    echo "[expand] $name/hooks.json \$HOME -> $HOME"
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
}

# Link user-facing wrappers onto PATH (spawn-anywhere): symlinks in
# $HOME/.local/bin (where `agy` lives) -> global plugin bin. Internal
# hooks (*.sh) stay unlinked; derived from bins.list so new wrappers
# auto-link. LINK_BIN_DIR overrides the target for tests.
link_wrappers() {
  local dest="${LINK_BIN_DIR:-$HOME/.local/bin}"
  local src_bin="$global_plugins/agy-minimal/bin"
  local list="$root_dir/plugins/agy-minimal/bins.list"
  [ -f "$list" ] || return 0
  if [ "$DRY_RUN" -eq 1 ]; then
    local b
    while IFS= read -r b || [ -n "${b:-}" ]; do
      [ -n "${b:-}" ] || continue
      case "$b" in
        *.sh|lib-*) continue ;;
      esac
      echo "[dry-run] would link $dest/$b -> $src_bin/$b"
    done < "$list"
    return 0
  fi
  mkdir -p "$dest"
  local b
  while IFS= read -r b || [ -n "${b:-}" ]; do
    [ -n "${b:-}" ] || continue
    case "$b" in
      *.sh|lib-*) continue ;;
    esac
    ln -sf "$src_bin/$b" "$dest/$b" \
      && echo "[link] $dest/$b" \
      || echo "[warn] link failed: $dest/$b" >&2
  done < "$list"
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
      agy-minimal|agy-hud) continue ;;
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

if [ "$LINK_BIN" -eq 1 ]; then
  link_wrappers
else
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] wrapper symlinks skipped (pass --link-bin to preview links)"
  else
    echo "[skip] wrapper symlinks not linked (pass --link-bin to enable)"
  fi
fi

sweep_stale_plugins

plugin_ok=0
if command -v agy >/dev/null 2>&1; then
  if agy plugin list 2>/dev/null | grep -q "agy-minimal"; then
    echo "[ok] agy plugin lists agy-minimal"
    plugin_ok=1
  else
    echo "[warn] agy plugin does not list agy-minimal" >&2
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
