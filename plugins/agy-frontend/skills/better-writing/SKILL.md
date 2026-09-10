---
name: better-writing
description: Focuses on improving product copy in your project.
---

# Interface writing

Clear and brief beats clever; consistent beats varied. Redesign away the error before rewording it. (Condensed port of [upstream](https://github.com/jakubkrehel/skills/tree/main/skills/better-writing); MIT © 2026 Jakub Krehel.)

## Principles

- Recon nearby copy first: terminology, conventions, voice guide. One product voice; tone flexes by stakes (warm success, neutral routine, calm errors, serious loss).
- Address the reader (`you`, not `the user`); sparse possessives; plain tire-reader words, no idioms/humor; device verbs (tap/click/select); full templated strings with plurals, never fragment assembly.
- Verb-first buttons (`Delete project`, never `OK!`); confirmations repeat the consequence; one flow vocabulary (`Get started`/`Continue`/`Done`); links describe destinations (`suffix Learn more`s).
- One capitalization policy per element type (sentence case default); toggles label the ON state; link to settings, don't describe paths.
- Errors: instruction beside the failed field (`aria-invalid`+describedby, focus first error), no blame/`oops`/`!`, hints before mistakes.
- Empty states: what + how to fill + one next action (name the query + exit for search); placeholders are format examples, never labels.

## Report

Severity HIGH (misleads/hides recovery) / MEDIUM (voice/terminology break) / LOW (wording polish). Source alone verifies: labels vs actions, errors vs fixes, terminology vs neighbors; no browser needed. Table `Severity | Location | Before | After | Why`, then `Block`/`Approve`.
