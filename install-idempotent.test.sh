#!/usr/bin/env bash
# Prove re-running install.sh leaves a project's hooks.json byte-identical,
# including when tracked domain wrappers already call the harness hooks.
set -euo pipefail

HARNESS="$(cd "$(dirname "$0")" && pwd)"
fails=0
pass() { echo "ok - $1"; }
fail() { echo "not ok - $1" >&2; fails=$((fails + 1)); }

ROOT="$(mktemp -d "${TMPDIR:-/tmp}/harness-idem.XXXXXX")"
trap 'rm -rf "$ROOT"' EXIT

new_project() {
  local dest="$1"
  mkdir -p "$dest/vendor" "$dest/.cursor/hooks"
  ln -s "$HARNESS" "$dest/vendor/cursor-harness"
  cp "$HARNESS/templates/harness.project.yaml" "$dest/harness.project.yaml"
}
install_into() { "$HARNESS/install.sh" --target "$1" --mode symlink >/dev/null; }
wrapper() {
  printf '#!/usr/bin/env bash\nbash "$(dirname "$0")/%s"\n' "$2" >"$1/.cursor/hooks/$3"
}
count() { grep -c "\"command\": \"$2\"" "$1/.cursor/hooks.json" || true; }

# Every harness hook is wrapped by a tracked domain script.
p="$ROOT/wrapped"
new_project "$p"
wrapper "$p" session-bootstrap.sh session-domain.sh
wrapper "$p" protect-secrets-prompt.sh secrets-domain.sh
wrapper "$p" guard-destructive-shell.sh guard-domain.sh
wrapper "$p" context-governor.sh governor-domain.sh
cat >"$p/.cursor/hooks.json" <<'EOF'
{
  "version": 1,
  "hooks": {
    "sessionStart": [
      {
        "command": "bash .cursor/hooks/session-domain.sh"
      }
    ],
    "beforeSubmitPrompt": [
      {
        "command": "bash .cursor/hooks/secrets-domain.sh"
      }
    ],
    "beforeShellExecution": [
      {
        "command": "bash .cursor/hooks/guard-domain.sh",
        "failClosed": true
      }
    ],
    "postToolUse": [
      {
        "command": "bash .cursor/hooks/governor-domain.sh"
      }
    ],
    "preCompact": [
      {
        "command": "bash .cursor/hooks/governor-domain.sh"
      }
    ],
    "stop": [
      {
        "command": "bash .cursor/hooks/governor-domain.sh"
      }
    ]
  }
}
EOF
cp "$p/.cursor/hooks.json" "$ROOT/wrapped.orig"
install_into "$p"
install_into "$p"
if diff -u "$ROOT/wrapped.orig" "$p/.cursor/hooks.json"; then
  pass "wrapped project: two installs leave hooks.json unchanged"
else
  fail "wrapped project: install added vendor entries next to wrappers"
fi

# Stale duplicates from an older install are dropped when a wrapper covers them.
python3 - "$p/.cursor/hooks.json" <<'PY'
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
d["hooks"]["postToolUse"].append({"command": ".cursor/hooks/context-governor.sh"})
p.write_text(json.dumps(d, indent=2) + "\n")
PY
install_into "$p"
if diff -q "$ROOT/wrapped.orig" "$p/.cursor/hooks.json" >/dev/null; then
  pass "wrapped project: stale vendor duplicate is removed"
else
  fail "wrapped project: stale vendor duplicate survived"
fi

# Plain project: harness entries added once, then stable; custom entries keep order.
p="$ROOT/plain"
new_project "$p"
install_into "$p"
python3 - "$p/.cursor/hooks.json" <<'PY'
import json, sys
from pathlib import Path
p = Path(sys.argv[1])
d = json.loads(p.read_text())
d["hooks"]["postToolUse"].append({"command": "bash .cursor/hooks/project-extra.sh"})
p.write_text(json.dumps(d, indent=2) + "\n")
PY
cp "$p/.cursor/hooks.json" "$ROOT/plain.first"
install_into "$p"
if diff -u "$ROOT/plain.first" "$p/.cursor/hooks.json"; then
  pass "plain project: re-install leaves hooks.json unchanged"
else
  fail "plain project: re-install changed hooks.json"
fi
if [[ "$(count "$p" .cursor/hooks/context-governor.sh)" == 3 ]]; then
  pass "plain project: governor registered once per event"
else
  fail "plain project: governor count $(count "$p" .cursor/hooks/context-governor.sh)"
fi

# Partial wrapper: only the wrapped event skips the vendor entry.
p="$ROOT/partial"
new_project "$p"
wrapper "$p" context-governor.sh governor-domain.sh
printf '{\n  "version": 1,\n  "hooks": {\n    "stop": [\n      {\n        "command": "bash .cursor/hooks/governor-domain.sh"\n      }\n    ]\n  }\n}\n' \
  >"$p/.cursor/hooks.json"
install_into "$p"
cp "$p/.cursor/hooks.json" "$ROOT/partial.first"
install_into "$p"
if diff -q "$ROOT/partial.first" "$p/.cursor/hooks.json" >/dev/null \
  && [[ "$(count "$p" .cursor/hooks/context-governor.sh)" == 2 ]]; then
  pass "partial wrapper: vendor governor only in unwrapped events, stable"
else
  fail "partial wrapper: governor count $(count "$p" .cursor/hooks/context-governor.sh)"
fi

if [[ "$fails" -ne 0 ]]; then
  echo "$fails test(s) failed" >&2
  exit 1
fi
echo "all tests passed"
