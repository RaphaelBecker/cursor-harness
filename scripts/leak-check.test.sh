#!/usr/bin/env bash
# Prove leak-check.sh flags consumer denylist terms and passes a clean tree.
set -euo pipefail

HARNESS="$(cd "$(dirname "$0")/.." && pwd)"
CHECK="$HARNESS/scripts/leak-check.sh"
fails=0
pass() { echo "ok - $1"; }
fail() { echo "not ok - $1" >&2; fails=$((fails + 1)); }

ROOT="$(mktemp -d "${TMPDIR:-/tmp}/harness-leak.XXXXXX")"
trap 'rm -rf "$ROOT"' EXIT

printf '# comment only\nzq-no-such-term-%s\n' "$$" >"$ROOT/clean.txt"
if "$CHECK" --denylist "$ROOT/clean.txt" >/dev/null 2>&1; then
  pass "absent term passes"
else
  fail "absent term reported a leak"
fi

printf 'SELF-TEST-NEEDLE\n' >"$ROOT/hit.txt"
if ! out="$("$CHECK" --denylist "$ROOT/hit.txt" 2>&1)" \
  && grep -q 'scripts/leak-check.test.sh' <<<"$out"; then
  pass "present term fails with the offending path"
else
  fail "present term not reported: $out"
fi

mkdir -p "$ROOT/proj"
printf 'issue_source: none\ntest:\n  discover: true\npacks: [core]\n' >"$ROOT/proj/harness.project.yaml"
if out="$("$CHECK" --project "$ROOT/proj" 2>&1)" && grep -q 'skipped' <<<"$out"; then
  pass "project without leak_denylist skips"
else
  fail "project without leak_denylist: $out"
fi

cp "$ROOT/hit.txt" "$ROOT/proj/deny.txt"
printf 'leak_denylist: deny.txt\n' >>"$ROOT/proj/harness.project.yaml"
if ! "$CHECK" --project "$ROOT/proj" >/dev/null 2>&1; then
  pass "project leak_denylist is read relative to the project root"
else
  fail "project leak_denylist was not applied"
fi

if [[ "$fails" -ne 0 ]]; then
  echo "$fails test(s) failed" >&2
  exit 1
fi
echo "all tests passed"
