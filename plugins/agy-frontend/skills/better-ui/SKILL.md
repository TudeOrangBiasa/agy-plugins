---
name: better-ui
description: Polishes and improves the UI in your project. Covers concentric border radius, optical alignment, surface depth, contextual icons, hit areas and more.
---

# UI polish

Polish is compounding small details. Exact values below, not approximations. (Condensed port of [upstream](https://github.com/jakubkrehel/skills/tree/main/skills/better-ui); MIT © 2026 Jakub Krehel.)

## Principles (exact values)

- Concentric radius: outer = inner + padding.
- Optical alignment over geometric (icon-side padding −2px; play triangle +2px X).
- Shadows for elevation, borders for structure/dividers only.
- Interactive changes: interruptible CSS transitions (keyframes = one-shot sequences only).
- Enter: split semantic chunks, stagger ~100ms (`opacity`+`blur`+`translateY`); frequent interactions never stagger. Exit: softer, `-12px`, `ease-out`, shorter than enter.
- Contextual icons: `opacity`+`scale(0.25→1)`+`blur(4px→0)`, spring `duration 0.3 bounce 0`; no-motion-lib = CSS cross-fade `cubic-bezier(0.2, 0, 0, 1)`.
- Images: `1px` outline, black/10 light, white/10 dark, `offset -1px`.
- Press: `scale(0.96)` (never <0.95) + opt-out `static` prop.
- Page load: `initial={false}` on AnimatePresence (except intentional entrances).
- Theme switch: kill transitions, reflow, restore next frame.
- Transition named properties only (never `all`); `will-change` sparingly (`transform`/`opacity`/`filter`, on stutter).
- Icon stroke matches text weight (1.5px@400, 2px@600); one SVG `currentColor` per icon, outline default / fill active.
- Motion restraint: ≤150ms or instant on high-frequency; motion never the only cue.

## Mistakes

Off-center icons → optical nudge · staged jank → stagger/subtle exits · theme smear → transition kill · `transition: all` → named props · first-frame stutter → sparse `will-change` · hairline-vs-bold mismatch → stroke match.

## Deep shelf (fetch one upstream file on demand)

- [animations.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-ui/animations.md) · [enter-exit.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-ui/enter-exit.md) · [icon-transitions.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-ui/icon-transitions.md) · [icons.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-ui/icons.md) · [performance.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-ui/performance.md) · [surfaces.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-ui/surfaces.md)

## Report

Severity HIGH (breaks interaction/motion-only state) / MEDIUM (visible inconsistency) / LOW (isolated polish). Verify states + durations from code, motion at 10% with a browser; unrun checks are `Not verified`. Table `Severity | Location | Before | After | Why`, then `Block`/`Approve`.
