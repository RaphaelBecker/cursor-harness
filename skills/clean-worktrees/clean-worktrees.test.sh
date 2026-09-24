#!/usr/bin/env bash
# Self-test for clean-worktrees.sh. Uses a temp farm — never ~/.cursor.
set -euo pipefail

SCRIPT="$(cd "$(dirname "$0")" && pwd)/clean-worktrees.sh"
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

ROOT="$(mktemp -d "${TMPDIR:-/tmp}/clean-worktrees.XXXXXX")"
trap 'rm -rf "$ROOT"' EXIT

init_repo() {
  local dest="$1"
  git init -b main "$dest" >/dev/null
  git -C "$dest" config user.email "test@example.com"
  git -C "$dest" config user.name "Test"
  echo base >"$dest/file"
  git -C "$dest" add file
  git -C "$dest" commit -m init >/dev/null
}

MAIN="$ROOT/app"
init_repo "$MAIN"
FARM="$ROOT/farm"
PROJECTS="$ROOT/projects"
STORAGE="$ROOT/storage"
mkdir -p "$FARM" "$PROJECTS" "$STORAGE"

run_script() {
  "$SCRIPT" --main-root "$MAIN" \
    --cursor-worktrees-root "$FARM" \
    --cursor-projects-root "$PROJECTS" \
    --workspace-storage-root "$STORAGE" \
    "$@"
}

slug_for() {
  python3 -c '
import sys
p = sys.argv[1].rstrip("/")
if p.startswith("/"):
    p = p[1:]
parts = []
for seg in p.split("/"):
    if seg.startswith("."):
        seg = seg[1:]
    if seg:
        parts.append(seg)
print("-".join(parts))
' "$1"
}

# --- refuse linked worktree as main-root ---
git -C "$MAIN" worktree add -b linked "$ROOT/linked" >/dev/null
assert_exit 2 "refuse linked worktree as --main-root" \
  "$SCRIPT" --main-root "$ROOT/linked" \
    --cursor-worktrees-root "$FARM" \
    --cursor-projects-root "$PROJECTS" \
    --workspace-storage-root "$STORAGE"
git -C "$MAIN" worktree remove --force "$ROOT/linked" >/dev/null
git -C "$MAIN" branch -d linked >/dev/null

# --- live lock stops ---
git -C "$MAIN" worktree add -b locked "$ROOT/locked" >/dev/null
mkdir -p "$MAIN/.cursor"
printf '123\tlocked\t%s\t%s\n' "$ROOT/locked" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >"$MAIN/.git/ship-local.lock"
assert_exit 2 "live lock refuses to clean" run_script
if [[ -d "$ROOT/locked" && -f "$MAIN/.git/ship-local.lock" ]]; then
  pass "live lock left worktree and lock in place"
else
  fail "live lock deleted worktree or lock"
fi
rm -f "$MAIN/.git/ship-local.lock"
git -C "$MAIN" worktree remove --force "$ROOT/locked" >/dev/null
git -C "$MAIN" branch -d locked >/dev/null

# --- project ship.lock reporting held also stops ---
printf 'ship:\n  lock: echo held; true\n' >"$MAIN/harness.project.yaml"
assert_exit 2 "project ship.lock held refuses to clean" run_script
rm -f "$MAIN/harness.project.yaml"

# --- stale lock is removed, ghost leftover goes ---
mkdir -p "$FARM/ghost/.cursor/hooks"
printf '1\told\t%s\t2000-01-01T00:00:00Z\n' "$ROOT/gone-holder" >"$MAIN/.git/ship-local.lock"
if run_script >/tmp/clean-worktrees-stale.out; then
  if [[ ! -e "$FARM/ghost" && ! -f "$MAIN/.git/ship-local.lock" ]]; then
    pass "stale lock removed and leftover deleted"
  else
    fail "stale lock path still present"
  fi
else
  fail "stale lock run failed"
fi

