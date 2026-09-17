#!/usr/bin/env bash
# shellcheck disable=SC2016  # backticks in the deny reason are literal markdown, not expansion.
# block-bash-bypass.sh — PreToolUse hook on run_command for agy.
# NEVER use rg/fd/ripgrep, recursive grep, sed -i/perl -pi, unbounded find,
# tree/locate, or ls -R here — use ffgrep/fffind/hasline via run_command.
# Full deny/allow contract lives in docs/ARCHITECTURE.md (bypass hook output
# contract); what stays here by design: single-level listing (plain ls, ls -d,
# bounded find) stays allowed — denying it only adds deny+retry tokens with
# zero savings. Reads hook payload on stdin; allow (incl. parse failure) is
# fail-open.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
lib="$here/lib-runmatch.py"
payload=""
if [ ! -t 0 ]; then
  payload=$(cat 2>/dev/null || true)
fi

result=$(python3 - "$payload" "$lib" <<'EOF' 2>/dev/null
import importlib.util
import json, re, sys
raw = sys.argv[1] if len(sys.argv) > 1 else ""
_lib_path = sys.argv[2] if len(sys.argv) > 2 else ""
try:
    _spec = importlib.util.spec_from_file_location("lib_runmatch", _lib_path)
    _lib = importlib.util.module_from_spec(_spec)
    _spec.loader.exec_module(_lib)
    strip_prose, split_segments, segment_head = _lib.strip_prose, _lib.split_segments, _lib.segment_head
except Exception:
    def strip_prose(s):
        s = re.sub(r"<<-?\s*['\"]?(\w+)['\"]?[^\n]*\n.*?^\1\s*$", " ", s, flags=re.DOTALL | re.MULTILINE)
        s = re.sub(r"'[^']*'", " ", s)
        s = re.sub(r'"(?:[^"\\]|\\.)*"', " ", s)
        return s
    def split_segments(cmd):
        return re.split(r"[;&|\n]+", cmd)
    def segment_head(seg):
        seg = re.sub(r"^(sudo\s+)+", "", seg.strip())
        if not seg:
            return ""
        return seg.split(None, 1)[0].rsplit("/", 1)[-1]
try:
    data = json.loads(raw) if raw.strip() else {}
except Exception:
    print("allow")
    sys.exit(0)
args = (data.get("toolCall") or {}).get("args") or {}
cmd = args.get("CommandLine", args.get("commandLine", args.get("command_line", "")))
if not isinstance(cmd, str):
    cmd = str(cmd)
# Prose is not code: drop heredoc bodies and quoted strings ($(...) is kept).
cmd = strip_prose(cmd)
allow_heads = {"ffgrep", "fffind", "hasline", "agy-doctor", "tfsearch", "tffetch"}
rules = [
    (r"(?:^|[\s;|&(`$])(rg|ripgrep|fdfind|fd)(?=[\s]|$)", "ffgrep / fffind"),
    (r"\bgrep\s+(?:-[a-zA-Z]*[rR]|--recursive|--include)", "ffgrep"),
    (r"\bsed\b[^\n]*?(?:^|[\s;|&(`$])-i[^\s|&;`$]*", "hasline"),
    (r"\bperl\b[^\n]*?(?:^|[\s;|&(`$])-i[^\s|&;`$]*", "hasline"),
]
denied = None
for seg in split_segments(cmd):
    seg = seg.strip()
    if not seg:
        continue
    head = segment_head(seg)
    if head in allow_heads:
        continue
    if head in ("tree", "locate"):
        denied = ("fffind", head)
        break
    if head == "find":
        if not re.search(r"\s-maxdepth\s+[01]\b", seg):
            denied = ("fffind", head)
            break
    if head == "ls":
        m = re.search(r"\s(-[a-zA-Z]*R|--recursive)", seg)
        if m:
            denied = ("fffind", ("ls " + m.group(1)).strip()[:24])
            break
    for pattern, wrapper in rules:
        m = re.search(pattern, seg)
        if m:
            denied = (wrapper, m.group(0).strip()[:24])
            break
    if denied:
        break
if denied:
    print("deny|%s|%s" % denied)
else:
    print("allow")
EOF
) || result="allow"

case "$result" in
  deny\|*)
    wrapper="${result#deny|}"; wrapper="${wrapper%%|*}"
    trigger="${result#deny|*|}"; trigger="${result##*|}"
    printf '{"decision":"deny","reason":"Raw `%s` in run_command bypasses plugin wrappers. Use %s via run_command."}\n' \
      "$trigger" "$wrapper"
    ;;
  *)
    echo "{}"
    ;;
esac
exit 0
