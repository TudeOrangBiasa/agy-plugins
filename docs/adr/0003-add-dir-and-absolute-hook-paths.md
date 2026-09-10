# ADR-0003: Always --add-dir, absolute hook paths

Date: 2026-09-08
Status: Accepted (path form superseded by ADR-0005; --add-dir finding stands)

## Context

Spec (`agy-customizations/docs/hooks.md` + `rules.md`) says `.agents/hooks.json`
loads — but only with `--add-dir` (`loaded 2 named hooks from 2 files`);
without it, only global hooks load. The spec's `./scripts/...` example fails
live: hook cwd is the dir containing `hooks.json`, giving exit 127.

## Decision

Always run with `--add-dir "$PWD"`; hook commands absolute, never
`./scripts/...`. Rejected `../scripts/...` as cwd-fragile.

## Consequences

- Sessions without `--add-dir` silently lose workspace hooks.
- ADR-0005 replaced absolute paths with plugin-relative `./bin/` commands
  (hook cwd = plugin root, proven live).
