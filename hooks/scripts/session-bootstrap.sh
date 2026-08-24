#!/usr/bin/env bash
# sessionStart hook: remind the agent that cursor-harness packs are installed.
set -euo pipefail

# Consume stdin JSON from Cursor (required even if unused).
cat >/dev/null

additional_context='cursor-harness is installed. Inventory: .cursor/HARNESS.md (/help, /glossary). Domain overlay: .cursor/HARNESS.local.md when present. Project interface: harness.project.yaml. Prep (anytime, ~2h max): /prep packet grill → plan review → approve contract in a human-created Cursor worktree. Nightshift: night-shift fire → execute-approved-plan unattended (park BLOCKED.md, never wait). After: night-shift status + manual tests, then /ship-local /ship-prod. Agents do not create worktrees. Never remote push/deploy without an explicit human request.'

# Escape for JSON string
escaped=$(printf '%s' "$additional_context" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

printf '{"additional_context": %s}\n' "$escaped"
exit 0
