# ADR-0004: Print mode is read-only

Date: 2026-09-09
Status: Accepted

## Context

Print-mode (`-p`) toolset probe via transcripts + hook stdin tap:
`run_command` is absent from the `-p` toolset (agent routes shell via MCP
`exec`); `write_to_file` is unregistered (`unknown tool` on forced attempt).
Hook stdin payload carries no mode flag (only
conversationId/stepIdx/toolCall/workspacePaths), so hooks cannot condition
on mode.

## Decision

Treat `-p` as read-only; use interactive sessions for execution. Deny hooks
still fire in `-p`, degrading gracefully to copy-paste patch output.

## Consequences

- Conditional allow-in-`-p` is impossible; no mode signal exists.
- Persona and skills must present the read-only contract up front.
