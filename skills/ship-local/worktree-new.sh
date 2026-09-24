#!/usr/bin/env bash
# Create one task worktree the way Cursor does: wt-<slug> in the Cursor farm,
# a feature branch off the default branch, then the repo's create-time setup
# (.cursor/worktrees.json). /ship-local removes it after landing.
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage: worktree-new.sh <slug> [--main-root PATH] [--branch NAME] [--base REF]
                       [--farm PATH] [--no-setup]

  slug         lowercase kebab-case; folder wt-<slug>, branch feat/<slug>
  --main-root  primary checkout (default: resolved from the current repo)
  --farm       parent folder (default: ~/.cursor/worktrees/<repo-name>)
  --base       start point (default: main or master of the primary checkout)
EOF
  exit 2
}

SLUG=""
MAIN_ROOT=""
BRANCH=""
BASE=""
FARM=""
SETUP=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --main-root) MAIN_ROOT="${2:-}"; shift 2 ;;
    --branch) BRANCH="${2:-}"; shift 2 ;;
    --base) BASE="${2:-}"; shift 2 ;;
    --farm) FARM="${2:-}"; shift 2 ;;
    --no-setup) SETUP=0; shift ;;
    -h|--help) usage ;;
    -*) echo "error: unknown argument: $1" >&2; usage ;;
    *)
      [[ -z "$SLUG" ]] || usage
      SLUG="$1"
      shift
      ;;
  esac
done

[[ "$SLUG" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "error: slug must be lowercase kebab-case: '$SLUG'" >&2; exit 2; }
SLUG="${SLUG#wt-}"

if [[ -z "$MAIN_ROOT" ]]; then
  common="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || {
    echo "error: not inside a git repo; pass --main-root" >&2
    exit 2
  }
  MAIN_ROOT="$(dirname "$common")"
fi
MAIN_ROOT="$(cd "$MAIN_ROOT" && pwd -P)"
[[ -d "$MAIN_ROOT/.git" ]] || { echo "error: --main-root must be the primary checkout: $MAIN_ROOT" >&2; exit 2; }

if [[ -z "$BASE" ]]; then
  for candidate in main master; do
    if git -C "$MAIN_ROOT" show-ref --verify --quiet "refs/heads/$candidate"; then
      BASE="$candidate"
      break
    fi
  done
  [[ -n "$BASE" ]] || { echo "error: no main/master branch; pass --base" >&2; exit 2; }
fi

BRANCH="${BRANCH:-feat/$SLUG}"
FARM="${FARM:-$HOME/.cursor/worktrees/$(basename "$MAIN_ROOT")}"
WT="$FARM/wt-$SLUG"

[[ ! -e "$WT" ]] || { echo "error: $WT already exists (reuse it, or pick another slug)" >&2; exit 2; }
if git -C "$MAIN_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH"; then
  echo "error: branch $BRANCH already exists" >&2
  exit 2
fi

mkdir -p "$FARM"
git -C "$MAIN_ROOT" worktree add "$WT" -b "$BRANCH" "$BASE"
WT="$(cd "$WT" && pwd -P)"

run_setup() {
  local config="$WT/.cursor/worktrees.json"
  [[ -f "$config" ]] || { echo "setup: no .cursor/worktrees.json — skipped"; return 0; }
  python3 - "$config" "$WT" <<'PY' | while IFS= read -r -d '' step; do
import json, os, sys
config, wt = sys.argv[1], sys.argv[2]
data = json.load(open(config, encoding="utf-8"))
value = data.get("setup-worktree-unix") if os.name != "nt" else None
if value is None:
    value = data.get("setup-worktree")
steps = [value] if isinstance(value, str) else list(value or [])
for step in steps:
    script = os.path.join(wt, ".cursor", step)
    if os.path.isfile(script):
        step = f'bash "{script}" "{wt}"'
    sys.stdout.write(step + "\0")
PY
    echo "setup: $step"
    (cd "$WT" && ROOT_WORKTREE_PATH="$MAIN_ROOT" bash -c "$step" </dev/null) || return 1
  done
}

if [[ "$SETUP" -eq 1 ]] && ! run_setup; then
  echo "error: create-time setup failed; tree kept at $WT (fix, then re-run the setup)" >&2
  exit 1
fi

echo "worktree: $WT"
echo "branch: $BRANCH (off $BASE)"
echo "next: work inside $WT (cd into it in every command); /ship-local removes it after landing"
