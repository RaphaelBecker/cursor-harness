#!/usr/bin/env bash
# Self-test for land.sh on throwaway repos.
set -euo pipefail

LAND="$(cd "$(dirname "$0")" && pwd)/land.sh"
ROOT="$(mktemp -d "${TMPDIR:-/tmp}/land-test.XXXXXX")"
ROOT="$(cd "$ROOT" && pwd -P)"
trap 'rm -rf "$ROOT"' EXIT
fails=0
pass() { echo "ok - $1"; }
fail() { echo "not ok - $1" >&2; fails=$((fails + 1)); }

MAIN="$ROOT/app"
git init -q -b main "$MAIN"
git -C "$MAIN" config user.email t@example.com
git -C "$MAIN" config user.name T
echo base >"$MAIN/file"
git -C "$MAIN" add file && git -C "$MAIN" commit -qm init

feature() {
  git -C "$MAIN" worktree add -q -b "$1" "$ROOT/$1"
  echo "$1" >"$ROOT/$1/$1.txt"
  git -C "$ROOT/$1" add . && git -C "$ROOT/$1" commit -qm "$1"
}
land() { bash "$LAND" --main-root "$MAIN" --worktree "$ROOT/$1" --branch "$1" --no-fetch; }
rc_of() { local rc=0; "$@" >"$ROOT/out" 2>&1 || rc=$?; echo "$rc"; }

feature one
if [[ "$(rc_of land one)" == 0 && -f "$MAIN/one.txt" && ! -e "$ROOT/one" && ! -f "$MAIN/.git/ship-local.lock" ]] &&
  ! git -C "$MAIN" show-ref -q refs/heads/one; then
  pass "fast-forward land removes tree, branch, and lock"
else
  fail "fast-forward land"; cat "$ROOT/out" >&2
fi

feature two
echo ahead >"$MAIN/ahead.txt" && git -C "$MAIN" add . && git -C "$MAIN" commit -qm ahead
if [[ "$(rc_of land two)" == 0 && -f "$MAIN/two.txt" && -f "$MAIN/ahead.txt" && ! -e "$ROOT/two" ]]; then
  pass "main-ahead is merged into the feature, then landed"
else
  fail "main-ahead land"; cat "$ROOT/out" >&2
fi

feature three
echo dirty >"$ROOT/three/extra.txt"
if [[ "$(rc_of land three)" == 4 && -d "$ROOT/three" && ! -f "$MAIN/.git/ship-local.lock" ]]; then
  pass "dirty feature exits 4, keeps the tree, frees the lock"
else
  fail "dirty feature"; cat "$ROOT/out" >&2
fi
rm "$ROOT/three/extra.txt"

echo main-side >"$MAIN/three.txt" && git -C "$MAIN" add . && git -C "$MAIN" commit -qm clash
if [[ "$(rc_of land three)" == 3 && -d "$ROOT/three" ]]; then
  pass "conflict exits 3 with the merge left in the feature tree"
else
  fail "conflict exit"; cat "$ROOT/out" >&2
fi
echo resolved >"$ROOT/three/three.txt"
git -C "$ROOT/three" add three.txt && git -C "$ROOT/three" commit -qm resolve
if [[ "$(rc_of land three)" == 0 && "$(cat "$MAIN/three.txt")" == resolved && ! -e "$ROOT/three" ]]; then
  pass "re-run after resolving lands and cleans up"
else
  fail "resume after conflict"; cat "$ROOT/out" >&2
fi

feature hook
printf 'ship:\n  after_land: touch after-land.ran\n' >"$MAIN/harness.project.yaml"
echo harness.project.yaml >>"$MAIN/.git/info/exclude"; echo after-land.ran >>"$MAIN/.git/info/exclude"
if [[ "$(rc_of land hook)" == 0 && -f "$MAIN/after-land.ran" && ! -e "$ROOT/hook" ]]; then
  pass "ship.after_land runs on default after the land"
else
  fail "after_land hook"; cat "$ROOT/out" >&2
fi
rm -f "$MAIN/harness.project.yaml" "$MAIN/after-land.ran"

feature four
printf '1\tx\t%s\t%s\n' "$ROOT/four" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >"$MAIN/.git/ship-local.lock"
if [[ "$(rc_of land four)" == 2 && -d "$ROOT/four" && -f "$MAIN/.git/ship-local.lock" ]]; then
  pass "a live lock refuses and is left alone"
else
  fail "live lock"; cat "$ROOT/out" >&2
fi

[[ "$fails" -eq 0 ]] || { echo "$fails test(s) failed" >&2; exit 1; }
echo "all tests passed"
