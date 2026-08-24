#!/usr/bin/env bash
# afterFileEdit: fail-open format/lint on the edited file. Always exit 0.
#
# Consumer-owned. Copy to `.cursor/hooks/autofix.sh`, chmod +x, and add an
# afterFileEdit entry in `.cursor/hooks.json`:
#   { "command": ".cursor/hooks/autofix.sh" }
# install.sh merges harness hooks by command path and leaves this entry alone.
#
# Discover formatters from the project (package.json, ruff.toml, Makefile).
# Do not hardcode another product's paths. Optional harness.project.yaml:
#   autofix:
#     js: npx eslint --fix
#     py: ruff format
set -uo pipefail

input=$(cat)
file=$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
path = data.get("file_path") or data.get("filePath") or data.get("path") or ""
if not path and isinstance(data.get("edits"), list) and data["edits"]:
    path = data["edits"][0].get("path") or ""
print(path)
' 2>/dev/null)
[ -z "${file:-}" ] && exit 0

root="$(cd "$(dirname "$0")/../.." && pwd)"
case "$file" in
  /*) abs="$file" ;;
  *) abs="$root/$file" ;;
esac
[ -f "$abs" ] || exit 0

mkdir -p "$root/.cursor/hooks/.cache"
log="$root/.cursor/hooks/.cache/autofix.log"

# Example: JS/TS via local eslint when present. Replace globs with this project's trees.
case "$abs" in
  *.ts|*.tsx|*.js|*.jsx)
    if [ -x "$root/node_modules/.bin/eslint" ]; then
      "$root/node_modules/.bin/eslint" --fix "$abs" >>"$log" 2>&1 || true
    fi
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format "$abs" >>"$log" 2>&1 || true
      ruff check --fix "$abs" >>"$log" 2>&1 || true
    fi
    ;;
esac

exit 0
