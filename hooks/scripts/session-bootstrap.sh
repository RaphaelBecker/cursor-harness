#!/usr/bin/env bash
# sessionStart hook: remind the agent that cursor-harness packs are installed.
set -euo pipefail

# Consume stdin JSON from Cursor (required even if unused).
cat >/dev/null

additional_context='cursor-harness is installed. Follow core-principles lifecycle (day-shift plan contract → night-shift execute-approved-plan for Phases 2-5). Route docs via doc-routing. Use project-memory for Phase 1 load / Phase 7 consolidate; implementation-plan-review + grill-me for planning; review-code for Phase 4b; sync-spec-docs for Phase 5. Never push/merge/deploy without an explicit human request.'

# Escape for JSON string
escaped=$(printf '%s' "$additional_context" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

printf '{"additional_context": %s}\n' "$escaped"
exit 0
