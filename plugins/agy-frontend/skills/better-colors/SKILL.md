---
name: better-colors
description: Helps you build a color system and answer anything about color in your project. You can generate palettes, use semantic tokens, convert between formats, check contrast and more.
---

# Colors

A color system is ramps named by role, verified on real backgrounds. Never report an unmeasured contrast or an estimated color. (Condensed port of [upstream](https://github.com/jakubkrehel/skills/tree/main/skills/better-colors); MIT © 2026 Jakub Krehel.)

## Principles (exact values)

- Ramps, not colors: 1 neutral + 1 accent + only rendered status ramps; every step has a consuming role (Tailwind `50`–`950` / Radix `1`–`12` role map).
- Primitives by hue (`--blue-500`, never in components); semantics by role (`--color-text-secondary`); grammar `--color-{role}-{variant}-{state}`; `accent` = brand, `primary` = most prominent.
- Token only in its role, never borrowed by value; one color one meaning (±15° hue); one filled action per view.
- Well-formed ramp: even perceived lightness, constant hue, vividness peaks mid-ramp, denser light end, no pure black/white ends, adjacent steps distinguishable; compute with a library (`culori`/`colorjs.io`/`chroma.js`), never by eye.
- Brand color on the solid-fill step (`500`/`9`); pin fixed brands, snap the rest; dark mode = swap roles then hand-tune (vividness down, dark-end separation, recheck pairs); one switching mechanism only.
- Measure the rendered pair (foreground vs actual background, every appearance); APCA default (body Lc 75/90, non-body 60/75, large 45/60, UI 30), WCAG 2 for legal claims; fix by lightness, remeasure; report failing pairs, don't repaint.
- Notation matches the project (`oklch()` for new systems); convert only in-scope migrations; sRGB fallback before P3/`@supports`.
- Gradients: space is a look (`oklab` default, `okch` vivid sweeps, sRGB mutes); watch gray dead-zone, banding, text-on-gradient (worst region or scrim).

## Mistakes

Raw value for tokened role → reuse/add token · stray `oklch()` in hex codebase → keep notation · primitive in component → semantic token · appearance/use-named token → role name · `primary` collision → `accent` for brand · borrowed token → add missing role · HSL-built ramp → perceptual rebuild · even full-range spacing → tighten light end · copied saturation → proportional maxima · status/acent collision → separate hues · mirrored dark mode → hand-tune + recheck · mixed switch mechanisms → pick one · hue-fixed contrast → change lightness · P3 without fallback → sRGB first.

## Deep shelf (fetch one upstream file on demand)

- [color-formats.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-colors/color-formats.md) · [color-usage.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-colors/color-usage.md) · [contrast.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-colors/contrast.md) · [palette-generation.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-colors/palette-generation.md) · [palette-structure.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-colors/palette-structure.md) · [token-naming.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-colors/token-naming.md)

## Report

Severity HIGH (unreadable/misleading color) / MEDIUM (theme/token/gamut failure) / LOW (isolated polish). Verify token values, gamut, both themes, computed contrast from declared pairs (rendered result with a browser). Unrun checks are `Not verified`. Table `Severity | Location | Before | After | Why`, then `Block`/`Approve`.
