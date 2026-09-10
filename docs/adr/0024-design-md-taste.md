# ADR-0024: DESIGN.md as the taste foundation

Date: 2026-09-10
Status: Accepted

## Context

Taste = avoiding generic AI output (slop) = premium results. The
mechanism is a point of view: [google-labs-code/design.md](https://github.com/google-labs-code/design.md)
(Apache 2.0) gives agents a persistent visual identity as tokens +
prose, with computable `lint`/`diff` verification. This fills the
`design` slot (ADR-0023) with an identity layer beneath principles
(`better-*`) and verification (`checklist-design`).

## Decision

New `design-taste` frontend skill: condensed format + taste doctrine,
`references/philosophy.md` verbatim, spec/examples upstream-linked
(versioned alpha, never snapshotted). Repo `DESIGN.md` is read whenever
present; absent, the agent says so and falls back — never invents an
identity. Layer order: identity (`design-taste`) → principles
(`better-*`) → verification (`checklist-design`, upstream lint).

## Consequences

- Upstream CLI verification needs network once (on-demand, like the web layer).
- Apache 2.0 attribution recorded; verbatim file carries its notice.
