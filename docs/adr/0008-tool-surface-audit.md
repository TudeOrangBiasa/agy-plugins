# ADR-0008: Hook scope from mined tool surface

Date: 2026-09-09
Status: Accepted

## Context

The `run_command` interceptor was first designed from assumption. Retroactive
audit: binary enum (`CORTEX_STEP_TYPE_*`, 150+ values) + 22 conversation DBs
mined. `run_command` appears in 435/436 CommandLine payloads (the shell
channel). Real bypasses observed: `grep -rn` (8x), `find -maxdepth 4` (4x)
— both denied. `find_by_name`/`write_to_file`/`replace_file_content`
confirmed present (98/76/70 hits), so existing deny matchers are live, not
aspirational. `ls -la` observed 20x+ as legit exploration.

## Decision

Keep hook scope at `run_command` content-inspection with the mined deny set.
No `shell_exec` matcher (zero hits), no `mcp_tool` interception (bypass
unconfirmed, risks TinyFish tools), no step-level `find` deny (`find_all_references`
collision), plain `ls` stays allowed (deny+retry overhead, zero savings).

## Consequences

- Hook scope changes now require mined evidence first (see `agy-doctor` and
  the transcript-mining recipe in this file's history, not new assumptions).
