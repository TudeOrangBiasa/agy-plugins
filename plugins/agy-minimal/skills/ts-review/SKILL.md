---
name: ts-review
description: TypeScript review rules checklist with examples. Use when writing or reviewing TypeScript (*.ts/*.tsx) code.
---

# ts-review

Condensed port of all 13 oh-my-pi `builtin-rules/ts-*` (MIT License,
Copyright (c) 2025 Mario Zechner, 2025-2026 Can Bölük, 2026 Stencil Labs, Inc.;
full texts: https://github.com/can1357/oh-my-pi/tree/main/packages/coding-agent/src/discovery/builtin-rules).
Advisory only — apply with judgment at review time, never gate or block
(matches upstream `interruptMode: never`).

## Checklist

1. **ts-no-any** — never `: any` / `as any`. Use `unknown`, generics, a
   schema parse (Zod/Valibot) at trust boundaries, named types, guards, or
   `satisfies` for literals.
2. **ts-bare-catch** — unused error binding → bare `catch {}`.
3. **ts-import-type** — type positions use top-level `import type`, never
   inline `import("pkg").Type` (except ambient `.d.ts` globals).
4. **ts-no-deprecated-leftovers** — finish the refactor: update every call
   site, delete the old name in the same change (public migration windows
   excepted).
5. **ts-no-dynamic-import** — static imports; `await import()` only for
   genuinely runtime-selected specifiers (+ comment why).
6. **ts-no-inline-cast-access** — never `(x as {...}).prop`; schema-parse at
   the boundary or narrow with `in`/`typeof`.
7. **ts-no-local-is-record** — no per-site `isRecord` guards; parse once at
   the boundary (or check used properties); at most one canonical guard per
   package.
8. **ts-no-return-type** — never `ReturnType<typeof fn>` in contracts; export
   a named type from the owning module.
9. **ts-no-test-timers** — no real timers in tests (`Bun.sleep`, `setTimeout`,
   `setInterval`); fake timers or await the real signal.
10. **ts-no-tiny-functions** — inline 1-2 line wrappers unless 3+ lockstep
    callsites, exported domain concept, guard, or test seam.
11. **ts-promise-with-resolvers** — `Promise.withResolvers()` over
    `new Promise` executor (unless an API requires executor form).
12. **ts-redundant-clear-guard** — no truthiness guards around
    `clearTimeout`/`clearInterval`/`clearImmediate` (unless the body does
    more than clear).
13. **ts-set-map** — static string-keyed literal → `Record`; dynamic
    membership → `Set`/`Map`.

## Need detail?

Fetch exactly one upstream file (never all at once):
`https://github.com/can1357/oh-my-pi/raw/main/packages/coding-agent/src/discovery/builtin-rules/<rule>.md`
for rationale, bad/good examples, and exception wording.

## Verify

- `tsc --noEmit` proves compilation, not rule compliance; re-check the
  triggered pattern is gone.
