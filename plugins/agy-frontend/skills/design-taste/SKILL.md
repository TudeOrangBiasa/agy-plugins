---
name: design-taste
description: Develop taste and kill AI slop with DESIGN.md (Google Labs format): exact tokens plus prose rationale, specific references over generic adjectives, negative constraints. Use when authoring or reading a repo DESIGN.md, defining a visual identity, or when output looks generic and needs a point of view. Verifies with the upstream lint/diff CLI.
---

# Design taste via DESIGN.md

Taste = a specific point of view, not generic adjectives. "Modern, clean, premium" describes a region — the model generates its center (slop). A specific reference ("1970s graduate lecture handout") describes a point. A repo-owned DESIGN.md makes that point persistent. (After [google-labs-code/design.md](https://github.com/google-labs-code/design.md); Apache 2.0.)

## The file (design slot)

Repo `DESIGN.md` (`docs/` fallback): YAML frontmatter tokens + markdown prose. Tokens are the normative values; prose is the why and how. Read it whenever doing design work in a repo that has one. None present → say so, fall back to `better-*`/`checklist-design`, never invent an identity.

Token groups: `colors`, `typography`, `rounded`, `spacing`, `components` (+ any custom keys); cross-reference syntax `{path.to.token}`. Prose sections (`##`, omissible but ordered): Overview, Colors, Typography, Layout, Elevation & Depth, Shapes, Components, Do's and Don'ts.

## Writing taste (authoring or tightening)

1. Specific reference over adjectives: one evocative object or world, never a dozen metric adjectives.
2. Prose first, tokens as context: describe intent, bind values with `{refs}`.
3. Negative constraints: state what it is NOT (no glows, accent never on type). A specific reference gives most for free; add an intentional Do's and Don'ts list for the rest.
4. Restraint stated plainly: one accent used sparingly, one family, motion caps — written as rules, not vibes.

Full doctrine: `references/philosophy.md` (verbatim). Full spec: upstream `docs/spec.md` (versioned alpha — fetch on demand, never snapshot).

## Verify (computable, on demand)

- `npx @google/design.md lint DESIGN.md` — spec conformance, broken refs, WCAG contrast as JSON findings (needs network once).
- `npx @google/design.md diff OLD NEW` — token and prose regressions.
- Unrun checks are `Not verified`.
