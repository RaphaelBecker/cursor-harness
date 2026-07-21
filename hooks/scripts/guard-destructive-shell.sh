#!/usr/bin/env bash
# beforeShellExecution guard: require human confirmation for destructive or
# prod-affecting shell commands. failClosed=true in hooks.json: if this script
# errors, the command is blocked.
set -uo pipefail

input=$(cat)
command=$(printf '%s' "$input" | python3 -c 'import json,sys; data=json.load(sys.stdin); print(data.get("command") or "")' 2>/dev/null || true)

# Patterns that must never run silently.
ask=0
if printf '%s' "$command" | grep -Eiq \
  'supabase[[:space:]]+db[[:space:]]+(reset|push)|prisma[[:space:]]+migrate[[:space:]]+reset|drop[[:space:]]+database'; then
  ask=1
fi
# Force-push targeting main/master (order of flags/ref may vary).
if printf '%s' "$command" | grep -Eiq 'git[[:space:]]+push' \
  && printf '%s' "$command" | grep -Eiq -- '--force(--with-lease)?|[[:space:]]-f[[:space:]]|[[:space:]]-f$' \
  && printf '%s' "$command" | grep -Eiq '(^|[[:space:]/])(main|master)([[:space:]]|$)'; then
  ask=1
fi

if [[ "$ask" -eq 1 ]]; then
  cat <<'JSON'
{
  "permission": "ask",
  "user_message": "This command can destroy data, rewrite a remote database, or force-push to a protected branch. Confirm only if you intend this.",
  "agent_message": "Blocked pending confirmation: a destructive or prod-affecting command was detected. Prefer versioned migrations, non-destructive workflows, and normal (non-force) pushes. Never reset or push schema to production without explicit human intent."
}
JSON
  exit 0
fi

echo '{ "permission": "allow" }'
exit 0
