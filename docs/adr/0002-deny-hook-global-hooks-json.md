# ADR-0002: Deny hook lives in global hooks.json

Date: 2026-09-08
Status: Accepted (hook location superseded by ADR-0005; finding stands)

## Context

Logs showed `loaded 1 named hooks` from workspace runs until a global merge
produced `loaded 2 named hooks`. `hooks_manager` loads exactly one
`hooks.json` file (the global one); workspace files are source templates
only.

## Decision

Merge deny hooks into global `~/.gemini/config/hooks.json` idempotently via
the deploy script, with absolute command paths.

## Consequences

- Rules alone are not a safety net; forced native-tool attempts need the
  hook to deny with a reason.
- ADR-0005 later moved hooks into the plugin bundle with `./bin/` relative
  commands and removed the global merge.
