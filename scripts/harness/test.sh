#!/usr/bin/env bash
# shellcheck disable=SC2015,SC2016  # ok/bad exit 0 (safe &&/||); $(...) in payloads is literal test data.
# test.sh — full functional tests for wrappers + hook + contracts.
set -euo pipefail
root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$root_dir"
PBIN="plugins/agy-minimal/bin"
fail=0
ok() { echo "[ok] $1"; }
bad() { echo "[fail] $1" >&2; fail=1; }

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/sub"
printf 'hello agy-minimal world\nsecond line\n' > "$fixture/a.txt"
printf 'nothing here\n' > "$fixture/sub/b.txt"

# ffgrep: hit
out=$("$PBIN/ffgrep" "agy-minimal" "$fixture")
echo "$out" | grep -q "a.txt:1:hello agy-minimal world" && ok "ffgrep hit contract" || bad "ffgrep hit contract: $out"

# ffgrep: no hit -> exit 1, empty stdout
set +e
out=$("$PBIN/ffgrep" "zzz-no-match" "$fixture" 2>/dev/null)
code=$?
set -e
[ "$code" -eq 1 ] && [ -z "$out" ] && ok "ffgrep no-hit exit 1" || bad "ffgrep no-hit (code=$code out=$out)"

# ffgrep: usage guard -> exit 2
set +e
"$PBIN/ffgrep" >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ] && ok "ffgrep usage guard" || bad "ffgrep usage guard (code=$code)"

# fffind: finds by name
out=$("$PBIN/fffind" "a.txt" "$fixture")
echo "$out" | grep -q "a.txt" && ok "fffind hit" || bad "fffind hit: $out"

# fffind: usage guard -> exit 2
set +e
"$PBIN/fffind" >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ] && ok "fffind usage guard" || bad "fffind usage guard (code=$code)"

# hook: deny JSON contract
out=$(echo '{"tool":"grep_search"}' | "$PBIN/block-native-search.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "hook deny decision" || bad "hook deny: $out"
echo "$out" | grep -q "ffgrep" && ok "hook reason mentions ffgrep" || bad "hook reason: $out"

# hook: works with empty stdin too
out=$("$PBIN/block-native-search.sh" < /dev/null)
echo "$out" | grep -q '"decision":"deny"' && ok "hook empty-stdin" || bad "hook empty-stdin: $out"

# edit hook: deny JSON contract
out=$(echo '{"tool":"write_to_file"}' | "$PBIN/block-native-edit.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "edit hook deny decision" || bad "edit hook deny: $out"
echo "$out" | grep -q "hasline" && ok "edit hook reason mentions hasline" || bad "edit hook reason: $out"

# hasline: show/apply round-trip
printf 'alpha\nbeta\ngamma\n' > "$fixture/h.txt"
htag=$("$PBIN/hasline" show "$fixture/h.txt" | head -n 1)
echo "$htag" | grep -qE '^\[.+#([0-9A-F]{4})\]$' && ok "hasline show header" || bad "hasline show header: $htag"
printf '%s\nPUT 2.=2:\n+BETA\n' "$htag" > "$fixture/h.patch"
"$PBIN/hasline" apply "$fixture/h.patch" >/dev/null && ok "hasline apply" || bad "hasline apply failed"
grep -q "^BETA$" "$fixture/h.txt" && ok "hasline apply content" || bad "hasline apply content wrong"

# hasline: stale tag aborts exit 3
set +e
"$PBIN/hasline" apply "$fixture/h.patch" >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 3 ] && ok "hasline stale guard" || bad "hasline stale guard (code=$code)"

# hasline: usage guard -> exit 2
set +e
"$PBIN/hasline" >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ] && ok "hasline usage guard" || bad "hasline usage guard (code=$code)"

