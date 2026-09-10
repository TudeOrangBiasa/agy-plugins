# ADR-0010: Documented frontmatter fields only

Date: 2026-09-09
Status: Accepted

## Context

Our agent carried `skills: []` / `agents: []` — fields absent from the live
docs and from the official flutter reference agent (which carries only
`name`/`description`/`mainAgent`/`subagent`/`commandExecutionPolicy`).
`skills: []` risked unloading the plugin skills the persona depends on.

## Decision

Stripped the undocumented fields; added `$schema` + `description` to
`plugin.json` per the live schema (`required: [name]`,
`additionalProperties: false`). Did not copy `commandExecutionPolicy`
(semantics unknown; global `toolPermission` already covers it).

## Consequences

- Removal is weakly dominant: no-op if the fields were ignored, restores
  skills if they were restrictive.
- Deferred migrating to the `agy plugin install` registry path
  (`config/plugins` is proven live; the `plugin list` registry gap is a
  follow-up).
