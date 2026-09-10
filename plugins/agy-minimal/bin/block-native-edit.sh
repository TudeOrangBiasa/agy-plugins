#!/usr/bin/env bash
# block-native-edit.sh — PreToolUse hook for agy.
# Denies write_to_file / replace_file_content so the agent falls back to
# hasline edits via run_command. Reads hook payload on stdin, ignores it.
set -euo pipefail

if [ ! -t 0 ]; then
  cat >/dev/null 2>&1 || true
fi

cat <<'EOF'
{"decision":"deny","reason":"Native edit disabled. Use hasline via run_command: `hasline show FILE`, then `hasline apply PATCH`."}
EOF
exit 0
