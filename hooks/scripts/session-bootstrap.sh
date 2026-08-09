#!/usr/bin/env bash
# sessionStart hook: remind the agent that cursor-harness packs are installed.
set -euo pipefail

# Consume stdin JSON from Cursor (required even if unused).
cat >/dev/null

additional_context='cursor-harness is installed. Inventory: .cursor/HARNESS.md (/help, /glossary). Day shift: auto grill-me → draft plan → human implementation-plan-review → approve. Night shift: execute-approved-plan (BDD → testing-rule ladder → review-code 4b → review-bugbot 4c → sync-spec-docs → Lessons learned → Phase 5 Candidates). Ship: human /ship-local then /ship-prod. Agents do not manage git branches except during /ship-local. Never remote push/deploy without an explicit human request.'

# Escape for JSON string
escaped=$(printf '%s' "$additional_context" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

printf '{"additional_context": %s}\n' "$escaped"
exit 0
