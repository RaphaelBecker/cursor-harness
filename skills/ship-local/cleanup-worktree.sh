#!/usr/bin/env bash
# Remove one landed feature worktree and its merged local branch.
# Always cd to --main-root first. Never run this with cwd inside --worktree.
set -euo pipefail

usage() {
  echo "usage: cleanup-worktree.sh --main-root PATH --worktree PATH [--branch NAME]" >&2
  exit 2
}

MAIN_ROOT=""
WORKTREE=""
BRANCH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --main-root)
      [[ $# -ge 2 ]] || usage
      MAIN_ROOT="$2"
      shift 2
      ;;
    --worktree)
      [[ $# -ge 2 ]] || usage
      WORKTREE="$2"
      shift 2
      ;;
    --branch)
      [[ $# -ge 2 ]] || usage
      BRANCH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage
      ;;
  esac
done

[[ -n "$MAIN_ROOT" && -n "$WORKTREE" ]] || usage

resolve_path() {
  python3 -c 'import os,sys; p=sys.argv[1]; print(os.path.realpath(p) if os.path.exists(p) else os.path.abspath(p))' "$1"
}

is_abs() {
  [[ "$1" == /* ]]
}

MAIN_ROOT="$(resolve_path "$MAIN_ROOT")"
WORKTREE_IN="$WORKTREE"
WORKTREE="$(resolve_path "$WORKTREE")"

if ! is_abs "$MAIN_ROOT" || ! is_abs "$WORKTREE"; then
  echo "error: --main-root and --worktree must be absolute" >&2
  exit 2
fi

if [[ ! -d "$MAIN_ROOT" ]]; then
  echo "error: --main-root is not a directory: $MAIN_ROOT" >&2
  exit 2
fi

if ! git -C "$MAIN_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: --main-root is not a git work tree: $MAIN_ROOT" >&2
  exit 2
fi

COMMON_DIR="$(git -C "$MAIN_ROOT" rev-parse --git-common-dir)"
if [[ "$COMMON_DIR" != /* ]]; then
  COMMON_DIR="$MAIN_ROOT/$COMMON_DIR"
fi
COMMON_DIR="$(resolve_path "$COMMON_DIR")"

if [[ "$WORKTREE" == "$MAIN_ROOT" || "$WORKTREE" == "$COMMON_DIR" ]]; then
  echo "error: refuse to remove the primary checkout or git dir" >&2
  exit 2
fi

case "$WORKTREE" in
  "$MAIN_ROOT"/*)
    echo "error: refuse to remove a path inside the primary checkout" >&2
    exit 2
    ;;
  "$COMMON_DIR"/*)
    echo "error: refuse to remove a path inside the git dir" >&2
    exit 2
    ;;
esac

case "$MAIN_ROOT" in
  "$WORKTREE"/*)
    echo "error: refuse to remove an ancestor of the primary checkout" >&2
    exit 2
    ;;
esac

if [[ "$WORKTREE" == "/" || "$WORKTREE" == "$HOME" ]]; then
  echo "error: refuse to remove $WORKTREE" >&2
  exit 2
fi

# /tmp and /Users are too broad; require a nested path.
slash_count="${WORKTREE//[^\/]/}"
if [[ ${#slash_count} -lt 2 ]]; then
  echo "error: --worktree is too shallow: $WORKTREE" >&2
  exit 2
fi

if [[ -n "$BRANCH" && ( "$BRANCH" == "main" || "$BRANCH" == "master" ) ]]; then
  echo "error: refuse to delete default branch: $BRANCH" >&2
  exit 2
fi

cd "$MAIN_ROOT"
echo "main-root: $MAIN_ROOT"

worktree_listed() {
  local want="$1"
  local p resolved
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    [[ "$p" == "$want" || "$p" == "$WORKTREE_IN" ]] && return 0
    resolved="$(resolve_path "$p")"
    [[ "$resolved" == "$want" ]] && return 0
  done < <(git worktree list --porcelain | sed -n 's/^worktree //p')
  return 1
}

gitfile_points_here() {
  local gitfile="$1/.git"
  local raw gitdir
  [[ -f "$gitfile" ]] || return 1
  raw="$(tr -d '\r' <"$gitfile")"
  gitdir="${raw#gitdir: }"
  [[ "$gitdir" != "$raw" ]] || return 1
  gitdir="$(resolve_path "$gitdir")"
  [[ "$gitdir" == "$COMMON_DIR/worktrees/"* ]]
}

if [[ -e "$WORKTREE" && -d "$WORKTREE/.git" ]]; then
  echo "error: --worktree looks like a standalone clone, not a linked worktree" >&2
  exit 2
fi

if [[ -e "$WORKTREE" && -f "$WORKTREE/.git" ]] && ! gitfile_points_here "$WORKTREE"; then
  echo "error: --worktree gitdir does not belong to this repo" >&2
  exit 2
fi

if worktree_listed "$WORKTREE"; then
  if git worktree remove --force "$WORKTREE" && ! worktree_listed "$WORKTREE"; then
    echo "worktree: removed $WORKTREE"
  else
    echo "worktree: git remove incomplete; pruning"
    git worktree prune
  fi
else
  echo "worktree: not listed"
  git worktree prune
fi

if [[ -e "$WORKTREE" ]]; then
  if [[ -d "$WORKTREE/.git" ]]; then
    echo "error: refuse to rm a standalone clone: $WORKTREE" >&2
    exit 2
  fi
  rm -rf "$WORKTREE"
  echo "worktree: deleted leftover folder $WORKTREE"
fi

if [[ ! -e "$WORKTREE" ]]; then
  echo "worktree: gone $WORKTREE"
else
  echo "error: worktree folder still exists: $WORKTREE" >&2
  exit 1
fi

if worktree_listed "$WORKTREE"; then
  echo "error: git still lists $WORKTREE" >&2
  exit 1
fi

if [[ -z "$BRANCH" ]]; then
  echo "branch: skipped"
  exit 0
fi

if ! git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  echo "branch: already gone $BRANCH"
  exit 0
fi

if git merge-base --is-ancestor "$BRANCH" HEAD; then
  git branch -d "$BRANCH"
  echo "branch: deleted $BRANCH"
  exit 0
fi

echo "error: branch $BRANCH is not an ancestor of HEAD; left in place" >&2
exit 1
