#!/usr/bin/env bash
# shellcheck disable=SC2015  # ok/bad always exit 0, so A && ok || bad is if-then-else-safe here.
# smoke.sh — fast sanity for agy-minimal (<30s, offline, no network).
set -euo pipefail
root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$root_dir"
PBIN="plugins/agy-minimal/bin"
fail=0
ok() { echo "[ok] $1"; }
bad() { echo "[fail] $1" >&2; fail=1; }

[ -f AGENTS.md ] && ok "AGENTS.md present" || bad "AGENTS.md missing"
[ ! -f plugins/agy-minimal/agents/agy-minimal.md ] && ok "single persona (no minimal split)" || bad "split persona still present"
[ -f plugins/agy-minimal/plugin.json ] && ok "plugin manifest present" || bad "plugin manifest missing"
bins_list="$root_dir/plugins/agy-minimal/bins.list"
if [ -f "$bins_list" ]; then
  while IFS= read -r b || [ -n "${b:-}" ]; do
    [ -n "${b:-}" ] || continue
    case "$b" in
      fffind) [ -x "$PBIN/$b" ] && ok "fffind executable" || bad "fffind not executable" ;;
      tfsearch) [ -x "$PBIN/$b" ] && ok "tfsearch executable" || bad "tfsearch not executable" ;;
      tffetch) [ -x "$PBIN/$b" ] && ok "tffetch executable" || bad "tffetch not executable" ;;
      ffgrep) [ -x "$PBIN/$b" ] && ok "ffgrep executable" || bad "ffgrep not executable" ;;
      hasline) [ -x "$PBIN/$b" ] && ok "hasline executable" || bad "hasline not executable" ;;
      block-native-search.sh) [ -x "$PBIN/$b" ] && ok "block hook executable" || bad "block hook not executable" ;;
      block-native-edit.sh) [ -x "$PBIN/$b" ] && ok "block edit hook executable" || bad "block edit hook not executable" ;;
      agy-doctor) [ -x "$PBIN/$b" ] && ok "agy-doctor executable" || bad "agy-doctor not executable" ;;
      block-bash-bypass.sh) [ -x "$PBIN/$b" ] && ok "bypass hook executable" || bad "bypass hook not executable" ;;
      stream-gate.sh) [ -x "$PBIN/$b" ] && ok "stream gate executable" || bad "stream gate not executable" ;;
      guidance-inject.sh) [ -x "$PBIN/$b" ] && ok "guidance inject executable" || bad "guidance inject not executable" ;;
      *) [ -x "$PBIN/$b" ] && ok "$b executable" || bad "$b not executable" ;;
    esac
  done < "$bins_list"
fi
[ -f plugins/agy-minimal/mcp_config.json ] && ok "plugin mcp present" || bad "plugin mcp missing"
[ -f plugins/agy-minimal/skills/cli-tweaks/SKILL.md ] && ok "cli-tweaks skill present" || bad "cli-tweaks skill missing"
[ -f plugins/agy-minimal/skills/context-files/SKILL.md ] && ok "context-files skill present" || bad "context-files skill missing"
[ -f plugins/agy-frontend/skills/design-taste/SKILL.md ] && ok "design-taste skill present" || bad "design-taste skill missing"
[ -f plugins/agy-frontend/skills/design-taste/references/philosophy.md ] && ok "design-taste doctrine present" || bad "design-taste doctrine missing"
[ -f plugins/agy-minimal/stream-rules.json ] && ok "stream rules present" || bad "stream rules missing"
[ -x scripts/harness/ci.sh ] && ok "ci wrapper executable" || bad "ci wrapper not executable"
[ -f plugins/agy-minimal/skills/ts-review/SKILL.md ] && ok "ts-review skill present" || bad "ts-review skill missing"
[ -f plugins/agy-frontend/plugin.json ] && ok "frontend manifest present" || bad "frontend manifest missing"
[ -f plugins/agy-frontend/agents/agy-frontend.md ] && ok "frontend agent present" || bad "frontend agent missing"
[ -f plugins/agy-frontend/ATTRIBUTION.md ] && ok "frontend attribution present" || bad "frontend attribution missing"
for s in better-interface better-ui better-typography better-colors better-accessibility better-layout better-writing checklist-design; do
  [ -f "plugins/agy-frontend/skills/$s/SKILL.md" ] && ok "frontend skill $s" || bad "frontend skill $s missing"
done
[ -f plugins/agy-frontend/skills/checklist-design/references/index.md ] && ok "checklist bundle index present" || bad "checklist bundle index missing"
[ -f plugins/agy-frontend/skills/checklist-design/references/checklists/web-app-login.md ] && ok "checklist bundle sample present" || bad "checklist bundle sample missing"
[ -x scripts/audit_harness.sh ] && ok "audit script executable" || bad "audit script not executable"

grep -q "Tooling Overrides" AGENTS.md && ok "AGENTS tool overrides" || bad "AGENTS tool overrides missing"
grep -q "Harness Commands" AGENTS.md && ok "AGENTS harness commands" || bad "AGENTS harness commands missing"
grep -q "Execution Plans" AGENTS.md && ok "AGENTS execution plans" || bad "AGENTS execution plans missing"

echo "smoke-test-string" > /tmp/agy_smoke_probe.txt
"$PBIN/ffgrep" "smoke-test-string" /tmp/agy_smoke_probe.txt >/dev/null 2>&1 \
  && ok "ffgrep runs" || bad "ffgrep failed"
rm -f /tmp/agy_smoke_probe.txt

echo "$?" | grep -q . && ok "pipeline alive" || bad "pipeline broken"

if [ "$fail" -ne 0 ]; then echo "smoke FAILED" >&2; exit 1; fi
echo "smoke passed."
