# Architecture Decision Records

Short-form ADRs (Context → Decision → Consequences). One file per
structural choice; newest last. Append — never rewrite history (superseded
ADRs keep their Status line updated instead).

| ADR | Title | Status |
|-----|-------|--------|
| [0001](0001-agent-discovery-global-only.md) | Global-only agent discovery | Accepted (mechanism superseded by 0005) |
| [0002](0002-deny-hook-global-hooks-json.md) | Deny hook lives in global hooks.json | Accepted (location superseded by 0005) |
| [0003](0003-add-dir-and-absolute-hook-paths.md) | Always --add-dir, absolute hook paths | Accepted (paths superseded by 0005) |
| [0004](0004-print-mode-read-only.md) | Print mode is read-only | Accepted |
| [0005](0005-portable-plugin-cutover.md) | Portable plugin cutover | Accepted |
| [0006](0006-tinyfish-mcp-lazy.md) | TinyFish MCP lazy and minimal | Accepted |
| [0007](0007-cli-tweak-expansion-no-new-plugin.md) | CLI-tweak expansion without a new plugin | Accepted |
| [0008](0008-tool-surface-audit.md) | Hook scope from mined tool surface | Accepted |
| [0009](0009-playbook-practices-4-and-9.md) | Harness practices 4 and 9 made real | Accepted |
| [0010](0010-frontmatter-manifest-docs.md) | Documented frontmatter fields only | Accepted |
| [0011](0011-ttsr-port-shellcheck.md) | TTSR port (gate subset) and shellcheck enforcement | Accepted |
| [0012](0012-omp-agent-rules-port.md) | OMP agent-rules git port | Accepted |
| [0013](0013-ts-rules-port.md) | TypeScript rules port (condensed + on-demand) | Accepted (always-on reversed by 0014) |
| [0014](0014-ts-rules-skill-only.md) | TypeScript rules skill-only | Accepted |
| [0015](0015-guidance-inject.md) | Guidance-inject via transcriptPath | Accepted |
| [0016](0016-persona-pointer-style.md) | Persona as tool-pointer inventory | Accepted |
| [0017](0017-frontend-plugin.md) | Frontend tuning as a separate plugin | Accepted |
| [0018](0018-condense-frontend-skills.md) | Condense vendored frontend skills | Accepted |
| [0019](0019-kill-redundant-rules-files.md) | Kill redundant plugin rules files | Accepted |
| [0020](0020-restore-specialized-rules-files.md) | Restore specialized rules files | Accepted |
| [0021](0021-core-extension-checklist.md) | Core-extension vocabulary + Checklist Design verification | Accepted |
| [0022](0022-bundle-checklist-design.md) | Bundle Checklist Design checklists as local references | Accepted |
| [0023](0023-context-files-pull.md) | Pull-convention workspace context files | Accepted |
| [0024](0024-design-md-taste.md) | DESIGN.md as the taste foundation | Accepted |
| [0025](0025-single-persona.md) | Single frontend persona | Superseded by 0026 |
| [0026](0026-base-default-conditional-frontend.md) | Base-default session, conditional frontend | Accepted |
