# ADR-0022: Bundle Checklist Design checklists as local references

Date: 2026-09-10
Status: Accepted (supersedes the never-bundle consequence of ADR-0021)

## Context

ADR-0021 kept 129 checklists upstream (fetch via `tffetch` per audit)
to protect the always-on budget. Correction: bloat is what gets
injected per turn (`SKILL.md`), not reference files resting on disk.
Checklists are inert data (~1–2KB each, ~200KB total); principles are
the live function. Unused injection is the bloat; on-demand reads are
not. Upstream pinned at `5de6e83` (shallow clone, MIT).

## Decision

Vendor verbatim under `skills/checklist-design/references/`: `index.md`,
`audit.md`, `critique.md`, all 129 `checklists/*.md`. Skill reads the
matching file per audit; nothing else loads. Docs repointed in the same
change (SKILL finding section, ATTRIBUTION, frontend rules, glossary,
snapshot); smoke asserts index + one sample checklist.

## Consequences

- Audits work offline; no per-audit network dependency.
- Update policy: re-vendor from upstream when checklists drift (record
  new SHA in ATTRIBUTION + SKILL footer); no live-drift surprise.
- Supersedes ADR-0021's fetch consequence; its core-extension
  vocabulary and mode discipline stand.
