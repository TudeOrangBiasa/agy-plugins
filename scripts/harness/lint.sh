#!/usr/bin/env bash
# shellcheck disable=SC2015  # echo helpers exit 0; &&/|| chains below are if-then-else-safe.
# lint.sh — static checks before tests. Offline.
set -euo pipefail
root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$root_dir"
fail=0

while IFS= read -r f; do
  bash -n "$f" && echo "[ok] bash -n $f" || { echo "[fail] bash -n $f" >&2; fail=1; }
done < <(find scripts plugins/agy-minimal/bin -name '*.sh' -o -name 'ffgrep' -o -name 'fffind' -o -name 'tfsearch' -o -name 'tffetch' -o -name 'agy-doctor' -o -name 'block-native-*.sh' | grep -v '/hasline$' | sort -u)

for j in plugins/agy-minimal/hooks.json plugins/agy-minimal/plugin.json plugins/agy-minimal/mcp_config.json plugins/agy-frontend/plugin.json; do
  if command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool "$j" >/dev/null && echo "[ok] json $j" || { echo "[fail] json $j" >&2; fail=1; }
  elif command -v jq >/dev/null 2>&1; then
    jq empty "$j" && echo "[ok] json $j" || { echo "[fail] json $j" >&2; fail=1; }
  fi
done

python3 -m py_compile plugins/agy-minimal/bin/hasline && echo "[ok] py_compile hasline" || { echo "[fail] py_compile hasline" >&2; fail=1; }

if command -v shellcheck >/dev/null 2>&1; then
  SC="shellcheck"
elif command -v nix >/dev/null 2>&1; then
  SC="nix run nixpkgs#shellcheck --"
else
  SC=""
fi
if [ -n "$SC" ]; then
  $SC plugins/agy-minimal/bin/ffgrep plugins/agy-minimal/bin/fffind plugins/agy-minimal/bin/tfsearch plugins/agy-minimal/bin/tffetch plugins/agy-minimal/bin/agy-doctor plugins/agy-minimal/bin/block-native-search.sh plugins/agy-minimal/bin/block-native-edit.sh plugins/agy-minimal/bin/block-bash-bypass.sh plugins/agy-minimal/bin/stream-gate.sh plugins/agy-minimal/bin/guidance-inject.sh scripts/deploy-global.sh scripts/harness/*.sh scripts/audit_harness.sh \
    && echo "[ok] shellcheck" || { echo "[fail] shellcheck" >&2; fail=1; }
else
  echo "[skip] shellcheck not installed (nix profile install nixpkgs#shellcheck)"
fi

# no trailing whitespace in agent/config markdown
if find plugins AGENTS.md PLANS.md docs -name '*.md' -exec grep -l ' $' {} + 2>/dev/null | grep -q .; then
  echo "[fail] trailing whitespace" >&2; fail=1
else
  echo "[ok] no trailing whitespace"
fi

[ "$fail" -ne 0 ] && exit 1
echo "lint passed."