# --- dry-run does not delete ---
git -C "$MAIN" worktree add -b dryfeat "$ROOT/dryfeat" >/dev/null
git -C "$MAIN" merge --ff-only dryfeat >/dev/null
mkdir -p "$FARM/dryghost/.cursor/hooks"
if run_script --dry-run >/tmp/clean-worktrees-dry.out; then
  if [[ -d "$ROOT/dryfeat" && -d "$FARM/dryghost" ]]; then
    pass "dry-run leaves trees in place"
  else
    fail "dry-run deleted something"
  fi
else
  fail "dry-run exited non-zero"
fi
git -C "$MAIN" worktree remove --force "$ROOT/dryfeat" >/dev/null
git -C "$MAIN" branch -d dryfeat >/dev/null
rm -rf "$FARM/dryghost"

# --- dirty feature is skipped; leftover still removed ---
git -C "$MAIN" worktree add -b dirty "$ROOT/dirty" >/dev/null
echo dirty >>"$ROOT/dirty/file"
mkdir -p "$FARM/half/.cursor/hooks"
if run_script >/tmp/clean-worktrees-dirty.out; then
  fail "dirty run should exit 1"
else
  if [[ -d "$ROOT/dirty" && ! -e "$FARM/half" ]]; then
    pass "dirty worktree kept; leftover removed"
  else
    fail "dirty skip / leftover remove mismatch"
  fi
fi
git -C "$MAIN" worktree remove --force "$ROOT/dirty" >/dev/null
git -C "$MAIN" branch -d dirty >/dev/null

# --- vendor-symlink retarget on a landed tree is not project dirt ---
mkdir -p "$MAIN/.cursor/skills" "$MAIN/vendor/cursor-harness/skills"
echo skill >"$MAIN/vendor/cursor-harness/skills/clean-worktrees"
ln -s "$MAIN/vendor/cursor-harness/skills/clean-worktrees" "$MAIN/.cursor/skills/clean-worktrees"
git -C "$MAIN" add .cursor vendor
git -C "$MAIN" commit -m 'track harness skill link' >/dev/null
git -C "$MAIN" worktree add -b slink "$FARM/slink" >/dev/null
rm "$FARM/slink/.cursor/skills/clean-worktrees"
ln -s "$FARM/slink/vendor/cursor-harness/skills/clean-worktrees" "$FARM/slink/.cursor/skills/clean-worktrees"
if run_script >/tmp/clean-worktrees-slink.out; then
  if [[ ! -e "$FARM/slink" ]]; then
    pass "vendor-symlink retarget is ignored and landed tree is removed"
  else
    fail "symlink-retarget tree was kept"
    cat /tmp/clean-worktrees-slink.out >&2 || true
  fi
else
  fail "symlink-retarget run should exit 0"
  cat /tmp/clean-worktrees-slink.out >&2 || true
fi
git -C "$MAIN" branch -d slink >/dev/null 2>&1 || true

# --- symlink retarget plus real project dirt is still skipped ---
git -C "$MAIN" worktree add -b mixed "$ROOT/mixed" >/dev/null
rm "$ROOT/mixed/.cursor/skills/clean-worktrees"
ln -s "$ROOT/mixed/vendor/cursor-harness/skills/clean-worktrees" "$ROOT/mixed/.cursor/skills/clean-worktrees"
echo mixed >>"$ROOT/mixed/file"
assert_exit 1 "mixed symlink+project dirt is skipped" run_script
if [[ -d "$ROOT/mixed" ]]; then
  pass "mixed dirty worktree still exists"
else
  fail "mixed dirty worktree was deleted"
fi
git -C "$MAIN" worktree remove --force "$ROOT/mixed" >/dev/null
git -C "$MAIN" branch -d mixed >/dev/null

# --- --discard removes a dirty tree after human confirmation ---
git -C "$MAIN" worktree add -b tossdirty "$ROOT/tossdirty" >/dev/null
echo toss >>"$ROOT/tossdirty/file"
if run_script --discard "$ROOT/tossdirty" >/tmp/clean-worktrees-discard-dirty.out; then
  if [[ ! -e "$ROOT/tossdirty" ]] && ! git -C "$MAIN" show-ref --verify --quiet refs/heads/tossdirty; then
    pass "discard removes dirty landed tree and branch"
  else
    fail "discard left dirty tree or branch"
    cat /tmp/clean-worktrees-discard-dirty.out >&2 || true
  fi
