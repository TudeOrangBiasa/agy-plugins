# ADR-0006: TinyFish MCP lazy and minimal

Date: 2026-09-09
Status: Accepted (pending one-time user OAuth)

## Context

Token-cheap web tools are needed, but eager MCP servers inflate every
turn's system prompt. TinyFish `search` + `fetch_content` are free;
OAuth is a one-time browser flow.

## Decision

Plugin `mcp_config.json` declares only the TinyFish `serverUrl` (lazy by
default, no eager flags); `search` + `fetch_content` only, no
automation/browser tools. REST wrappers (`tfsearch`/`tffetch`) stay the
first resort; MCP covers richer needs after OAuth.

## Consequences

- `agy mcp list` shows nothing headless until OAuth completes — install
  proves discovery, auth proves connection.
- Rejected eager flags (wasteful) and API-key env transport (OAuth is the
  documented path, no secret to manage).
