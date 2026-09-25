#!/usr/bin/env bash
# Usage: bash skills/workflows/ship-prod/shard-check.test.sh
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK="$ROOT/shard-check.sh"
SHA="0123456789abcdef0123456789abcdef01234567"
failures=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fail() {
  echo "FAIL: $*"
  failures=$((failures + 1))
}

expect_code() {
  local want="$1" got="$2" what="$3"
  [[ "$got" -eq "$want" ]] || fail "$what: want exit $want, got $got"
}

cat >"$tmp/gh" <<'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "${GH_STUB_LOG:?}"
if [ "$1" = "workflow" ]; then
  exit 0
fi
if [ "$1" = "run" ] && [ "$2" = "list" ]; then
  cat "${GH_STUB_LIST:?}"
  exit 0
fi
if [ "$1" = "run" ] && [ "$2" = "view" ]; then
  cat "${GH_STUB_VIEW:?}"
  exit 0
fi
echo "unexpected gh $*" >&2
exit 1
EOF
chmod +x "$tmp/gh"
export PATH="$tmp:$PATH"
export GH_STUB_LOG="$tmp/gh.log"
export GH_STUB_LIST="$tmp/list.json"
export GH_STUB_VIEW="$tmp/view.json"
: >"$GH_STUB_LOG"

bash "$CHECK" dispatch --workflow deploy.yml --shard e2e_read --ref not-a-sha --branch main >/dev/null 2>&1
expect_code 2 $? "reject a short ref"
[[ ! -s "$GH_STUB_LOG" ]] || fail "invalid ref must not call gh"

printf '%s\n' '[{"databaseId":42,"displayTitle":"shard-check e2e_read '"$SHA"'","url":"https://example/42","status":"queued","createdAt":"2026-09-25T12:00:00Z"}]' >"$GH_STUB_LIST"
out="$(bash "$CHECK" dispatch --workflow deploy.yml --shard e2e_read --ref "$SHA" --branch main --seconds 5)"
expect_code 0 $? "dispatch finds the run"
grep -q '^run: 42$' <<<"$out" || fail "dispatch prints run id: $out"
grep -q '^state: dispatched$' <<<"$out" || fail "dispatch state: $out"
grep -q "shard=${SHA}\|ref=${SHA}" "$GH_STUB_LOG" || fail "dispatch passes the sha: $(cat "$GH_STUB_LOG")"
grep -q 'shard=e2e_read' "$GH_STUB_LOG" || fail "dispatch passes the shard"

printf '%s\n' '[]' >"$GH_STUB_LIST"
out="$(bash "$CHECK" dispatch --workflow deploy.yml --shard e2e_read --ref "$SHA" --branch main --seconds 0)"
expect_code 3 $? "dispatch pending"
grep -q '^state: pending$' <<<"$out" || fail "pending state: $out"

out="$(bash "$CHECK" find --workflow deploy.yml --shard e2e_read --ref "$SHA")"
expect_code 3 $? "find missing"

printf '%s\n' '{"status":"completed","conclusion":"success","url":"https://example/42"}' >"$GH_STUB_VIEW"
bash "$CHECK" wait-step --run 42 --seconds 90 >/dev/null
expect_code 0 $? "green shard"

printf '%s\n' '{"status":"completed","conclusion":"failure","url":"https://example/42"}' >"$GH_STUB_VIEW"
out="$(bash "$CHECK" wait-step --run 42 --seconds 1)"
expect_code 1 $? "red shard"
grep -q '^conclusion: failure$' <<<"$out" || fail "red conclusion: $out"

printf '%s\n' '{"status":"in_progress","conclusion":"","url":"https://example/42"}' >"$GH_STUB_VIEW"
t0=$(date +%s)
out="$(bash "$CHECK" wait-step --run 42 --seconds 0)"
expect_code 3 $? "still running"
(( $(date +%s) - t0 <= 3 )) || fail "wait-step --seconds 0 must return immediately"
grep -q '^state: running$' <<<"$out" || fail "running state: $out"

t0=$(date +%s)
bash "$CHECK" wait-step --run 42 --seconds 1 >/dev/null
expect_code 3 $? "short poll while running"
(( $(date +%s) - t0 <= 5 )) || fail "wait-step --seconds 1 must return within 5s"

if [[ "$failures" -gt 0 ]]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "shard-check: all cases pass"
