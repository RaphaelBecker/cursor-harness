#!/usr/bin/env bash
# Usage: bash skills/project-memory/prune-candidates.test.sh
set -euo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/prune-candidates.py"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
failures=0

git -C "$tmp" init -q
git -C "$tmp" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "Lint changed files (resolves lint-gap)"
mkdir -p "$tmp/docs"
echo "see row doc-owned-id" >"$tmp/docs/guide.md"
git -C "$tmp" add docs && git -C "$tmp" -c user.name=t -c user.email=t@t commit -q -m docs
cat >"$tmp/project_memory.md" <<'MD'
| id | domain | lesson | added_at | help_count | last_helped_at | status |
| --- | --- | --- | --- | --- | --- | --- |
| owned-row | test | Owned by `docs/x.md` §1. | 2026-01-01 | 0 | - | retired |
| lint-gap | test | Lint before merge. | 2026-01-01 | 0 | - | active |
| doc-owned-id | ui | Something. | 2026-01-01 | 0 | - | active |
| still-useful | ui | Keep me. | 2026-01-01 | 0 | - | active |
MD

out="$(python3 "$SCRIPT" --root "$tmp")"
expect() {
  if ! grep -qF -- "$1" <<<"$out"; then
    echo "FAIL: missing '$1'"
    failures=$((failures + 1))
  fi
}
expect '| owned-row | retired | owner | `docs/x.md` §1 |'
expect '| lint-gap | active | commit |'
expect 'Lint changed files (resolves lint-gap)'
expect '| doc-owned-id | active | file |'
expect '| still-useful | active | none | - |'
expect 'rows: 4'

if [[ "$failures" -gt 0 ]]; then
  echo "$out"
  exit 1
fi
echo "prune-candidates: all cases pass"
