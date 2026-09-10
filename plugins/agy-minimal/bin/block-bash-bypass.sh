#!/usr/bin/env bash
# shellcheck disable=SC2016  # backticks in the deny reason are literal markdown, not expansion.
# block-bash-bypass.sh — PreToolUse hook on run_command for agy.
# Denies raw search/edit commands that bypass plugin wrappers:
# rg/fd/recursive-grep -> ffgrep/fffind; sed -i/perl -pi -> hasline.
# Wrapper-headed segments (ffgrep/fffind/hasline/agy-doctor/tfsearch/tffetch) are
# skipped; quoted strings and heredoc bodies are prose, not code. Only unbounded
# discovery is denied (use fffind): find without -maxdepth 0/1, tree, locate,
# ls -R. Single-level listing (plain ls, ls -d, bounded find) stays allowed —
# denying it only adds deny+retry tokens with zero savings.
# Reads hook payload on stdin; allow (incl. parse failure) is fail-open.
set -euo pipefail

payload=""
if [ ! -t 0 ]; then
  payload=$(cat 2>/dev/null || true)
fi

result=$(python3 - "$payload" <<'EOF' 2>/dev/null
import json, re, sys
raw = sys.argv[1] if len(sys.argv) > 1 else ""
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
cmd = re.sub(r"<<-?\s*['\"]?(\w+)['\"]?[^\n]*\n.*?^\1\s*$", " ", cmd, flags=re.DOTALL | re.MULTILINE)
cmd = re.sub(r"'[^']*'", " ", cmd)
cmd = re.sub(r'"(?:[^"\\]|\\.)*"', " ", cmd)
allow_heads = {"ffgrep", "fffind", "hasline", "agy-doctor", "tfsearch", "tffetch"}
rules = [
    (r"(?:^|[\s;|&(`$])(rg|ripgrep|fdfind|fd)(?=[\s]|$)", "ffgrep / fffind"),
    (r"\bgrep\s+(?:-[a-zA-Z]*[rR]|--recursive|--include)", "ffgrep"),
    (r"\bsed\b[^\n]*?(?:^|[\s;|&(`$])-i[^\s|&;`$]*", "hasline"),
    (r"\bperl\b[^\n]*?(?:^|[\s;|&(`$])-i[^\s|&;`$]*", "hasline"),
]
denied = None
for seg in re.split(r"[;&|\n]+", cmd):
    seg = seg.strip()
    if not seg:
        continue
    first = re.sub(r"^(sudo\s+)+", "", seg).split(None, 1)[0]
    head = first.rsplit("/", 1)[-1]
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