else
  fail "discard dirty run failed"
  cat /tmp/clean-worktrees-discard-dirty.out >&2 || true
fi

# --- unmerged unique commits are skipped ---
git -C "$MAIN" worktree add -b unique "$ROOT/unique" >/dev/null
echo unique >>"$ROOT/unique/file"
git -C "$ROOT/unique" add file
git -C "$ROOT/unique" commit -m unique >/dev/null
assert_exit 1 "unmerged unique worktree is skipped" run_script
if [[ -d "$ROOT/unique" ]]; then
  pass "unmerged worktree still exists"
else
  fail "unmerged worktree was deleted"
fi
git -C "$MAIN" worktree remove --force "$ROOT/unique" >/dev/null
git -C "$MAIN" branch -D unique >/dev/null

# --- --discard removes unique unmerged commits after human confirmation ---
git -C "$MAIN" worktree add -b tossunique "$ROOT/tossunique" >/dev/null
echo unique2 >>"$ROOT/tossunique/file"
git -C "$ROOT/tossunique" add file
git -C "$ROOT/tossunique" commit -m unique2 >/dev/null
if run_script --discard "$ROOT/tossunique" >/tmp/clean-worktrees-discard-unique.out; then
  if [[ ! -e "$ROOT/tossunique" ]] && ! git -C "$MAIN" show-ref --verify --quiet refs/heads/tossunique; then
    pass "discard removes unmerged unique worktree and branch"
  else
    fail "discard left unique tree or branch"
    cat /tmp/clean-worktrees-discard-unique.out >&2 || true
  fi
else
  fail "discard unique run failed"
  cat /tmp/clean-worktrees-discard-unique.out >&2 || true
fi

# --- keep spares a clean merged tree ---
git -C "$MAIN" worktree add -b kept "$ROOT/kept" >/dev/null
git -C "$MAIN" merge --ff-only kept >/dev/null
mkdir -p "$FARM/spare-ghost/.cursor"
if run_script --keep "$ROOT/kept" >/tmp/clean-worktrees-keep.out; then
  if [[ -d "$ROOT/kept" && ! -e "$FARM/spare-ghost" ]]; then
    pass "keep leaves named tree; leftover gone"
  else
    fail "keep path wrong"
  fi
else
  fail "keep run failed"
fi
git -C "$MAIN" worktree remove --force "$ROOT/kept" >/dev/null
git -C "$MAIN" branch -d kept >/dev/null

# --- standalone clone in farm is refused ---
init_repo "$FARM/other-repo"
assert_exit 1 "standalone clone in farm is skipped" run_script
if [[ -d "$FARM/other-repo/.git" ]]; then
  pass "standalone clone still exists"
else
  fail "standalone clone was deleted"
fi
rm -rf "$FARM/other-repo"

# --- landed tree whose dirt is night-shift, already-on-main, or project reset rows ---
mkdir -p "$MAIN/.cursor/plans"
printf -- '---\nstatus: approved\n---\n' >"$MAIN/.cursor/plans/p.plan.md"
git -C "$MAIN" add .cursor/plans && git -C "$MAIN" commit -m plan >/dev/null
git -C "$MAIN" worktree add -b noisy "$ROOT/noisy" >/dev/null
printf -- '---\nstatus: archived\n---\n' | tee "$MAIN/.cursor/plans/p.plan.md" >"$ROOT/noisy/.cursor/plans/p.plan.md"
git -C "$MAIN" commit -am 'archive plan' >/dev/null
mkdir -p "$ROOT/noisy/.cursor/night-shift"
echo handoff >"$ROOT/noisy/.cursor/night-shift/HANDOFF.md"
echo generated >"$ROOT/noisy/gen.txt"
printf 'ship:\n  leftovers: printf "reset\\tgen.txt\\tgenerated\\n"\n' >"$MAIN/harness.project.yaml"
if run_script >/tmp/clean-worktrees-noisy.out && [[ ! -e "$ROOT/noisy" ]]; then
  pass "landed noise (night-shift, on-main plan, project reset) is not dirt"
