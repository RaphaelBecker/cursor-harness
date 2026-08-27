#!/usr/bin/env bash
# sessionStart hook: remind the agent that cursor-harness packs are installed.
set -euo pipefail

# Consume stdin JSON from Cursor (required even if unused).
cat >/dev/null

additional_context='cursor-harness is installed. Inventory: .cursor/HARNESS.md (/help, /glossary). Domain overlay: .cursor/HARNESS.local.md when present. Project interface: harness.project.yaml. Prep (anytime, ~2h max): /prep packet grill → plan review → approve contract in a human-created Cursor worktree. Nightshift: Cursor Build or night-shift fire → execute-approved-plan (park BLOCKED.md, never wait). After: /ship-local (worktree) or leftover-commit on default, then /ship-prod. Agents do not create worktrees. Never remote push/deploy without an explicit human request. Chat last line DONE or PARTIAL.'

# Escape for JSON string
escaped=$(printf '%s' "$additional_context" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

printf '{"additional_context": %s}\n' "$escaped"
exit 0
