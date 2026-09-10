# ADR-0023: Pull-convention workspace context files

Date: 2026-09-10
Status: Accepted

## Context

Probes proved workspace `AGENTS.md` loads only with `--add-dir`
(verbatim canary quote) and is invisible without it (`NONE-SEEN`);
the 16 requested filenames overlap heavily; prose obedience cannot be
deny-gated like tool calls.

## Decision

Seven canonical slots with alias order (style, contribute,
architecture, practices, memory, domain, design — `DESIGN.md` routes to
the frontend extension as token/system design). Thin pointer in
`rules/AGENTS.md`, full mapping in the `context-files` core skill;
`agy-doctor` reports slot presence only. Precedence: repo wins for
style/taste, core wins for tooling (deny-hooks + wrappers
non-negotiable). Created root `CONTEXT.md` with the resolved terms.

## Consequences

- Default-agent coverage via the rules pointer (ADR-0020 pattern).
- Missing slots are normal; the agent never invents defaults.
