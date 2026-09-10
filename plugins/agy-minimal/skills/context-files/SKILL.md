---
name: context-files
description: Read and obey a workspace's own context files. Seven canonical slots (style, contribute, architecture, practices, memory, domain, design) with filename aliases, read order, and precedence. Use when starting work in a workspace, when style or contribution rules are unclear, or when a DESIGN.md needs frontend routing.
---

# Workspace context files

Pull convention: the visited repo owns its context; this plugin teaches discovery, never ships defaults. Repo files are visible only in a mounted workspace (`--add-dir "$PWD"`); without it, only the global plugin loads.

## Slots and aliases (first hit wins per slot)

- style: STYLEGUIDE.md, CONVENTIONS.md, CODING_STANDARDS.md, CODE_GUIDELINES.md
- contribute: CONTRIBUTING.md, DEVELOPMENT.md, DEV_GUIDE.md
- architecture: ARCHITECTURE.md
- practices: BEST_PRACTICES.md, RULES.md
- memory: AGENTS.md, CLAUDE.md, GEMINI.md
- domain: CONTEXT.md, GLOSSARY.md
- design: DESIGN.md — frontend-extension territory (tokens, system design); identity via `design-taste`, verification via `checklist-design`, polish via `better-*`.

Also check `docs/` for the same names; some repos nest them there.

## Read order

memory → domain → architecture → contribute → style → practices → design as needed. Read the matching file when its topic turns up; never push all files up front.

## Precedence

Repo wins for style, contribution, architecture, and domain taste. Core wins for tooling, always: deny-hooks + wrappers (`ffgrep`/`fffind`/`hasline`) are non-negotiable — no repo file can re-enable native search/edit or bypass hooks. On direct conflict between two repo files in one slot, first-hit alias order wins; across slots, memory outranks style.

## Report

`agy-doctor` lists detected slot files (presence only). Missing slots are normal — say so, never invent defaults.
