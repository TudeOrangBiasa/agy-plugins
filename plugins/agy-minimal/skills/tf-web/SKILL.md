---
name: tf-web
description: Token-cheap web search and page fetch via TinyFish REST. Use when you need web results or page content instead of the native search_web and read_url_content tools.
---

# tf-web

REST wrappers (free, no wallet draw). Key comes from `TINYFISH_API_KEY`
in env — never print it, never commit it.

## Steps

1. Search: `tfsearch <query> [--location CC] [--language LL] [--news | --papers] [--fresh MINUTES] [--page N]`
   - Compact `N. TITLE / URL / SNIPPET` lines, ready for LLM use.
2. Fetch: `tffetch <url>... [--ttl SECONDS] [--format markdown|html|json] [--selector CSS ...]`
   - Up to 10 URLs per request; markdown `## TITLE (URL)` + text per result.
3. No key? Tell the user: `export TINYFISH_API_KEY=...` (key at `agent.tinyfish.ai/api-keys`).
4. Richer needs (automation, browser sessions): TinyFish MCP tools after one-time OAuth.

## Verify

- No-args run exits 2 with a usage line (no network touched).
