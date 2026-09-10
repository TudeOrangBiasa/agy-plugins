# agy-minimal harness

Portable Antigravity CLI plugin harness: a minimal core that replaces the default tool surface, plus a frontend extension for interface quality.

## Language

**Context file**:
A repo-owned markdown file the agent reads for guidance (style, process, architecture).
_Avoid_: config, manifest

**Slot**:
One canonical role a context file fills (style, contribute, architecture, practices, memory, domain, design); several filenames can alias the same slot.
_Avoid_: category, type

**Pull convention**:
The agent reads a context file when its topic turns up, instead of having contents injected up front.
_Avoid_: push, preload
