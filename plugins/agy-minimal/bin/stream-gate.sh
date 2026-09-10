#!/usr/bin/env bash
# stream-gate.sh — TTSR-style named gate rules for agy (PreToolUse).
# Reads ../stream-rules.json (STREAM_RULES env overrides the path, for tests).
# Enabled gate rules apply in file order against the toolCall name +
# serialized args; first match denies, otherwise allow. Fail-open on bad
# payload, missing file, or broken rule — mirroring TTSR's skip-broken rule.
# Non-goals (gating only): free-text redact/replace, session time-travel.
# Model-context inject lives in guidance-inject.sh (PreInvocation).
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
rules_file="${STREAM_RULES:-$here/../stream-rules.json}"

payload=""
if [ ! -t 0 ]; then
  payload=$(cat 2>/dev/null || true)
fi

result=$(python3 - "$payload" "$rules_file" <<'PYEOF' 2>/dev/null
import json, re, sys
raw, path = sys.argv[1], sys.argv[2]
try:
    data = json.loads(raw) if raw.strip() else {}
except Exception:
    print("allow")
    sys.exit(0)
try:
    with open(path) as f:
        spec = json.load(f)
except Exception:
    print("allow")
    sys.exit(0)
call = data.get("toolCall") or {}
tname = call.get("name", "") or ""
args = call.get("args") or {}
blob = json.dumps(args, sort_keys=True, default=str)
def leaves(o):
    if isinstance(o, str):
        yield o
    elif isinstance(o, dict):
        for v in o.values():
            yield from leaves(v)
    elif isinstance(o, list):
        for v in o:
            yield from leaves(v)
def strip_prose(s):
    s = re.sub(r"<<-?\s*['\"]?(\w+)['\"]?[^\n]*\n.*?^\1\s*$", " ", s, flags=re.DOTALL | re.MULTILINE)
    s = re.sub(r"'[^']*'", " ", s)
    s = re.sub(r'"(?:[^"\\]|\\.)*"', " ", s)
    return s
stripped = strip_prose("\n".join(leaves(args)))
rules = spec.get("rules") if isinstance(spec, dict) else None
if not isinstance(rules, list):
    print("allow")
    sys.exit(0)
flagmap = {"i": re.IGNORECASE, "m": re.MULTILINE, "s": re.DOTALL}
for r in rules:
    try:
        if not isinstance(r, dict):
            continue
        if r.get("type") != "gate":
            continue
        if r.get("enabled") is False:
            continue
        if "pre_tool_use" not in (r.get("scope") or []):
            continue
        matcher, pattern = r.get("matcher", ""), r.get("pattern", "")
        if not matcher or not pattern:
            continue
        if not re.search(matcher, tname):
            continue
        fl = 0
        for ch in (r.get("flags") or ""):
            fl |= flagmap.get(ch, 0)
        hay = stripped if r.get("strip_prose") else blob
        if not re.search(pattern, hay, fl):
            continue
        name = r.get("name", "unnamed")
        dec = r.get("decision", "deny")
        if dec not in ("deny", "ask"):
            continue
        reason = r.get("reason") or ("Blocked by stream rule '%s'." % name)
        print(dec + "|" + json.dumps(reason))
        break
    except Exception:
        continue
else:
    print("allow")
PYEOF
) || result="allow"

case "$result" in
  deny\|*|ask\|*)
    dec="${result%%|*}"
    reason="${result#*|}"
    printf '{"decision":"%s","reason":%s}\n' "$dec" "$reason"
    ;;
  *)
    echo "{}"
    ;;
esac
exit 0
