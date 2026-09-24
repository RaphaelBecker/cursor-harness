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
# Overwriting GitHub issue bodies / closing issues.
if printf '%s' "$command" | grep -Eiq 'gh[[:space:]]+issue[[:space:]]+(edit|close|delete|lock)'; then
  ask=1
fi
# Force-push targeting main/master (order of flags/ref may vary).
if printf '%s' "$command" | grep -Eiq 'git[[:space:]]+push' \
  && printf '%s' "$command" | grep -Eiq -- '--force(--with-lease)?|[[:space:]]-f[[:space:]]|[[:space:]]-f$' \
  && printf '%s' "$command" | grep -Eiq '(^|[[:space:]/])(main|master)([[:space:]]|$)'; then
  ask=1
fi

# Filesystem-wide scans walk the /home autofs mount (and any share under
# /Volumes); macOS then shows a "network volume" access prompt for the IDE.
# Deny instead of ask so unattended agents re-scope without a human.
root_scan=$(printf '%s' "$command" | python3 -c '
import re, shlex, sys
ROOTS = {"/", "/*", "/Users", "/Volumes", "/System/Volumes", "/System/Volumes/Data",
         "/home", "/net", "/Network"}
SCANNERS = {"find", "du", "rg", "grep", "egrep", "ls", "tree", "fd", "locate"}
WRAPPERS = {"sudo", "time", "nice", "command", "exec", "xargs"}
def is_root(arg):
    if arg in ("/", "/*"):
        return True
    stripped = arg.rstrip("/")
    return stripped in ROOTS or stripped.removesuffix("/*") in ROOTS
for segment in re.split(r"[;&|\n()]+", sys.stdin.read()):
    try:
        words = shlex.split(segment)
    except ValueError:
        words = segment.split()
    while words and (words[0] in WRAPPERS or re.match(r"^\w+=", words[0])):
        words = words[1:]
    if not words or words[0].rsplit("/", 1)[-1] not in SCANNERS:
        continue
    name, args = words[0].rsplit("/", 1)[-1], words[1:]
    if name == "ls" and not any(a.startswith("-") and "R" in a for a in args):
        continue
    if name in ("grep", "egrep") and not any(re.match(r"^-\w*[rR]|^--(recursive|dereference-recursive)$", a) for a in args):
        continue
    if any(is_root(a) for a in args if not a.startswith("-")):
        print(1)
        break
' 2>/dev/null || true)

if [[ "$root_scan" == "1" ]]; then
  cat <<'JSON'
{
  "permission": "deny",
  "user_message": "Blocked a filesystem-wide scan (from /, /Users, /Volumes, /System/Volumes, or /home). It triggers the macOS network-volume prompt.",
  "agent_message": "Blocked: do not scan from /, /Users, /Volumes, /System/Volumes, or /home. On macOS that walks the /home automount and shows the user a network-volume permission prompt. Search the repo or worktree root, or read a known absolute path. A Cursor Project store path /cursor/stores/<id>/... lives on macOS at \"$HOME/Library/Application Support/Cursor/AgentStores/cursor_agent_stores/<id>/files/...\"."
}
JSON
  exit 0
fi

if [[ "$ask" -eq 1 ]]; then
  cat <<'JSON'
{
  "permission": "ask",
  "user_message": "This command can destroy data, overwrite GitHub issue text, rewrite a remote database, or force-push to a protected branch. Confirm only if you intend this.",
  "agent_message": "Blocked pending confirmation: a destructive or prod-affecting command was detected. Prefer versioned migrations, non-destructive workflows, and normal (non-force) pushes. Never reset or push schema to production, or overwrite GitHub issues, without explicit human intent."
}
JSON
  exit 0
fi

echo '{ "permission": "allow" }'
exit 0
