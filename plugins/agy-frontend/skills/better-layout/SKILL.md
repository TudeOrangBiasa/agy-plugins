---
name: better-layout
description: Helps with grouping, alignment, reading order, progressive disclosure and other details that make a good layout.
---

# Layout

Position, spacing and alignment carry hierarchy before a word is read. (Condensed port of [upstream](https://github.com/jakubkrehel/skills/tree/main/skills/better-layout); MIT © 2026 Jakub Krehel.)

## Principles (exact values)

- Group with space first (inter-group gap ≥2× intra-group, e.g. `8px`→`16px`+), background shapes second, separator lines last.
- Controls visually distinct from content (shape, border, or placement zone).
- Shared alignment edges, one spacing step per subordination level (`16px` default); logical properties (`inline-start/end`), never physical, for direction-dependent layout.
- Order by importance: top + leading edge first; identifying content leads, metadata/actions trail.
- Hidden content needs a visible cue (established pattern, `16–32px` peek, or disclosure control).
- Breathing room: `12px` bordered/filled adjacents, `24px` borderless/unrelated groups (hit areas must not overlap).
- Buttons inside layout margins (`16px` inline mobile), radius visible; edge-to-edge only as deliberate platform chrome with safe areas.
- Content bleeds, controls float (margins + `env(safe-area-inset-*)`).
- Breakpoints from content (collapse late); container queries for components; test smallest+largest first.
- Growth: no fixed sizes on text containers (`max-width`+wrap, `min-height`), buttons size from labels; pseudo-localize. Never park critical actions where clipping can reach them.

## Mistakes

Physical logical-property violation → `inline-start/end` · edge-touching button → inset margins · default breakpoints → content-fit breaks · fixed monolingual widths → `max-width`+wrap · clipped primary action → stable chrome/sticky.

## Deep shelf (fetch one upstream file on demand)

- [grouping-and-alignment.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-layout/grouping-and-alignment.md) · [spacing-and-adaptivity.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-layout/spacing-and-adaptivity.md)

## Report

Severity HIGH (blocked content/action at supported viewport) / MEDIUM (hierarchy/reading/adaptability harm) / LOW (isolated polish). Verify logical props, container/media queries, DOM reading order from code; supported widths, 200% zoom, RTL mirror with a browser. Unrun checks are `Not verified`. Table `Severity | Location | Before | After | Why`, then `Block`/`Approve`.
