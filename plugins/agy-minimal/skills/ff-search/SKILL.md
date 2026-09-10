---
name: ff-search
description: Fast repo search with ffgrep (text) and fffind (files). Use when you need to find code, text, or files instead of the native grep_search and find_by_name tools.
---

# ff-search

Thin deterministic wrappers over `rg` and `fd`. Always prefer these over native search tools.

## Steps

1. Text search: `ffgrep <pattern> [path] [-- <extra rg args>]`
   - Output contract: `path:line:content`, `--color=never`.
   - Exit 0 on hit, 1 on no hit, 2 on usage error.
   - Ignores `.git`, `node_modules`, `target` by default.
2. File search: `fffind <pattern> [path] [-- <extra fd args>]`
   - Output contract: one path per line.
3. If a PreToolUse hook denies `grep_search`/`find_by_name`, that is expected — use the wrappers above.

## Verify

- `ffgrep --help` equivalent: run with no args, expect exit 2 + usage line.
