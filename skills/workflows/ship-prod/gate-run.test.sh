#!/usr/bin/env bash
# Usage: bash skills/workflows/ship-prod/gate-run.test.sh
set -uo pipefail

GATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/gate-run.sh"
GATE_RUN_DIR="$(mktemp -d)"
export GATE_RUN_DIR
trap 'rm -rf "$GATE_RUN_DIR"' EXIT
failures=0

fail() {
  echo "FAIL: $*"
  failures=$((failures + 1))
}

expect_code() {
  local want="$1" got="$2" what="$3"
  [[ "$got" -eq "$want" ]] || fail "$what: want exit $want, got $got"
}

bash "$GATE" start --name red -- bash -c 'echo red-line; exit 7' >/dev/null
out="$(bash "$GATE" wait-step --name red --seconds 20)"
expect_code 1 $? "red gate"
grep -q '^exit: 7$' <<<"$out" || fail "red gate reports exit 7: $out"
grep -q 'red-line' <<<"$out" || fail "red gate shows log tail: $out"

bash "$GATE" start --name green -- bash -c 'echo ok' >/dev/null
bash "$GATE" wait-step --name green --seconds 20 >/dev/null
expect_code 0 $? "green gate"

bash "$GATE" start --name slow -- sleep 30 >/dev/null
t0=$(date +%s)
out="$(bash "$GATE" status --name slow)"
expect_code 3 $? "running gate"
(( $(date +%s) - t0 <= 2 )) || fail "status must return immediately"
grep -q '^state: running$' <<<"$out" || fail "running state: $out"
bash "$GATE" start --name slow -- sleep 1 >/dev/null 2>&1
expect_code 2 $? "second start while running"
kill -- "-$(cat "$GATE_RUN_DIR/slow/pid")" 2>/dev/null
sleep 1
bash "$GATE" status --name slow >/dev/null
code=$?
[[ "$code" -eq 1 || "$code" -eq 4 ]] || fail "killed gate: want 1 or 4, got $code"

mkdir -p "$GATE_RUN_DIR/ghost"
echo 999999 >"$GATE_RUN_DIR/ghost/pid"
bash "$GATE" status --name ghost >/dev/null
expect_code 4 $? "dead gate without exit marker"

bash "$GATE" status --name missing >/dev/null 2>&1
expect_code 2 $? "unknown gate"

bash "$GATE" start --name capped -- sleep 200 >/dev/null
t0=$(date +%s)
bash "$GATE" wait-step --name capped --seconds 1 >/dev/null
expect_code 3 $? "wait-step returns while running"
(( $(date +%s) - t0 <= 5 )) || fail "wait-step honours --seconds"
kill -- "-$(cat "$GATE_RUN_DIR/capped/pid")" 2>/dev/null

if [[ "$failures" -gt 0 ]]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "gate-run: all cases pass"
