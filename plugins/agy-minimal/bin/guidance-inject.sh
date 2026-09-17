#!/usr/bin/env bash
# guidance-inject.sh — TTSR-style guidance for agy (PreInvocation, flat).
# Scans NEW transcript tool_calls since the last run and injects a compact
# guidance notice (ephemeralMessage) once per rule per conversation — the
# agy-native equivalent of OMP's ttsr-injection (match at tool_call, deliver
# as context, never block). Rules live in ../stream-rules.json with
# type "inject". Fail-open: {} on any problem.
# Interface parameters:
#   transcriptPath — transcript file path, taken from the payload's
#     transcriptPath field (missing/unreadable file → {}).
#   tail-range — one 262144-byte chunk read from the stored offset
#     (offset resets to 0 when the transcript shrank, e.g. rotation);
#     only tool_calls in this window are scanned on a run.
#   state-handle — agy-guidance-<safe-cid>.json under the state dir, where
#     <safe-cid> is conversationId sanitized to [A-Za-z0-9_-] (max 48
#     chars); stores {"offset": <next-byte>, "fired": [<rule names>]} for
#     once-per-conversation dedupe and offset bookkeeping.
# Overrides (unchanged): STREAM_RULES overrides the rules path for tests;
# GUIDANCE_STATE_DIR overrides /tmp state for tests.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
rules_file="${STREAM_RULES:-$here/../stream-rules.json}"
state_dir="${GUIDANCE_STATE_DIR:-/tmp}"

payload=""
if [ ! -t 0 ]; then
  payload=$(cat 2>/dev/null || true)
fi

result=$(python3 - "$payload" "$rules_file" "$state_dir" <<'PYEOF' 2>/dev/null
import json, os, re, sys
# Interface parameters (see header): tail-range window and state-handle name.
TAIL_BYTES = 262144
STATE_PREFIX, STATE_SUFFIX = "agy-guidance-", ".json"
raw, rules_path, state_dir = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    data = json.loads(raw) if raw.strip() else {}
except Exception:
    print("{}")
    sys.exit(0)
cid = data.get("conversationId") or "noconv"
tpath = data.get("transcriptPath", "") or ""
if not tpath or not os.path.isfile(tpath):
    print("{}")
    sys.exit(0)
try:
    with open(rules_path) as f:
        spec = json.load(f)
except Exception:
    print("{}")
    sys.exit(0)
rules = spec.get("rules") if isinstance(spec, dict) else None
if not isinstance(rules, list):
    print("{}")
    sys.exit(0)
flagmap = {"i": re.IGNORECASE, "m": re.MULTILINE, "s": re.DOTALL}
safe = re.sub(r"[^A-Za-z0-9_-]", "_", cid)[:48]
state_path = os.path.join(state_dir, "%s%s%s" % (STATE_PREFIX, safe, STATE_SUFFIX))
try:
    with open(state_path) as f:
        state = json.load(f)
    offset, fired = state.get("offset", 0), set(state.get("fired", []))
except Exception:
    offset, fired = 0, set()
try:
    size = os.path.getsize(tpath)
    if size < offset:
        offset = 0
    with open(tpath, errors="replace") as f:
        f.seek(offset)
        chunk = f.read(TAIL_BYTES)
        new_offset = offset + len(chunk.encode("utf-8", "replace"))
except Exception:
    print("{}")
    sys.exit(0)
texts = []
for line in chunk.splitlines():
    try:
        d = json.loads(line)
    except Exception:
        continue
    for tc in (d.get("tool_calls") or []):
        if isinstance(tc, dict):
            texts.append(json.dumps(tc.get("args", {}), sort_keys=True, default=str))
blob = "\n".join(texts)
notices = []
for r in rules:
    try:
        if not isinstance(r, dict):
            continue
        if r.get("type") != "inject":
            continue
        if r.get("enabled") is False:
            continue
        if "pre_invocation" not in (r.get("scope") or []):
            continue
        name = r.get("name", "unnamed")
        if name in fired:
            continue
        pattern = r.get("pattern", "")
        if not pattern:
            continue
        fl = 0
        for ch in (r.get("flags") or ""):
            fl |= flagmap.get(ch, 0)
        if not re.search(pattern, blob, fl):
            continue
        text = r.get("text") or ("guidance: %s" % name)
        notices.append({"ephemeralMessage": text})
        fired.add(name)
    except Exception:
        continue
try:
    with open(state_path, "w") as f:
        json.dump({"offset": new_offset, "fired": sorted(fired)}, f)
except Exception:
    pass
if notices:
    print(json.dumps({"injectSteps": notices}))
else:
    print("{}")
PYEOF
) || result="{}"

printf '%s\n' "$result"
exit 0
