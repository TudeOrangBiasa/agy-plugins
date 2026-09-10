# ADR-0016: Persona as tool-pointer inventory

Date: 2026-09-09
Status: Accepted

## Context

Pi's `system-prompt.ts` lists tools only with one-line snippets plus a
tiny always-on core; docs resolve via a topic-routing table read on
demand. Our persona carried bare NEVER prohibitions — context pollution,
since deny hooks already enforce with self-contained reasons.

## Decision

Rewrote the persona to the pi structure (opener → tool inventory → custom
tools note → guidelines → skill routing table); dropped NEVER lines and
the non-actionable `Run with:` line. The lazy-senior discipline ships as
an on-demand skill; repo `AGENTS.md` overrides flipped positive-first.

## Consequences

- Enforcement lives in hooks, knowledge in skills, pointers in the
  persona. Prohibition without an alternative is treated as pollution.
