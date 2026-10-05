# agy-minimal harness

Portable Antigravity CLI plugin harness: a minimal core (tools + discipline, general-purpose, no flags).

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

**Core**:
The `agy-minimal` plugin: owns the tool surface (deny-hooks + wrappers) and the base coding discipline. Stock `agy` runs general-purpose on the core with no flags.
_Avoid_: backend, service


**Wrapper**:
A plugin `bin/*` script run via `run_command` (`ffgrep`, `fffind`, `hasline`, `agy-doctor`, `tfsearch`, `tffetch`). Native search/edit tools stay denied; wrappers are the only path.
_Avoid_: helper, util

**Deny hook**:
A PreToolUse hook answering `deny` with a reason pointing at the wrapper to use instead.
_Avoid_: blocker, guard

**Stream rule**:
A named `gate`/`ask`/`inject` entry in `stream-rules.json`, enforced by `stream-gate.sh` or `guidance-inject.sh`.
_Avoid_: filter, policy

**Guidance notice**:
A one-shot `ephemeralMessage` injected at PreInvocation, once per rule per conversation.
_Avoid_: hint, nudge
