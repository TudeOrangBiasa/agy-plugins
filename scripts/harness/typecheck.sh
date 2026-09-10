#!/usr/bin/env bash
# shellcheck disable=SC2015  # ok/bad always exit 0, so &&/|| chains are if-then-else-safe here.
# typecheck.sh — contract validation (shell repo: no compiler; validate schemas).
set -euo pipefail
root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$root_dir"
fail=0
ok() { echo "[ok] $1"; }
bad() { echo "[fail] $1" >&2; fail=1; }

# hooks.json schema: matcher + PreToolUse + command
if python3 - <<'EOF'
import json, sys
d = json.load(open('plugins/agy-minimal/hooks.json'))
h = d['enforce-custom-search']['PreToolUse'][0]
assert h['matcher'] == 'grep_search|find_by_name', h
assert h['hooks'][0]['command'] == './bin/block-native-search.sh', h
EOF
then
  echo "[ok] hooks.json schema"
else
  fail=1
fi

if python3 - <<'EOF'
import json
d = json.load(open('plugins/agy-minimal/hooks.json'))
h = d['enforce-hasline-edit']['PreToolUse'][0]
assert h['matcher'] == 'write_to_file|replace_file_content', h
assert h['hooks'][0]['command'] == './bin/block-native-edit.sh', h
EOF
then
  echo "[ok] edit hook schema"
else
  fail=1
fi

if python3 - <<'EOF'
import json, re
spec = json.load(open('plugins/agy-minimal/stream-rules.json'))
assert isinstance(spec.get("rules"), list) and spec["rules"], "rules must be a non-empty list"
for r in spec["rules"]:
    for k in ("name", "type", "scope", "enabled", "pattern"):
        assert k in r, (k, r.get("name"))
    assert r["type"] in ("gate", "inject"), r["name"]
    if r["type"] == "gate":
        for k in ("matcher", "reason"):
            assert k in r, (k, r.get("name"))
        assert r.get("decision", "deny") in ("deny", "ask"), r["name"]
    else:
        assert "text" in r, r["name"]
        assert "pre_invocation" in r["scope"], r["name"]
    flags = 0
    for ch in (r.get("flags") or ""):
        flags |= {"i": re.IGNORECASE, "m": re.MULTILINE, "s": re.DOTALL}[ch]
    re.compile(r["pattern"], flags)
    if "matcher" in r:
        re.compile(r["matcher"])
EOF
then
  echo "[ok] stream-rules schema"
else
  fail=1
fi

if python3 - <<'EOF'
import json
d = json.load(open('plugins/agy-minimal/hooks.json'))
h = d['stream-rules']['PreToolUse'][0]
assert h['matcher'] == '*', h
assert h['hooks'][0]['command'] == './bin/stream-gate.sh', h
EOF
then
  echo "[ok] stream-rules hook wiring"
else
  fail=1
fi

if python3 - <<'EOF'
import json
d = json.load(open('plugins/agy-minimal/hooks.json'))
h = d['guidance-inject']['PreInvocation'][0]
assert h['command'] == './bin/guidance-inject.sh', h
EOF
then
  echo "[ok] guidance-inject hook wiring"
else
  fail=1
fi

# agy-minimal.md frontmatter keys (documented fields only; cf. official flutter agent)
for k in 'name: agy-minimal' 'mainAgent: true' 'subagent: false'; do
  grep -qF "$k" plugins/agy-minimal/agents/agy-minimal.md && ok "frontmatter $k" || bad "frontmatter missing: $k"
done
# undocumented skills:/agents: fields must stay out (unload risk for plugin skills)
for a in plugins/agy-minimal/agents/agy-minimal.md plugins/agy-frontend/agents/agy-frontend.md; do
  if grep -Eq '^(skills|agents):' "$a"; then
    bad "undocumented frontmatter present (skills:/agents:) in $a"
  else
    ok "no undocumented frontmatter"
  fi
done
if python3 -c 'import json; assert json.load(open("plugins/agy-frontend/plugin.json")).get("name") == "agy-frontend"'; then
  echo "[ok] frontend manifest"
else
  fail=1
fi
for k in 'name: agy-frontend' 'mainAgent: true' 'subagent: false'; do
  grep -qF "$k" plugins/agy-frontend/agents/agy-frontend.md && ok "frontend $k" || bad "frontend missing: $k"
done
# wrapper contracts: usage text present (wrappers exit 2; neutralize pipefail)
{ plugins/agy-minimal/bin/ffgrep 2>&1 || true; } | grep -q 'usage: ffgrep' && ok "ffgrep usage contract" || bad "ffgrep usage contract"
{ plugins/agy-minimal/bin/fffind 2>&1 || true; } | grep -q 'usage: fffind' && ok "fffind usage contract" || bad "fffind usage contract"
[ "$fail" -ne 0 ] && exit 1
echo "typecheck passed."
