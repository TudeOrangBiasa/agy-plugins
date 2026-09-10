---
name: better-typography
description: Focuses on type scale, spacing, sizing, variable fonts, OpenType features, wrapping, truncation and other details that make typography feel great across your product.
---

# Typography

Restraint: sensible scale, comfortable spacing, enough contrast. Exact values below, not approximations. (Condensed port of [upstream](https://github.com/jakubkrehel/skills/tree/main/skills/better-typography); MIT © 2026 Jakub Krehel.)

## Principles (exact values)

- Web format: `.woff2` (`.woff` legacy fallback only).
- CSS properties over raw axis/feature tags (`font-weight: 650`, `tabular-nums`); raw tags only for custom axes.
- Load every face the design uses; below `18px` stay ≥`400`; >3 fonts/families is a smell; pair for contrast.
- Type scale with semantic names (`text-body-sm` beats `text-sm`); headings descend with level; never pick a heading tag for its size.
- Line-height: headings ~`1.1`, body `1.5`–`1.6` (unitless); anything wrapping 3+ lines needs ≥`1.4`.
- Letter-spacing: negative on large headings, positive on small uppercase, none on body.
- Measure 60–75ch; `balance` on headings, `pretty` on descriptions, `break-word` on long strings, `nowrap` on labels; `line-clamp`/ellipsis with reachable full text.
- Tabular numbers on changing values; natural-case copy + `text-transform`; smart punctuation (curly quotes, en-dash ranges, `…`, `&nbsp;`, `&shy;`).
- Underlines from font metrics (`from-font`); color is the only reliably animatable part.
- Inputs `16px` on mobile (size up or scale trick); body ≥`16px`, UI ≥`14`/`13`, floor `12px`.
- Font smoothing once on root; set `lang`/`dir`, `<bdi>` mixed values, never reverse digits; keep text selectable.

## Mistakes

Synthesized face → load real face · overpowering child heading → descending scale · size-picked heading tag → semantics first · orphan → `pretty` · lopsided heading → `balance` · interface justify → `start` · descender-cut underline → `skip-ink`/from-font · bidi disorder → `lang`/`dir`/`<bdi>` · app-wide `select-none` → restore · hint without cue → dotted underline · thin UI text → `400`+ · `leading-none` on 3-line text → `1.4`.

## Deep shelf (fetch one upstream file on demand)

- [choosing-fonts.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-typography/choosing-fonts.md) · [css-cheat-sheet.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-typography/css-cheat-sheet.md) · [details-and-accessibility.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-typography/details-and-accessibility.md) · [spacing-and-sizing.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-typography/spacing-and-sizing.md) · [variable-fonts-and-opentype.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-typography/variable-fonts-and-opentype.md) · [wrapping-and-punctuation.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-typography/wrapping-and-punctuation.md)

## Report

Severity HIGH (unreadable/unrecoverable truncation) / MEDIUM (broken system/hierarchy) / LOW (isolated polish). Verify sizes/weights descending, line-heights, measure, truncation vs realistic strings from code; viewport resizing with a browser. Unrun checks are `Not verified`. Table `Severity | Location | Before | After | Why`, then `Block`/`Approve`.
