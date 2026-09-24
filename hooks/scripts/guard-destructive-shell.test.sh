#!/usr/bin/env bash
# Usage: bash hooks/scripts/guard-destructive-shell.test.sh
set -euo pipefail

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/guard-destructive-shell.sh"
failures=0

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

if [[ "$failures" -gt 0 ]]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "guard-destructive-shell: all cases pass"
