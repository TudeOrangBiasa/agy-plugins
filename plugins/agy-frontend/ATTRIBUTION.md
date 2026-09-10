# Attribution — agy-frontend skills

`skills/better-*` are condensed ports of
[jakubkrehel/skills](https://github.com/jakubkrehel/skills) (MIT License,
Copyright (c) 2026 Jakub Krehel): enforceable cores (principles, exact
values, mistake tables, reporting discipline) vendored per SKILL.md, full
texts fetched upstream on demand via deep-shelf links. Only the seven
`better-*` skills were ported (`break`, `variant`, `explain-interface`
need browser workflows the CLI cannot run); per-skill `agents/openai.yaml`
files were omitted as harness-specific to another runner.

`skills/checklist-design` adapts
[checklist-design/skills](https://github.com/checklist-design/skills) @`5de6e83` (MIT License):
`SKILL.md` is a condensed agy port (code-first review order); `references/audit.md`
and `references/critique.md` are verbatim mode discipline; all 129 files under
`references/checklists/` plus `references/index.md` are vendored verbatim.
Reference files rest on disk (never injected per turn) — only the matching
checklist is read per audit, so the bundle is not bloat.

`skills/design-taste` follows
[google-labs-code/design.md](https://github.com/google-labs-code/design.md) (Apache License 2.0,
Copyright Google Labs): `SKILL.md` condenses the format + taste doctrine for agy;
`references/philosophy.md` is verbatim. Spec and examples stay upstream
(versioned alpha) — linked, never snapshotted. Verification runs the upstream
CLI on demand (`npx @google/design.md lint|diff`).
