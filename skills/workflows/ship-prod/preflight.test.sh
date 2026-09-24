#!/usr/bin/env bash
# Usage: bash skills/workflows/ship-prod/preflight.test.sh
set -euo pipefail

PREFLIGHT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
failures=0

export PREFLIGHT_ROOT="$tmp" PREFLIGHT_SKIP_GH=1 HOOK_HEARTBEAT_DIR="$tmp/hb"
mkdir -p "$tmp/.cursor/hooks" "$tmp/.cursor/agents" "$HOOK_HEARTBEAT_DIR"
printf 'test:\n  full: npm run test:all\nship:\n  leftovers: npm run leftovers\n' >"$tmp/harness.project.yaml"
printf '{"hooks":{"beforeShellExecution":[{"command":"bash .cursor/hooks/guard-destructive-shell.sh"}]}}\n' >"$tmp/.cursor/hooks.json"
touch "$tmp/.cursor/hooks/guard-destructive-shell.sh" "$tmp/.cursor/agents/diff-review.md"

beat() {
  printf '%s\tbash .cursor/skills/workflows/ship-prod/preflight.sh --subagents x\n%s\tcd other-tree && rg foo\n' \
    "$1" "$(date +%s)" >"$HOOK_HEARTBEAT_DIR/beforeShellExecution.heartbeat"
}

check() {
  local name="$1" want_exit="$2" want_text="$3"; shift 3
  local out code=0
  out="$(bash "$PREFLIGHT" "$@" 2>&1)" || code=$?
  if [[ "$code" != "$want_exit" ]] || ! grep -qF -- "$want_text" <<<"$out"; then
    echo "FAIL: $name (exit $code, want $want_exit, want text: $want_text)"
    echo "$out" | sed 's/^/    /'
    failures=$((failures + 1))
  fi
}

beat "$(date +%s)"
check "builtins present" 0 "subagent bugbot" --subagents "bugbot, security-review, ci-investigator"
check "self-hosted inline fallback" 0 "inline: run .cursor/agents/diff-review.md, Focus: bugs" --subagents "explore,verifier"
check "diff-review subagent fallback" 0 "subagent diff-review, Focus: security" --subagents "diff-review"
check "no subagent flag" 1 "PARTIAL: missing subagent list"

rm "$tmp/.cursor/agents/diff-review.md"
check "no reviewer at all" 1 "PARTIAL: missing bugbot" --subagents "none"
touch "$tmp/.cursor/agents/diff-review.md"

beat "$(( $(date +%s) - 600 ))"
check "stale heartbeat" 1 "shell guard hook (did not fire" --subagents "bugbot,security-review"

beat "$(date +%s)"
rm "$tmp/.cursor/hooks/guard-destructive-shell.sh"
check "dangling hook script" 1 "beforeShellExecution:.cursor/hooks/guard-destructive-shell.sh" --subagents "bugbot,security-review"

if [[ "$failures" -gt 0 ]]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "ship-prod preflight: all cases pass"