# tfsearch/tffetch: usage + missing-key guards (no network)
set +e
"$PBIN/tfsearch" >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ] && ok "tfsearch usage guard" || bad "tfsearch usage guard (code=$code)"
set +e
"$PBIN/tffetch" >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ] && ok "tffetch usage guard" || bad "tffetch usage guard (code=$code)"
set +e
env -u TINYFISH_API_KEY "$PBIN/tfsearch" "probe-query-zzz" >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ] && ok "tfsearch missing-key guard" || bad "tfsearch missing-key guard (code=$code)"
set +e
env -u TINYFISH_API_KEY "$PBIN/tffetch" "https://example.com" >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ] && ok "tffetch missing-key guard" || bad "tffetch missing-key guard (code=$code)"

# agy-doctor: passes in repo, usage guard on args (no network, writes nothing)
out=$("$PBIN/agy-doctor") && ok "agy-doctor passes in repo" || bad "agy-doctor failed in repo: $out"
echo "$out" | grep -q "doctor passed" && ok "agy-doctor output contract" || bad "agy-doctor output: $out"
set +e
"$PBIN/agy-doctor" --bogus-flag >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ] && ok "agy-doctor usage guard" || bad "agy-doctor usage guard (code=$code)"

# bypass hook: denies raw search/edit in run_command, allows the rest
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"rg foo src"}}}' | "$PBIN/block-bash-bypass.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "bypass deny rg" || bad "bypass deny rg: $out"
echo "$out" | grep -q "ffgrep" && ok "bypass reason points at wrapper" || bad "bypass reason: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"grep -rn x src"}}}' | "$PBIN/block-bash-bypass.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "bypass deny recursive grep" || bad "bypass deny grep -r: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"grep -R x src"}}}' | "$PBIN/block-bash-bypass.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "bypass deny grep -R" || bad "bypass deny grep -R: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"sed -i s/a/b/ f"}}}' | "$PBIN/block-bash-bypass.sh")
echo "$out" | grep -q '"decision":"deny"' && echo "$out" | grep -q "hasline" && ok "bypass deny sed -i" || bad "bypass deny sed -i: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"make ci"}}}' | "$PBIN/block-bash-bypass.sh")
[ "$out" = "{}" ] && ok "bypass allow plain command" || bad "bypass allow make: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"agy agents | grep -q agy-minimal"}}}' | "$PBIN/block-bash-bypass.sh")
[ "$out" = "{}" ] && ok "bypass allow pipe grep" || bad "bypass allow pipe grep: $out"
out=$("$PBIN/block-bash-bypass.sh" < /dev/null)
[ "$out" = "{}" ] && ok "bypass allow empty stdin" || bad "bypass empty stdin: $out"

out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"ffgrep rg ."}}}' | "$PBIN/block-bash-bypass.sh")
[ "$out" = "{}" ] && ok "bypass allow wrapper-headed segment" || bad "bypass wrapper-headed: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"ffgrep foo .; rg bar ."}}}' | "$PBIN/block-bash-bypass.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "bypass deny raw after wrapper" || bad "bypass raw-after-wrapper: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"echo $(rg foo)"}}}' | "$PBIN/block-bash-bypass.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "bypass deny command substitution" || bad "bypass cmdsubst: $out"
out=$(python3 -c 'import json; print(json.dumps({"toolCall": {"name": "run_command", "args": {"CommandLine": "echo \x27use sed -i never\x27"}}}))' | "$PBIN/block-bash-bypass.sh")
[ "$out" = "{}" ] && ok "bypass allow quoted prose" || bad "bypass quoted prose: $out"
out=$(python3 -c 'import json; print(json.dumps({"toolCall": {"name": "run_command", "args": {"CommandLine": "cat > /tmp/p.patch <<EOF\nraw sed -i docs\nEOF"}}}))' | "$PBIN/block-bash-bypass.sh")
[ "$out" = "{}" ] && ok "bypass allow heredoc prose" || bad "bypass heredoc prose: $out"

