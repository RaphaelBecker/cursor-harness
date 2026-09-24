#!/usr/bin/env bash
# /ship-local steps 2-6 in one resumable run: lock, refresh default, merge default
# into the feature, land on default, integrity + leftovers, release, ship.after_land
# (e.g. sync local DB state to the new default), remove the tree.
# Exit: 0 landed+cleaned, 2 refused (STOP), 3 conflicts in the feature tree (resolve,
# commit, re-run), 4 dirty tree (commit ship-scoped paths, re-run), 5 landed but the
# tree is still on disk (run /clean-worktrees). Never pushes.
set -euo pipefail

usage() {
  echo "usage: land.sh --main-root PATH --worktree PATH --branch NAME [--no-fetch]" >&2
  exit 2
}

MAIN="" WT="" BRANCH="" FETCH=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --main-root) MAIN="${2:-}"; shift 2 ;;
    --worktree) WT="${2:-}"; shift 2 ;;
    --branch) BRANCH="${2:-}"; shift 2 ;;
    --no-fetch) FETCH=0; shift ;;
    *) usage ;;
  esac
done
[[ -n "$MAIN" && -n "$WT" && -n "$BRANCH" ]] || usage

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
MAIN="$(cd "$MAIN" && pwd -P)"
WT="$(cd "$WT" && pwd -P)"
cd "$MAIN"

say() { echo "land: $*"; }
die() { local code="$1"; shift; echo "land: $*" >&2; exit "$code"; }

[[ -d "$MAIN/.git" ]] || die 2 "--main-root must be the primary checkout"
DEFAULT="$(git branch --show-current)"
[[ "$DEFAULT" == main || "$DEFAULT" == master ]] || die 2 "primary is on '$DEFAULT', not main/master"
[[ "$BRANCH" != "$DEFAULT" ]] || die 2 "already on default: use the fast path"
[[ "$(git -C "$WT" branch --show-current)" == "$BRANCH" ]] || die 2 "$WT is not on $BRANCH"

project_get() {
  python3 "$HERE/../../runtime/project_config.py" get "$1" --target "$MAIN" 2>/dev/null || true
}
LOCK_CMD="$(project_get ship.lock)"
LEFTOVERS_CMD="$(project_get ship.leftovers)"
PORTABLE_LOCK="$MAIN/.git/ship-local.lock"
LOCK_HELD=0

acquire_lock() {
  if [[ -n "$LOCK_CMD" ]]; then
    (cd "$WT" && bash -c "$LOCK_CMD acquire") || die 2 "lock busy — another /ship-local is landing; retry after it"
  else
    if [[ -f "$PORTABLE_LOCK" ]]; then
      local holder ts
      IFS=$'\t' read -r _ _ holder ts <"$PORTABLE_LOCK" || true
      if [[ -d "$holder" && -n "$ts" ]] && python3 -c 'import sys,datetime as d
t=d.datetime.fromisoformat(sys.argv[1].replace("Z","+00:00"))
sys.exit(0 if d.datetime.now(d.timezone.utc)-t < d.timedelta(minutes=30) else 1)' "$ts" 2>/dev/null; then
        die 2 "lock held by $holder"
      fi
    fi
    mkdir -p "$(dirname "$PORTABLE_LOCK")"
    printf '%s\t%s\t%s\t%s\n' "$$" "$BRANCH" "$WT" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >"$PORTABLE_LOCK"
  fi
  LOCK_HELD=1
}

release_lock() {
  [[ "$LOCK_HELD" -eq 1 ]] || return 0
  LOCK_HELD=0
  if [[ -n "$LOCK_CMD" ]]; then
    (cd "$WT" && bash -c "$LOCK_CMD release") || echo "land: warning: lock release failed" >&2
  else
    rm -f "$PORTABLE_LOCK"
  fi
  say "lock released"
}
trap release_lock EXIT

run_leftovers() {
  local dir="$1"
  [[ -n "$LEFTOVERS_CMD" ]] || return 0
  local rc=0
  (cd "$dir" && bash -c "$LEFTOVERS_CMD -- --apply") || rc=$?
  [[ "$rc" -eq 0 ]] || die 2 "leftovers STOP in $dir (secret, vault, or live merge)"
}

require_clean() {
  local dir="$1" dirt
  dirt="$(git -C "$dir" status --porcelain)"
  [[ -z "$dirt" ]] || die 4 "commit these ship-scoped paths in $dir, then re-run:"$'\n'"$dirt"
}

acquire_lock

[[ -z "$(git -C "$WT" rev-parse -q --verify MERGE_HEAD 2>/dev/null)" ]] ||
  die 3 "merge in progress in $WT — resolve, commit, re-run"
run_leftovers "$WT"
require_clean "$WT"
run_leftovers "$MAIN"
require_clean "$MAIN"

if [[ "$FETCH" -eq 1 ]] && git fetch -q origin "$DEFAULT" 2>/dev/null; then
  if git merge-base --is-ancestor HEAD "origin/$DEFAULT"; then
    git merge -q --ff-only "origin/$DEFAULT"
  elif ! git merge-base --is-ancestor "origin/$DEFAULT" HEAD; then
    say "note: local $DEFAULT diverged from origin/$DEFAULT (left as is)"
  fi
fi

PRE="$(git rev-parse HEAD)"
if ! git -C "$WT" merge -q --no-edit "$DEFAULT"; then
  die 3 "conflicts merging $DEFAULT into $BRANCH in $WT:"$'\n'"$(git -C "$WT" diff --name-only --diff-filter=U)"
fi

if git merge-base --is-ancestor "$BRANCH" HEAD; then
  say "$BRANCH already on $DEFAULT"
elif ! git merge -q --ff-only "$BRANCH" 2>/dev/null; then
  git merge -q --no-ff -m "merge: land $BRANCH onto $DEFAULT" "$BRANCH" || {
    git merge --abort || true
    die 3 "unexpected conflict landing on $DEFAULT (aborted); re-run"
  }
fi

markers="$(git diff --name-only "$PRE" HEAD | while IFS= read -r f; do
  [[ -f "$f" ]] && grep -lE '^(<<<<<<<|>>>>>>>) ' "$f" || true
done)"
[[ -z "$markers" ]] || die 2 "conflict markers on $DEFAULT: $markers"

run_leftovers "$MAIN"
require_clean "$MAIN"
say "$DEFAULT at $(git rev-parse --short HEAD) (was ${PRE:0:8})"
release_lock
AFTER_LAND_CMD="$(project_get ship.after_land)"
if [[ -n "$AFTER_LAND_CMD" ]]; then
  bash -c "$AFTER_LAND_CMD" || echo "land: warning: ship.after_land failed (land is done)" >&2
fi

if bash "$HERE/cleanup-worktree.sh" --main-root "$MAIN" --worktree "$WT" --branch "$BRANCH" &&
  [[ ! -e "$WT" ]]; then
  say "worktree removed: $WT"
  exit 0
fi
die 5 "landed, but $WT is still on disk — run /clean-worktrees"
