#!/usr/bin/env bash
# Usage: bash hooks/scripts/guard-destructive-shell.test.sh
set -euo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/guard-destructive-shell.sh"
failures=0
HOOK_HEARTBEAT_DIR="$(mktemp -d)"
export HOOK_HEARTBEAT_DIR
trap 'rm -rf "$HOOK_HEARTBEAT_DIR"' EXIT

permission_for() {
  python3 -c 'import json,sys; print(json.dumps({"command": sys.argv[1]}))' "$1" \
    | bash "$HOOK" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["permission"])'
}

expect() {
  local want="$1" command="$2" got
  got="$(permission_for "$command")"
  if [[ "$got" != "$want" ]]; then
    echo "FAIL: want $want, got $got: $command"
    failures=$((failures + 1))
  fi
}

expect deny 'find / -name "queued-task*" -not -path "*/proc/*" 2>/dev/null | head'
expect deny 'cd repo && sudo find /System/Volumes/Data -name x'
expect deny 'find /Volumes/ -maxdepth 2'
expect deny 'du -sh /* 2>/dev/null'
expect deny 'ls -laR /Users'
expect deny 'rg -l needle /'
expect deny 'grep -rn needle /home'
expect deny 'LC_ALL=C /usr/bin/find /net -type f'

expect allow 'find . -name "*.ts" -not -path "*/node_modules/*"'
expect allow 'find ~/.cursor/projects -mmin -150 -type f'
expect allow 'find /Users/me/repo -name x'
expect allow 'ls -la /'
expect allow 'grep -n needle /etc/hosts'
expect allow 'rg -n "a|b" src/'
expect allow 'echo "find / is blocked"'

expect ask 'supabase db reset'

permission_for_payload() {
  printf '%s' "$1" | bash "$HOOK" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["permission"], d.get("agent_message", ""))'
}

gone="$HOOK_HEARTBEAT_DIR/removed-worktree"
got="$(permission_for_payload "{\"command\": \"ls\", \"cwd\": \"$gone\"}")"
if [[ "$got" != deny*"Workspace missing: $gone"* ]]; then
  echo "FAIL: missing cwd must deny with 'Workspace missing': $got"
  failures=$((failures + 1))
fi
got="$(permission_for_payload "{\"command\": \"ls\", \"workspace_roots\": [\"$gone\"]}")"
if [[ "$got" != deny*"Workspace missing"* ]]; then
  echo "FAIL: missing workspace root must deny: $got"
  failures=$((failures + 1))
fi
got="$(permission_for_payload "{\"command\": \"ls\", \"cwd\": \"$HOOK_HEARTBEAT_DIR\", \"workspace_roots\": [\"$gone\"]}")"
if [[ "$got" != allow* ]]; then
  echo "FAIL: existing cwd must allow even if the workspace root is gone: $got"
  failures=$((failures + 1))
fi

heartbeat_file="$HOOK_HEARTBEAT_DIR/beforeShellExecution.heartbeat"
permission_for 'echo heartbeat-probe' >/dev/null
permission_for 'echo other-agent' >/dev/null
if ! grep -qE $'^[0-9]+\techo heartbeat-probe$' "$heartbeat_file" 2>/dev/null; then
  echo "FAIL: heartbeat lost an earlier command: $heartbeat_file"
  failures=$((failures + 1))
fi

# Push gate: raw git push and gh pr need a fresh /ship-prod marker.
# Configured direct push scripts (fixture names stand in for the consumer's
# ship.direct_push list) are allowed only on the primary checkout's main.
# A script body of `git push` must not make that raw command allowed — the
# child push inside `npm run` is not the agent command.
MSG_PUSH='Pushes/PRs only via /ship-prod; land with /ship-local.'
MSG_SCRIPT='Direct push scripts only from the primary checkout on main.'

decide() {
  local cwd="$1" command="$2"
  python3 -c 'import json,sys; print(json.dumps({"command": sys.argv[1], "cwd": sys.argv[2]}))' "$command" "$cwd" \
    | bash "$HOOK"
}

permission_cwd() {
  decide "$1" "$2" | python3 -c 'import json,sys; print(json.load(sys.stdin)["permission"])'
}

message_cwd() {
  decide "$1" "$2" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("user_message", ""))'
}

