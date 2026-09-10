---
name: better-interface
description: Combines all of the `better-*` skills into a single review across accessibility, layout, writing, typography, color and UI polish.
---

# Interface review

Cross-discipline review: route to each `better-*` skill, collect evidence, consolidate one ranked verdict. Orchestration is all this skill owns — never duplicate domain rules here. (Condensed port of [upstream](https://github.com/jakubkrehel/skills/tree/main/skills/better-interface); MIT © 2026 Jakub Krehel.)

## Run order (foundational failures first)

1. `better-accessibility` 2. `better-layout` 3. `better-writing`
4. `better-typography` 5. `better-colors` 6. `better-ui`

Confirm every owner is available; missing owner → mark domain `Not reviewed`, never substitute from memory. Cap 15 findings; narrow oversized scopes to one complete flow and state the boundary.

## Rules

- Evidence, not taste: report triggers (below), leave deliberate project choices alone.
- One root cause, one row; never pad to the cap. Short or empty is valid.
- Fixes prefer: delete → platform → reuse project tokens → correct value → add.
- Read-only by default; don't edit unless asked to implement.
- Change/scoped requests (branch, PR, diff) belong to `interface-review` — say so and stop.

## Escalation triggers (HIGH on sight)

Unnamed interactive control · keyboard control without visible focus · pointer-only path · motion ignoring `prefers-reduced-motion` · clipped content at 320px/200% zoom · failing contrast pair · color-only meaning · destructive action without confirm/undo · unrecoverable truncation · cue-less hidden content · error without recovery path · semantic color misused · motion-only state change.

## Output

Findings table `Severity | Domain | Location(path:line) | Before | After | Why`, shared severity (HIGH blocks/misleads/hides/risks loss; MEDIUM harms comprehension; LOW isolated polish), then `Block` (any HIGH) or `Approve`. Full format: fetch [review-format.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-interface/review-format.md). State coverage per domain (`Clear`/`Not reviewed`) and every check not run as `Not verified`.