else
  fail "noisy landed tree was kept"
  cat /tmp/clean-worktrees-noisy.out >&2 || true
fi
rm -f "$MAIN/harness.project.yaml"
git -C "$MAIN" branch -d noisy >/dev/null 2>&1 || true

# --- a live night agent spares the tree ---
git -C "$MAIN" worktree add -b night "$ROOT/night" >/dev/null
mkdir -p "$ROOT/night/.cursor/night-shift"
echo "$$" >"$ROOT/night/.cursor/night-shift/agent.pid"
assert_exit 1 "live night agent tree is skipped" run_script
if [[ -d "$ROOT/night" ]]; then
  pass "night agent tree still exists"
else
  fail "night agent tree was deleted"
fi
git -C "$MAIN" worktree remove --force "$ROOT/night" >/dev/null
git -C "$MAIN" branch -d night >/dev/null

# --- happy path: merged tree + leftover + project cache + workspace storage ---
git -C "$MAIN" worktree add -b landed "$FARM/landed" >/dev/null
git -C "$MAIN" merge --ff-only landed >/dev/null
mkdir -p "$FARM/edrj/.cursor/hooks"
landed_slug="$(slug_for "$FARM/landed")"
ghost_slug="$(slug_for "$FARM/edrj")"
mkdir -p "$PROJECTS/$landed_slug" "$PROJECTS/$ghost_slug"
mkdir -p "$STORAGE/ws-landed" "$STORAGE/ws-ghost" "$STORAGE/ws-main"
printf '{"folder":"file://%s"}\n' "$FARM/landed" >"$STORAGE/ws-landed/workspace.json"
printf '{"folder":"file://%s"}\n' "$FARM/edrj" >"$STORAGE/ws-ghost/workspace.json"
printf '{"folder":"file://%s"}\n' "$MAIN" >"$STORAGE/ws-main/workspace.json"

if run_script >/tmp/clean-worktrees-happy.out; then
  listed=0
  git -C "$MAIN" worktree list --porcelain | grep -q "$FARM/landed" && listed=1
  branched=0
  git -C "$MAIN" show-ref --verify --quiet refs/heads/landed && branched=1
  if [[ ! -e "$FARM/landed" && ! -e "$FARM/edrj" \
    && ! -e "$PROJECTS/$landed_slug" && ! -e "$PROJECTS/$ghost_slug" \
    && ! -e "$STORAGE/ws-landed" && ! -e "$STORAGE/ws-ghost" \
    && -d "$STORAGE/ws-main" \
    && "$listed" -eq 0 && "$branched" -eq 0 ]]; then
    pass "happy path clears worktree, leftover, caches, and merged branch"
  else
    fail "happy path left an artifact"
    cat /tmp/clean-worktrees-happy.out >&2 || true
  fi
else
  fail "happy path script failed"
  cat /tmp/clean-worktrees-happy.out >&2 || true
fi

if [[ ! -d "$FARM" ]] || [[ -z "$(ls -A "$FARM" 2>/dev/null || true)" ]]; then
  pass "empty farm directory cleaned"
else
  fail "farm still has children: $(ls -A "$FARM")"
fi

# --- farm inside primary is refused ---
assert_exit 2 "refuse farm inside primary checkout" \
  "$SCRIPT" --main-root "$MAIN" \
    --cursor-worktrees-root "$MAIN/nested-farm" \
    --cursor-projects-root "$PROJECTS" \
    --workspace-storage-root "$STORAGE"

if [[ "$fails" -ne 0 ]]; then
  echo "$fails test(s) failed" >&2
  exit 1
fi
echo "all tests passed"
