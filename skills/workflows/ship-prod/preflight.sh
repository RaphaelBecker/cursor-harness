#!/usr/bin/env bash
# ship-prod preflight: list every capability the ship needs and how this session
# resolves it. Exit 1 with a PARTIAL line when a required piece has no fallback,
# so nothing is skipped silently.
#
# Usage: bash .cursor/skills/workflows/ship-prod/preflight.sh \
#          --subagents "<comma list of subagent types your Task tool offers, or none>"
#
# Subagent types are only visible to the agent, so the agent passes them in.
# Env: PREFLIGHT_SKIP_GH=1 (tests), HOOK_HEARTBEAT_DIR (tests), PREFLIGHT_ROOT.
set -uo pipefail

SUBAGENTS=""
HAVE_SUBAGENT_FLAG=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --subagents) SUBAGENTS="${2:-}"; HAVE_SUBAGENT_FLAG=1; shift 2 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

ROOT="${PREFLIGHT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
HEARTBEAT="${HOOK_HEARTBEAT_DIR:-$ROOT/.cursor/hooks/.cache}/beforeShellExecution.heartbeat"
missing=()

row() { printf '  %-22s %-9s %s\n' "$1" "$2" "$3"; }
need() { row "$1" "MISSING" "$2"; missing+=("$1 ($2)"); }

has_subagent() {
  [[ ",$(tr -d ' ' <<<"$SUBAGENTS")," == *",$1,"* ]]
}

echo "ship-prod preflight — $ROOT"

if [[ "$HAVE_SUBAGENT_FLAG" -eq 0 ]]; then
  need "subagent list" "pass --subagents with the types your Task tool offers (or none)"
fi

yaml="$ROOT/harness.project.yaml"
if [[ -f "$yaml" ]]; then
  for key in full leftovers; do
    value=$(grep -E "^[[:space:]]+${key}:" "$yaml" | head -1 | sed -E 's/^[^:]+:[[:space:]]*//')
    if [[ -n "$value" ]]; then
      row "yaml $key" "ok" "$value"
    elif [[ "$key" == full ]]; then
      need "yaml test.full" "idle-main complete gate is undeclared"
    else
      row "yaml ship.leftovers" "fallback" "portable leftover steps in SKILL.md"
    fi
  done
else
  need "harness.project.yaml" "required consumer interface"
fi

hooks_json="$ROOT/.cursor/hooks.json"
if [[ -f "$hooks_json" ]]; then
  broken=$(python3 - "$hooks_json" "$ROOT" <<'PY'
import json, os, shlex, sys
hooks = json.load(open(sys.argv[1])).get("hooks", {})
for event, entries in hooks.items():
    for entry in entries:
        words = shlex.split(entry.get("command", ""))
        script = next((w for w in words if w.endswith((".sh", ".py"))), None)
        if script and not os.path.isfile(os.path.join(sys.argv[2], script)):
            print(f"{event}:{script}")
PY
  )
  if [[ -n "$broken" ]]; then
    need "hook scripts" "missing or dangling: $(tr '\n' ' ' <<<"$broken")"
  else
    row "hook scripts" "ok" "every hooks.json command resolves"
  fi
  if grep -q 'guard-destructive-shell' "$hooks_json"; then
    fired=0
    if [[ -f "$HEARTBEAT" ]]; then
      stamp=$(head -1 "$HEARTBEAT")
      if [[ "$stamp" =~ ^[0-9]+$ ]] && (( $(date +%s) - stamp <= 120 )) \
        && tail -n +2 "$HEARTBEAT" | grep -q 'preflight\.sh'; then
        fired=1
      fi
    fi
    if [[ "$fired" -eq 1 ]]; then
      row "shell guard hook" "fired" "beforeShellExecution saw this preflight command"
    else
      need "shell guard hook" "did not fire for this command — hooks are off in this session type"
    fi
  fi
else
  need ".cursor/hooks.json" "no hooks installed"
fi

resolve_reviewer() {
  local builtin="$1" focus="$2"
  if has_subagent "$builtin"; then
    row "$builtin" "ok" "subagent $builtin"
  elif has_subagent diff-review; then
    row "$builtin" "fallback" "subagent diff-review, Focus: $focus"
  elif [[ -f "$ROOT/.cursor/agents/diff-review.md" ]]; then
    row "$builtin" "fallback" "inline: run .cursor/agents/diff-review.md, Focus: $focus"
  else
    need "$builtin" "no subagent and no .cursor/agents/diff-review.md to run inline"
  fi
}
resolve_reviewer bugbot bugs
resolve_reviewer security-review security

if has_subagent ci-investigator; then
  row "ci-investigator" "ok" "subagent ci-investigator"
else
  row "ci-investigator" "fallback" "inline: gh run view --log-failed"
fi

if [[ "${PREFLIGHT_SKIP_GH:-0}" != "1" ]]; then
  if gh auth status >/dev/null 2>&1; then
    row "gh auth" "ok" "authenticated"
  else
    need "gh auth" "gh auth status failed (retry outside the sandbox first)"
  fi
fi

if [[ ${#missing[@]} -gt 0 ]]; then
  printf 'PARTIAL: missing %s\n' "$(IFS=';'; echo "${missing[*]}")"
  exit 1
fi
echo "preflight: OK — use the resolutions above; do not skip any row"
