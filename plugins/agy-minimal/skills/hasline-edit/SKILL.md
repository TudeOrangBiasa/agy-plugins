---
name: hasline-edit
description: Anchored file edits with hasline show and apply. Use when you need to modify files instead of the native write_to_file and replace_file_content tools.
---

# hasline-edit

Hashline edits: every change is anchored to a `[FILE#TAG]` snapshot so stale edits abort instead of corrupting.

## Steps

1. `hasline show FILE [START-END]`
   - Prints `[FILE#TAG]` header plus `N:content` numbered lines.
2. Compose a patch:
   - `[FILE#TAG]` header (exact tag from step 1).
   - `PUT N.=M:` + `+body` rows — replace lines N–M.
   - `PUT <N:` / `PUT >N:` + `+body` rows — insert before/after line N (`>$` = tail).
   - `CUT N.=M` — delete lines N–M (no body).
   - A lone `+` is an empty line. Numbers always refer to ORIGINAL lines.
3. `hasline apply PATCH`
   - Exit 0 applied, 1 bad op/bounds, 2 usage, 3 stale tag.
   - On exit 3: re-`show`, never guess the tag.

## Verify

- Re-`show` the file and confirm the new `#TAG` changed.
