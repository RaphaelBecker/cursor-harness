#!/usr/bin/env bash
# beforeSubmitPrompt hook: flag prompts that look like they contain secrets.
set -euo pipefail

input=$(cat)
prompt=$(printf '%s' "$input" | python3 -c 'import json,sys; data=json.load(sys.stdin); print(data.get("prompt") or data.get("text") or "")')

# Lightweight heuristics — fail open unless a strong pattern matches.
patterns=(
  '-----BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY-----'
  'AKIA[0-9A-Z]{16}'
  'ghp_[A-Za-z0-9]{36}'
  'github_pat_[A-Za-z0-9_]{20,}'
  'xox[baprs]-[A-Za-z0-9-]{10,}'
  'sk-[A-Za-z0-9]{20,}'
  'sk_live_[A-Za-z0-9]{20,}'
  'sk_test_[A-Za-z0-9]{20,}'
)

matched=""
for pattern in "${patterns[@]}"; do
  if printf '%s' "$prompt" | grep -Eiq -- "$pattern"; then
    matched="$pattern"
    break
  fi
done

if [[ -n "$matched" ]]; then
  python3 - <<'PY'
import json
print(json.dumps({
  "continue": True,
  "user_message": "Possible secret detected in the prompt. Review before sending.",
  "agent_message": "A cursor-harness hook flagged a possible secret pattern in the user prompt. Do not echo or store the secret; ask the user to rotate if it was real."
}))
PY
  exit 0
fi

echo '{}'
exit 0