out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"ls -d */"}}}' | "$PBIN/block-bash-bypass.sh")
[ "$out" = "{}" ] && ok "bypass allow ls -d" || bad "bypass ls -d: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"ls -R src"}}}' | "$PBIN/block-bash-bypass.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "bypass deny ls -R" || bad "bypass ls -R: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"find . -name x"}}}' | "$PBIN/block-bash-bypass.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "bypass deny find" || bad "bypass find: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"find . -maxdepth 1 -name x"}}}' | "$PBIN/block-bash-bypass.sh")
[ "$out" = "{}" ] && ok "bypass allow bounded find" || bad "bypass bounded find: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"tree src"}}}' | "$PBIN/block-bash-bypass.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "bypass deny tree" || bad "bypass tree: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"ls -la"}}}' | "$PBIN/block-bash-bypass.sh")
[ "$out" = "{}" ] && ok "bypass allow plain ls" || bad "bypass plain ls: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"ls /tmp"}}}' | "$PBIN/block-bash-bypass.sh")
[ "$out" = "{}" ] && ok "bypass allow ls path" || bad "bypass ls path: $out"

# stream-gate: named TTSR-style rules (rm guard, secrets, scope, fail-open)
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"rm -rf /"}}}' | "$PBIN/stream-gate.sh")
echo "$out" | grep -q '"decision":"deny"' && echo "$out" | grep -q "gate-rm-rf-root" && ok "stream deny rm -rf /" || bad "stream rm: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"rm -rf /tmp/x"}}}' | "$PBIN/stream-gate.sh")
[ "$out" = "{}" ] && ok "stream allow rm /tmp" || bad "stream rm /tmp: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"rm -rf ./build"}}}' | "$PBIN/stream-gate.sh")
[ "$out" = "{}" ] && ok "stream allow rm relative" || bad "stream rm relative: $out"
# NOTE: sk-ant-AbCdEf1234567890 below is a synthetic fixture vector, not a real key.
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"export K=sk-ant-AbCdEf1234567890"}}}' | "$PBIN/stream-gate.sh")
echo "$out" | grep -q '"decision":"deny"' && echo "$out" | grep -q "gate-secret-in-args" && ok "stream deny secret" || bad "stream secret: $out"
out=$(printf '{"toolCall":{"name":"grep_search","args":{"pattern":"foo"}}}' | "$PBIN/stream-gate.sh")
[ "$out" = "{}" ] && ok "stream allow other tool" || bad "stream other tool: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"rm -rf /"}}}' | STREAM_RULES=/nonexistent.json "$PBIN/stream-gate.sh")
[ "$out" = "{}" ] && ok "stream allow missing rules" || bad "stream missing rules: $out"
python3 -c 'import json,sys; open(sys.argv[1]+"/sr.json","w").write(json.dumps({"rules":[{"name":"off","type":"gate","scope":["pre_tool_use"],"enabled":False,"matcher":".*","pattern":"rm","reason":"x"}]}))' "$fixture"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"rm -rf /"}}}' | STREAM_RULES="$fixture/sr.json" "$PBIN/stream-gate.sh")
[ "$out" = "{}" ] && ok "stream skip disabled rule" || bad "stream disabled: $out"

out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"export API_KEY=abc123"}}}' | "$PBIN/stream-gate.sh")
echo "$out" | grep -q '"decision":"deny"' && echo "$out" | grep -q "gate-secret-assignment" && ok "stream deny secret assignment" || bad "stream secret assign: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"grep password file"}}}' | "$PBIN/stream-gate.sh")
[ "$out" = "{}" ] && ok "stream allow secret mention" || bad "stream secret mention: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"rm -rf /"}}}' | "$PBIN/stream-gate.sh")
echo "$out" | grep -q '"decision":"deny"' || bad "stream repeat 1: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"rm -rf /"}}}' | "$PBIN/stream-gate.sh")
echo "$out" | grep -q '"decision":"deny"' || bad "stream repeat 2: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"rm -rf /"}}}' | "$PBIN/stream-gate.sh")
echo "$out" | grep -q '"decision":"deny"' && ok "stream deny stable 3x" || bad "stream repeat 3: $out"