expect_cwd() {
  local want="$1" cwd="$2" command="$3" got
  got="$(permission_cwd "$cwd" "$command")"
  if [[ "$got" != "$want" ]]; then
    echo "FAIL: want $want, got $got (cwd=$cwd): $command"
    failures=$((failures + 1))
  fi
}

expect_user_message() {
  local cwd="$1" command="$2" want="$3" got
  got="$(message_cwd "$cwd" "$command")"
  if [[ "$got" != "$want" ]]; then
    echo "FAIL: message $(printf '%q' "$got") != $(printf '%q' "$want"): $command"
    failures=$((failures + 1))
  fi
}

push_repo="$(mktemp -d)"
primary="$push_repo/primary"
linked="$push_repo/wt-linked"
mkdir -p "$primary"
git -C "$primary" init -q -b main
git -C "$primary" config user.email "push-gate@example.com"
git -C "$primary" config user.name "push-gate"
git -C "$primary" commit -q --allow-empty -m init
printf '%s\n' 'ship:' '  direct_push:' '    - ship:remote' '    - ship:docs' >"$primary/harness.project.yaml"
printf '%s\n' '{"scripts":{"ship:remote":"git push origin HEAD","ship:docs":"bash scripts/wrap.sh"}}' >"$primary/package.json"
git -C "$primary" worktree add -q -b feature "$linked" HEAD
cp "$primary/harness.project.yaml" "$primary/package.json" "$linked/"

expect_cwd allow "$primary" 'npm run ship:remote'
expect_cwd allow "$primary" 'npm run ship:docs -- --quiet'
expect_cwd allow "$primary" 'bash scripts/wrap.sh'
expect_cwd deny "$primary" 'git push origin HEAD'
expect_cwd deny "$primary" 'git push --force origin main'
expect_cwd deny "$primary" 'git push --force'
expect_cwd deny "$primary" 'gh pr create --fill'
expect_cwd deny "$primary" 'gh pr merge 12'
expect_user_message "$primary" 'git push origin main' "$MSG_PUSH"
expect_cwd allow "$primary" 'echo "git push origin main"'
expect_cwd allow "$primary" 'git status'
expect_cwd allow "$primary" 'gh pr list'
expect_cwd deny "$primary" 'bash -c "git push origin main"'
expect_cwd deny "$primary" 'python3 -c "import subprocess; subprocess.check_call([\"git\", \"push\"])"'
expect_cwd deny "$primary" 'npm run ship:remote && git push origin main'

expect_cwd deny "$linked" 'npm run ship:remote'
expect_cwd deny "$linked" 'npm run ship:docs'
expect_cwd deny "$linked" 'bash scripts/wrap.sh'
expect_user_message "$linked" 'npm run ship:remote' "$MSG_SCRIPT"
expect_cwd deny "$primary" "cd \"$linked\" && npm run ship:remote"
expect_cwd deny "$primary" "npm --prefix \"$linked\" run ship:docs"

git -C "$primary" checkout -q -b side
expect_cwd deny "$primary" 'npm run ship:remote'
expect_cwd deny "$primary" 'npm run ship:docs'
expect_user_message "$primary" 'npm run ship:docs' "$MSG_SCRIPT"
git -C "$primary" checkout -q main

marker_dir="$primary/.cursor/night-shift"
mkdir -p "$marker_dir"
marker="$marker_dir/ship-prod-push-gate"
echo $(( $(date +%s) + 3600 )) >"$marker"
expect_cwd allow "$primary" 'git push origin main'
expect_cwd allow "$primary" 'gh pr create'
expect_cwd allow "$primary" 'gh pr merge 3'
expect_cwd ask "$primary" 'git push --force origin main'
expect_cwd deny "$linked" 'git push origin feature'

echo $(( $(date +%s) - 30 )) >"$marker"
expect_cwd deny "$primary" 'git push origin main'
expect_cwd deny "$primary" 'gh pr create'
expect_user_message "$primary" 'gh pr merge 1' "$MSG_PUSH"

echo $(( $(date +%s) + 21600 + 120 )) >"$marker"
expect_cwd deny "$primary" 'git push origin main'

rm -f "$marker"
expect_cwd deny "$primary" "echo 1 > $primary/.cursor/night-shift/ship-prod-push-gate"

rm -rf "$push_repo"

if [[ "$failures" -gt 0 ]]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "guard-destructive-shell: all cases pass"
