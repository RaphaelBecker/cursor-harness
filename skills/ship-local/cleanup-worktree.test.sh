#!/usr/bin/env bash
# Self-test for cleanup-worktree.sh. No extra framework.
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/cleanup-worktree.sh"
chmod +x "$SCRIPT"

fails=0
pass() { echo "ok - $1"; }
fail() { echo "not ok - $1" >&2; fails=$((fails + 1)); }

assert_exit() {
  local want="$1"
  local name="$2"
  shift 2
  local got=0
  "$@" && got=0 || got=$?
  if [[ "$got" -eq "$want" ]]; then
    pass "$name"
  else
    fail "$name (exit $got, want $want)"
  fi
}

ROOT="$(mktemp -d "${TMPDIR:-/tmp}/ship-local-cleanup.XXXXXX")"
trap 'rm -rf "$ROOT"' EXIT

git init -b main "$ROOT/main" >/dev/null
git -C "$ROOT/main" config user.email "test@example.com"
git -C "$ROOT/main" config user.name "Test"
echo base >"$ROOT/main/file"
git -C "$ROOT/main" add file
git -C "$ROOT/main" commit -m init >/dev/null

# --- happy path: listed worktree + merged branch ---
git -C "$ROOT/main" worktree add -b feature "$ROOT/feature" >/dev/null
echo feat >>"$ROOT/feature/file"
git -C "$ROOT/feature" add file
git -C "$ROOT/feature" commit -m feat >/dev/null
git -C "$ROOT/main" merge --ff-only feature >/dev/null

if "$SCRIPT" --main-root "$ROOT/main" --worktree "$ROOT/feature" --branch feature >/dev/null; then
  if [[ ! -e "$ROOT/feature" ]] \
    && ! git -C "$ROOT/main" worktree list --porcelain | grep -q "$ROOT/feature" \
    && ! git -C "$ROOT/main" show-ref --verify --quiet refs/heads/feature; then
    pass "happy path removes worktree and merged branch"
  else
    fail "happy path left worktree or branch"
  fi
else
  fail "happy path script failed"
fi

# --- idempotent second run ---
if "$SCRIPT" --main-root "$ROOT/main" --worktree "$ROOT/feature" --branch feature >/dev/null; then
  pass "idempotent rerun after successful cleanup"
else
  fail "idempotent rerun failed"
fi

# --- orphan folder after unregister (stale .git, not listed) ---
git -C "$ROOT/main" worktree add -b orphan "$ROOT/orphan" >/dev/null
echo leftover >"$ROOT/orphan/keep"
admin="$ROOT/main/.git/worktrees/orphan"
rm -rf "$admin"
git -C "$ROOT/main" worktree prune >/dev/null 2>&1 || true
if [[ ! -d "$ROOT/orphan" ]]; then
  fail "orphan setup lost the folder"
else
  if "$SCRIPT" --main-root "$ROOT/main" --worktree "$ROOT/orphan" --branch orphan >/dev/null; then
    if [[ ! -e "$ROOT/orphan" ]]; then
      pass "orphan leftover folder is deleted"
    else
      fail "orphan folder still exists"
    fi
  else
    fail "orphan cleanup script failed"
  fi
fi

# --- half-deleted leftover: unregistered, no .git ---
mkdir -p "$ROOT/half/.cursor/hooks"
echo hook >"$ROOT/half/.cursor/hooks/guard.sh"
if "$SCRIPT" --main-root "$ROOT/main" --worktree "$ROOT/half" >/dev/null; then
  if [[ ! -e "$ROOT/half" ]]; then
    pass "half-deleted folder with no .git is deleted"
  else
    fail "half-deleted folder still exists"
  fi
else
  fail "half-deleted cleanup script failed"
fi

# --- refuse primary checkout ---
assert_exit 2 "refuse --worktree main-root" \
  "$SCRIPT" --main-root "$ROOT/main" --worktree "$ROOT/main"

# --- refuse default branch ---
git -C "$ROOT/main" worktree add -b other "$ROOT/other" >/dev/null
git -C "$ROOT/main" merge --ff-only other >/dev/null 2>&1 || true
assert_exit 2 "refuse --branch main" \
  "$SCRIPT" --main-root "$ROOT/main" --worktree "$ROOT/other" --branch main
if [[ -d "$ROOT/other" ]]; then
  pass "refuse-main-branch left the worktree in place"
else
  fail "refuse-main-branch deleted the worktree"
fi
# tidy the leftover other tree so EXIT trap is enough
git -C "$ROOT/main" worktree remove --force "$ROOT/other" >/dev/null 2>&1 || rm -rf "$ROOT/other"
git -C "$ROOT/main" branch -d other >/dev/null 2>&1 || true

# --- refuse standalone clone ---
git init -b main "$ROOT/other-repo" >/dev/null
git -C "$ROOT/other-repo" config user.email "test@example.com"
git -C "$ROOT/other-repo" config user.name "Test"
echo z >"$ROOT/other-repo/file"
git -C "$ROOT/other-repo" add file
git -C "$ROOT/other-repo" commit -m init >/dev/null
assert_exit 2 "refuse standalone clone" \
  "$SCRIPT" --main-root "$ROOT/main" --worktree "$ROOT/other-repo"
if [[ -d "$ROOT/other-repo/.git" ]]; then
  pass "standalone clone still exists"
else
  fail "standalone clone was deleted"
fi

if [[ "$fails" -ne 0 ]]; then
  echo "$fails test(s) failed" >&2
  exit 1
fi
echo "all tests passed"
