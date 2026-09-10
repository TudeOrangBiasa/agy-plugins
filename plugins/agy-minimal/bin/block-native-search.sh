#!/usr/bin/env bash
# block-native-search.sh — PreToolUse hook for agy.
# Denies grep_search / find_by_name so the agent falls back to
# ffgrep / fffind via run_command. Reads hook payload on stdin, ignores it.
set -euo pipefail

# Drain stdin (hook payload) without blocking when empty.
if [ ! -t 0 ]; then
  cat >/dev/null 2>&1 || true
fi

cat <<'EOF'
{"decision":"deny","reason":"Native search disabled. Use ffgrep <pattern> [path] / fffind <pattern> [path] via run_command."}
EOF
exit 0