out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"git push --force origin main"}}}' | "$PBIN/stream-gate.sh")
echo "$out" | grep -q '"decision":"deny"' && echo "$out" | grep -q "gate-git-force-push" && ok "stream deny force push" || bad "stream force: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"git reset --hard HEAD"}}}' | "$PBIN/stream-gate.sh")
echo "$out" | grep -q '"decision":"deny"' && echo "$out" | grep -q "gate-git-hard-reset" && ok "stream deny hard reset" || bad "stream reset: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"git checkout ."}}}' | "$PBIN/stream-gate.sh")
echo "$out" | grep -q '"decision":"deny"' && echo "$out" | grep -q "gate-git-discard" && ok "stream deny discard" || bad "stream discard: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"git push origin main"}}}' | "$PBIN/stream-gate.sh")
echo "$out" | grep -q '"decision":"ask"' && echo "$out" | grep -q "gate-git-protected-push" && ok "stream ask protected push" || bad "stream protected: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"git push -u origin feat/x"}}}' | "$PBIN/stream-gate.sh")
[ "$out" = "{}" ] && ok "stream allow feature push" || bad "stream feature push: $out"
out=$(printf '{"toolCall":{"name":"run_command","args":{"CommandLine":"git checkout -b feat"}}}' | "$PBIN/stream-gate.sh")
[ "$out" = "{}" ] && ok "stream allow checkout branch" || bad "stream checkout: $out"

# guidance-inject: transcript-triggered ts-no-any notice, once per conversation
mkdir -p "$fixture/gstate"
printf '%s\n' '{"step_index":10,"tool_calls":[{"name":"run_command","args":{"CommandLine":"cat > /tmp/p.patch <<EOF\n[a.ts#AB12]\nPUT 1.=1:\n+let x: any\nEOF"}}]}' > "$fixture/tr.jsonl"
out=$(printf '%s' "{\"conversationId\":\"convA\",\"transcriptPath\":\"$fixture/tr.jsonl\"}" | GUIDANCE_STATE_DIR="$fixture/gstate" "$PBIN/guidance-inject.sh")
echo "$out" | grep -q "ts-no-any" && echo "$out" | grep -q "injectSteps" && ok "guide injects ts-no-any" || bad "guide inject: $out"
out=$(printf '%s' "{\"conversationId\":\"convA\",\"transcriptPath\":\"$fixture/tr.jsonl\"}" | GUIDANCE_STATE_DIR="$fixture/gstate" "$PBIN/guidance-inject.sh")
[ "$out" = "{}" ] && ok "guide dedupes per conversation" || bad "guide dedupe: $out"
out=$(printf '%s' "{\"conversationId\":\"convB\",\"transcriptPath\":\"$fixture/tr.jsonl\"}" | GUIDANCE_STATE_DIR="$fixture/gstate" "$PBIN/guidance-inject.sh")
echo "$out" | grep -q "ts-no-any" && ok "guide fires per conversation" || bad "guide convB: $out"
printf '%s\n' '{"step_index":11,"tool_calls":[{"name":"run_command","args":{"CommandLine":"ls /tmp"}}]}' > "$fixture/tr2.jsonl"
out=$(printf '%s' "{\"conversationId\":\"convC\",\"transcriptPath\":\"$fixture/tr2.jsonl\"}" | GUIDANCE_STATE_DIR="$fixture/gstate" "$PBIN/guidance-inject.sh")
[ "$out" = "{}" ] && ok "guide quiet without match" || bad "guide quiet: $out"
out=$(printf '%s' '{"conversationId":"convD","transcriptPath":"/nonexistent.jsonl"}' | GUIDANCE_STATE_DIR="$fixture/gstate" "$PBIN/guidance-inject.sh")
[ "$out" = "{}" ] && ok "guide fail-open missing transcript" || bad "guide missing: $out"

if [ "$fail" -ne 0 ]; then echo "tests FAILED" >&2; exit 1; fi
echo "all tests passed."
