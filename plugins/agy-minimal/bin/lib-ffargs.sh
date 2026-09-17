# lib-ffargs.sh — shared <pattern> [path] [-- <extra args>] parser for ffgrep/fffind.
# Sourced only (no exec bit). Safe under `set -euo pipefail`.
# Contract: caller sets "$@" to args AFTER the usage guard; after
# `ff_parse_args "$@"`, globals are: pattern, path, extra (array).
# Globals set by ff_parse_args: pattern, path, extra (array). Declared here
# so shellcheck sees file-scope initialization (SC2154).
pattern=""; path="."; extra=()
ff_parse_args() {
  pattern="$1"; shift
  path="."
  extra=()
  if [ $# -gt 0 ]; then
    if [ "$1" = "--" ]; then
      shift
      extra=("$@")
    else
      path="$1"; shift
      if [ $# -gt 0 ] && [ "$1" = "--" ]; then
        shift
        extra=("$@")
      elif [ $# -gt 0 ]; then
        extra=("$@")
      fi
    fi
  fi
}
