---
name: better-accessibility
description: Helps your project comply with accessibility standards and best practices.
---

# Accessibility

Free when platform-native: real elements, real labels, one focus rule. (Condensed port of [upstream](https://github.com/jakubkrehel/skills/tree/main/skills/better-accessibility); MIT © 2026 Jakub Krehel.)

## Principles (exact values)

- Native first: `<button>` actions, `<a href>` navigation, never `<div onClick>`; no ARIA beats bad ARIA.
- Focus: `:focus-visible` (prefer browser ring); custom ring ≥`2px` verified on every crossed color + forced-colors; `tabindex` only `0`/`-1`; modals `inert` background + trap + restore trigger + `overscroll-behavior: contain`.
- Hit areas: WCAG AA floor 24×24, aim 44 touch / 40 desktop; extend via pseudo-element on wrapper (never `input`); never overlap; decorative layers `pointer-events: none`.
- Labels: every control `<label for>`/wrapping (placeholder never a label); `autocomplete`+`type`+`inputmode`; never block paste.
- Errors: submit stays enabled, validate on submit, `aria-invalid` + `aria-describedby` + focus first error; native `disabled` vs focusable `aria-disabled`.
- Names: icon-only buttons `aria-label`, visible text inside accessible name, decorative `aria-hidden` (never focusable).
- Color never sole carrier (icon/text/underline redundant cue).
- Motion opt-in (`prefers-reduced-motion: no-preference`); reduced = crossfade, kill parallax/autoplay; toasts with actions persist.
- Announce: focus move > `aria-describedby` > polite `role="status"` > `role="alert"` (urgent only); stable empty region before polite updates.
- Alt by purpose (`""` decorative, meaning informative, action functional); headings outline (`h1` once, no skips, one `<main>`, skip link first); 200% zoom + 320px reflow, `min-height` not `height`.

## Mistakes

Unverified custom focus color → check all adjacents + forced-colors · flaky polite updates → stable empty region · routine `assertive` → `polite` · `aria-hidden` on focusable → remove · disabled-until-valid submit → keep enabled · stuck touch hover → `(hover: hover)` gate · tooltip on `disabled` → beside-text or `aria-disabled`.

## Deep shelf (fetch one upstream file on demand)

- [focus-and-keyboard.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-accessibility/focus-and-keyboard.md) · [forms.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-accessibility/forms.md) · [hit-areas.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-accessibility/hit-areas.md) · [motion-and-zoom.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-accessibility/motion-and-zoom.md) · [screen-readers.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-accessibility/screen-readers.md) · [semantics-and-aria.md](https://github.com/jakubkrehel/skills/raw/main/skills/better-accessibility/semantics-and-aria.md)

## Report

Severity HIGH (task blocked/content hidden/systemic) / MEDIUM (meaningfully harder) / LOW (isolated polish). Verify names, keyboard paths, focus styles, motion guards, label bindings from code; tab order, a11y tree, focus visibility, audit with a browser/screen reader. Unrun checks are `Not verified`. Table `Severity | Location | Before | After | Why`, then `Block`/`Approve`.
