#!/usr/bin/env bash
# Reset leftover feature worktrees and Cursor workspace artifacts for one repo.
# Always run from --main-root (the primary default-branch checkout).
# Never creates worktrees. Never merges. Never pushes.
set -euo pipefail

usage() {
  echo "usage: clean-worktrees.sh --main-root PATH [--dry-run] [--keep PATH]... [--cursor-worktrees-root PATH] [--cursor-projects-root PATH] [--workspace-storage-root PATH]" >&2
  exit 2
}

MAIN_ROOT=""
DRY_RUN=0
KEEP_IN=()
FARM_ROOT=""
PROJECTS_ROOT=""
STORAGE_ROOT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --main-root)
      [[ $# -ge 2 ]] || usage
      MAIN_ROOT="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --keep)
      [[ $# -ge 2 ]] || usage
      KEEP_IN+=("$2")
      shift 2
      ;;
    --cursor-worktrees-root)
      [[ $# -ge 2 ]] || usage
      FARM_ROOT="$2"
      shift 2
      ;;
    --cursor-projects-root)
      [[ $# -ge 2 ]] || usage
      PROJECTS_ROOT="$2"
      shift 2
      ;;
    --workspace-storage-root)
      [[ $# -ge 2 ]] || usage
      STORAGE_ROOT="$2"
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

[[ -n "$MAIN_ROOT" ]] || usage

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP="$SCRIPT_DIR/../ship-local/cleanup-worktree.sh"

resolve_path() {
  python3 -c 'import os,sys; p=sys.argv[1]; print(os.path.realpath(p) if os.path.exists(p) else os.path.abspath(p))' "$1"
}

is_abs() {
  [[ "$1" == /* ]]
}

cursor_project_slug() {
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

path_variants() {
  python3 -c '
import os, sys
p = os.path.abspath(sys.argv[1]).rstrip("/")
out = [p]
if p.startswith("/private/var/"):
    out.append("/var/" + p[len("/private/var/"):])
elif p.startswith("/var/"):
    out.append("/private/var/" + p[len("/var/"):])
print("\n".join(out))
' "$1"
}

paths_match() {
  python3 -c '
import os, sys
def variants(p):
    p = os.path.abspath(p).rstrip("/")
    out = {p}
    if p.startswith("/private/var/"):
        out.add("/var/" + p[len("/private/var/"):])
    elif p.startswith("/var/"):
        out.add("/private/var/" + p[len("/var/"):])
    return out
sys.exit(0 if variants(sys.argv[1]) & variants(sys.argv[2]) else 1)
' "$1" "$2"
}

file_uri_path() {
  python3 -c '
import sys
from urllib.parse import unquote, urlparse
raw = sys.argv[1].strip()
if raw.startswith("file://"):
    parsed = urlparse(raw)
    print(unquote(parsed.path))
else:
    print(raw)
' "$1"
}

lock_is_stale() {
  local lock="$1"
  python3 -c '
import os, sys
from datetime import datetime, timezone, timedelta
path = sys.argv[1]
try:
    raw = open(path, encoding="utf-8").read().strip()
except OSError:
    sys.exit(0)
parts = raw.split("\t")
worktree = parts[2] if len(parts) >= 3 else ""
ts = parts[3] if len(parts) >= 4 else ""
if worktree and not os.path.exists(worktree):
    sys.exit(0)
if not ts:
    sys.exit(0)
try:
    parsed = datetime.fromisoformat(ts.replace("Z", "+00:00"))
except ValueError:
    sys.exit(0)
if parsed.tzinfo is None:
    parsed = parsed.replace(tzinfo=timezone.utc)
age = datetime.now(timezone.utc) - parsed.astimezone(timezone.utc)
sys.exit(0 if age > timedelta(minutes=30) else 1)
' "$lock"
}

MAIN_ROOT="$(resolve_path "$MAIN_ROOT")"

if ! is_abs "$MAIN_ROOT"; then
  echo "error: --main-root must be absolute" >&2
  exit 2
fi

if [[ ! -d "$MAIN_ROOT" ]]; then
  echo "error: --main-root is not a directory: $MAIN_ROOT" >&2
  exit 2
fi

if [[ ! -d "$MAIN_ROOT/.git" ]]; then
  echo "error: --main-root must be the primary checkout (.git directory), not a linked worktree" >&2
  exit 2
fi

if ! git -C "$MAIN_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: --main-root is not a git work tree: $MAIN_ROOT" >&2
  exit 2
fi

DEFAULT_BRANCH="$(git -C "$MAIN_ROOT" branch --show-current || true)"
if [[ "$DEFAULT_BRANCH" != "main" && "$DEFAULT_BRANCH" != "master" ]]; then
  echo "error: --main-root must be checked out on main or master (on '$DEFAULT_BRANCH')" >&2
  exit 2
fi

if [[ ! -x "$CLEANUP" ]]; then
  chmod +x "$CLEANUP" 2>/dev/null || true
fi
if [[ ! -f "$CLEANUP" ]]; then
  echo "error: missing sibling cleanup script: $CLEANUP" >&2
  exit 2
fi

REPO_NAME="$(basename "$MAIN_ROOT")"
if [[ -z "$FARM_ROOT" ]]; then
  FARM_ROOT="${HOME}/.cursor/worktrees/${REPO_NAME}"
fi
if [[ -z "$PROJECTS_ROOT" ]]; then
  PROJECTS_ROOT="${HOME}/.cursor/projects"
fi
if [[ -z "$STORAGE_ROOT" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]]; then
    STORAGE_ROOT="${HOME}/Library/Application Support/Cursor/User/workspaceStorage"
  else
    STORAGE_ROOT="${HOME}/.config/Cursor/User/workspaceStorage"
  fi
fi
FARM_ROOT="$(resolve_path "$FARM_ROOT")"
PROJECTS_ROOT="$(resolve_path "$PROJECTS_ROOT")"
STORAGE_ROOT="$(resolve_path "$STORAGE_ROOT")"

KEEP=()
for k in "${KEEP_IN[@]:-}"; do
  [[ -z "$k" ]] && continue
  KEEP+=("$(resolve_path "$k")")
done

is_kept() {
  local want="$1"
  local k
  for k in "${KEEP[@]:-}"; do
    [[ "$k" == "$want" ]] && return 0
  done
  return 1
}

is_same_or_inside() {
  python3 -c '
import os, sys
def norm(p):
    p = os.path.abspath(p)
    if p.startswith("/var/"):
        p = "/private/var/" + p[len("/var/"):]
    return p.rstrip("/")
outer, inner = norm(sys.argv[1]), norm(sys.argv[2])
sys.exit(0 if inner == outer or inner.startswith(outer + "/") else 1)
' "$1" "$2"
}

if [[ "$FARM_ROOT" == "/" || "$FARM_ROOT" == "$HOME" || "$PROJECTS_ROOT" == "/" || "$PROJECTS_ROOT" == "$HOME" ]]; then
  echo "error: refuse unsafe Cursor root" >&2
  exit 2
fi

if is_same_or_inside "$MAIN_ROOT" "$FARM_ROOT" || is_same_or_inside "$MAIN_ROOT" "$PROJECTS_ROOT"; then
  echo "error: Cursor roots must not sit inside the primary checkout" >&2
  exit 2
fi

listed_worktrees() {
  git -C "$MAIN_ROOT" worktree list --porcelain | sed -n 's/^worktree //p'
}

worktree_branch() {
  local want="$1"
  python3 -c '
import sys
want = sys.argv[1]
block = []
for line in sys.stdin:
    if line.strip() == "":
        path = ""
        branch = ""
        for row in block:
            if row.startswith("worktree "):
                path = row[len("worktree "):]
            elif row.startswith("branch refs/heads/"):
                branch = row[len("branch refs/heads/"):]
        if path == want:
            print(branch)
            break
        block = []
    else:
        block.append(line.rstrip("\n"))
' "$want" < <(git -C "$MAIN_ROOT" worktree list --porcelain; echo)
}

is_listed() {
  local want="$1"
  local p
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    [[ "$(resolve_path "$p")" == "$want" ]] && return 0
  done < <(listed_worktrees)
  return 1
}

tree_is_dirty() {
  local wt="$1"
  [[ -n "$(git -C "$wt" status --porcelain 2>/dev/null || true)" ]]
}

tree_is_merging() {
  local wt="$1"
  [[ -e "$wt/.git/MERGE_HEAD" ]] || git -C "$wt" rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1
}

tip_unmerged() {
  local wt="$1"
  local tip
  tip="$(git -C "$wt" rev-parse HEAD 2>/dev/null || true)"
  [[ -n "$tip" ]] || return 0
  ! git -C "$MAIN_ROOT" merge-base --is-ancestor "$tip" HEAD
}

LOCK="$MAIN_ROOT/.cursor/ship-local.lock"
LOCK_STATE="none"
if [[ -f "$LOCK" ]]; then
  if lock_is_stale "$LOCK"; then
    LOCK_STATE="stale"
  else
    echo "error: live /ship-local lock at $LOCK" >&2
    echo "lock: live" >&2
    exit 2
  fi
fi

REMOVED=()
SKIPPED=()
WOULD=()
STATUS=0
# keep is an intentional spare, not a leftover failure.

record() {
  local action="$1"
  local kind="$2"
  local path="$3"
  local why="${4:-}"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ "$action" == "skip" ]]; then
      SKIPPED+=("$kind $path${why:+ ($why)}")
      echo "skip: $kind $path${why:+ ($why)}"
    else
      WOULD+=("$kind $path")
      echo "would-remove: $kind $path"
    fi
    return
  fi
  if [[ "$action" == "skip" ]]; then
    SKIPPED+=("$kind $path${why:+ ($why)}")
    echo "skip: $kind $path${why:+ ($why)}"
    if [[ "$DRY_RUN" -eq 0 && "$why" != "keep" ]]; then
      STATUS=1
    fi
    return
  fi
  REMOVED+=("$kind $path")
  echo "remove: $kind $path"
}

do_rm() {
  local path="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi
  rm -rf "$path"
}

run_cleanup() {
  local wt="$1"
  local branch="${2:-}"
  local args=(--main-root "$MAIN_ROOT" --worktree "$wt")
  if [[ -n "$branch" && "$branch" != "main" && "$branch" != "master" ]]; then
    args+=(--branch "$branch")
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi
  bash "$CLEANUP" "${args[@]}"
}

echo "main-root: $MAIN_ROOT"
echo "dry-run: $([[ "$DRY_RUN" -eq 1 ]] && echo yes || echo no)"
if ((${#KEEP[@]})); then
  echo "keep: ${KEEP[*]}"
fi

if [[ "$LOCK_STATE" == "stale" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "lock: stale (would remove)"
  else
    rm -f "$LOCK"
    echo "lock: stale-removed"
  fi
else
  echo "lock: none"
fi

# Registered feature worktrees
while IFS= read -r raw; do
  [[ -z "$raw" ]] && continue
  wt="$(resolve_path "$raw")"
  [[ "$wt" == "$MAIN_ROOT" ]] && continue
  if is_kept "$wt"; then
    record skip worktree "$wt" keep
    continue
  fi
  branch="$(worktree_branch "$raw")"
  if tree_is_dirty "$wt"; then
    record skip worktree "$wt" dirty
    continue
  fi
  if tree_is_merging "$wt"; then
    record skip worktree "$wt" merge-in-progress
    continue
  fi
  if tip_unmerged "$wt"; then
    record skip worktree "$wt" "unmerged${branch:+ $branch}"
    continue
  fi
  if run_cleanup "$wt" "$branch"; then
    record remove worktree "$wt"
  else
    record skip worktree "$wt" cleanup-failed
  fi
done < <(listed_worktrees)

# Orphan farm folders for this repo name
if [[ -d "$FARM_ROOT" ]]; then
  shopt -s nullglob
  for child in "$FARM_ROOT"/*; do
    [[ -d "$child" ]] || continue
    wt="$(resolve_path "$child")"
    [[ "$wt" == "$MAIN_ROOT" ]] && continue
    if is_kept "$wt"; then
      record skip leftover "$wt" keep
      continue
    fi
    if is_listed "$wt"; then
      continue
    fi
    if [[ -d "$wt/.git" ]]; then
      record skip leftover "$wt" standalone-clone
      continue
    fi
    if run_cleanup "$wt"; then
      record remove leftover "$wt"
    else
      record skip leftover "$wt" cleanup-failed
    fi
  done
  shopt -u nullglob
  if [[ "$DRY_RUN" -eq 0 && -d "$FARM_ROOT" ]]; then
    rmdir "$FARM_ROOT" 2>/dev/null || true
  fi
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  git -C "$MAIN_ROOT" worktree prune >/dev/null 2>&1 || true
fi

# Cursor project caches + workspaceStorage for paths we removed (or would)
TARGETS=()
for row in "${REMOVED[@]:-}" "${WOULD[@]:-}"; do
  [[ -z "$row" ]] && continue
  path="${row#* }"
  TARGETS+=("$path")
done

if [[ -d "$PROJECTS_ROOT" ]]; then
  for path in "${TARGETS[@]:-}"; do
    [[ -z "$path" ]] && continue
    while IFS= read -r variant; do
      [[ -z "$variant" ]] && continue
      slug="$(cursor_project_slug "$variant")"
      dest="$PROJECTS_ROOT/$slug"
      if [[ -d "$dest" ]]; then
        record remove project-cache "$dest"
        do_rm "$dest"
      fi
    done < <(path_variants "$path")
  done
fi

if [[ -d "$STORAGE_ROOT" ]]; then
  shopt -s nullglob
  for ws in "$STORAGE_ROOT"/*; do
    [[ -d "$ws" ]] || continue
    meta="$ws/workspace.json"
    [[ -f "$meta" ]] || continue
    folder_raw="$(python3 -c 'import json,sys
try:
    data=json.load(open(sys.argv[1], encoding="utf-8"))
except Exception:
    raise SystemExit(0)
print(data.get("folder") or "")
' "$meta")"
    [[ -z "$folder_raw" ]] && continue
    folder="$(file_uri_path "$folder_raw")"
    if paths_match "$folder" "$MAIN_ROOT"; then
      continue
    fi
    hit=0
    for path in "${TARGETS[@]:-}"; do
      if paths_match "$folder" "$path"; then
        hit=1
        break
      fi
    done
    if [[ "$hit" -eq 0 && -n "$FARM_ROOT" ]] && is_same_or_inside "$FARM_ROOT" "$folder" && [[ ! -e "$folder" ]]; then
      hit=1
    fi
    if [[ "$hit" -eq 1 ]]; then
      record remove workspace-storage "$ws"
      do_rm "$ws"
    fi
  done
  shopt -u nullglob
fi

gone="${#REMOVED[@]}"
skipped="${#SKIPPED[@]}"
would="${#WOULD[@]}"
echo "gone: $gone"
echo "skipped: $skipped"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "would-remove: $would"
fi

if [[ "$STATUS" -ne 0 ]]; then
  exit 1
fi
exit 0
