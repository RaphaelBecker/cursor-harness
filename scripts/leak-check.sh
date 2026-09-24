#!/usr/bin/env bash
# Fail when the harness tree contains a term from a consumer's leak denylist.
# The denylist lives in the consumer project so this repo never names a product.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: leak-check.sh (--project <root> | --denylist <file>)

  --project <root>   Read `leak_denylist` from <root>/harness.project.yaml
  --denylist <file>  Regex file: one case-insensitive pattern per line, # comments

Exit 0 = clean or no denylist configured; 1 = hits (printed as path:line:text).
EOF
}

HARNESS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT=""
DENYLIST=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT="${2:-}"; shift 2 ;;
    --denylist) DENYLIST="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$DENYLIST" ]]; then
  if [[ -z "$PROJECT" ]]; then
    usage >&2
    exit 2
  fi
  PROJECT="$(cd "$PROJECT" && pwd)"
  rel="$(
    python3 - "$HARNESS/runtime" "$PROJECT/harness.project.yaml" <<'PY'
import sys
sys.path.insert(0, sys.argv[1])
from project_config import load_yaml_file
print(str(load_yaml_file(__import__("pathlib").Path(sys.argv[2])).get("leak_denylist") or ""))
PY
  )"
  if [[ -z "$rel" ]]; then
    echo "leak-check: no leak_denylist in $PROJECT/harness.project.yaml — skipped"
    exit 0
  fi
  [[ "$rel" == /* ]] && DENYLIST="$rel" || DENYLIST="$PROJECT/$rel"
fi

if [[ ! -f "$DENYLIST" ]]; then
  echo "leak-check: denylist not found: $DENYLIST" >&2
  exit 2
fi

patterns="$(mktemp "${TMPDIR:-/tmp}/leak-patterns.XXXXXX")"
trap 'rm -f "$patterns"' EXIT
sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$DENYLIST" >"$patterns"
if [[ ! -s "$patterns" ]]; then
  echo "leak-check: denylist is empty — skipped"
  exit 0
fi

cd "$HARNESS"
set +e
if command -v rg >/dev/null 2>&1; then
  hits="$(rg -n -i --hidden -f "$patterns" \
    --glob '!.git' --glob '!.smoke-tmp/**' --glob '!**/__pycache__/**' . 2>/dev/null)"
else
  hits="$(grep -rniIE -f "$patterns" \
    --exclude-dir=.git --exclude-dir=.smoke-tmp --exclude-dir=__pycache__ . 2>/dev/null)"
fi
set -e

if [[ -n "$hits" ]]; then
  echo "leak-check: consumer terms found in the harness ($DENYLIST):" >&2
  printf '%s\n' "$hits" >&2
  exit 1
fi
echo "leak-check: clean ($(wc -l <"$patterns" | tr -d ' ') patterns)"
