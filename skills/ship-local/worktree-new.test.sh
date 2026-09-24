#!/usr/bin/env bash
# Usage: bash skills/ship-local/worktree-new.test.sh  (temp repos only)
set -uo pipefail

NEW="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/worktree-new.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
failures=0

fail() {
  echo "FAIL: $*"
  failures=$((failures + 1))
}

MAIN="$TMP/repo"
FARM="$TMP/farm"
git init -q -b main "$MAIN"
mkdir -p "$MAIN/.cursor"
cat >"$MAIN/.cursor/setup.sh" <<'EOF'
#!/usr/bin/env bash
echo "$1|$ROOT_WORKTREE_PATH" >"$1/.setup-ran"
EOF
printf '{ "setup-worktree-unix": "setup.sh", "setup-worktree": ["echo not-unix > .wrong"] }\n' >"$MAIN/.cursor/worktrees.json"
git -C "$MAIN" add -A
git -C "$MAIN" -c user.name=t -c user.email=t@t commit -qm init

out="$(cd "$MAIN" && bash "$NEW" demo-task --farm "$FARM" 2>&1)" || fail "create: $out"
WT="$(cd "$FARM/wt-demo-task" 2>/dev/null && pwd -P)"
[[ -n "$WT" ]] || fail "folder wt-demo-task missing"
[[ "$(git -C "$WT" branch --show-current 2>/dev/null)" == "feat/demo-task" ]] || fail "branch feat/demo-task not checked out"
MAIN_REAL="$(cd "$MAIN" && pwd -P)"
[[ "$(cat "$WT/.setup-ran" 2>/dev/null)" == "$WT|$MAIN_REAL" ]] || fail "unix setup script not run with path + ROOT_WORKTREE_PATH"
[[ ! -e "$WT/.wrong" ]] || fail "setup-worktree ran although setup-worktree-unix exists"
grep -q "^worktree: $WT$" <<<"$out" || fail "prints worktree path: $out"

out="$(cd "$WT" && bash "$NEW" demo-task --farm "$FARM" 2>&1)"
[[ $? -eq 2 ]] || fail "existing folder must refuse with exit 2: $out"

out="$(cd "$MAIN" && bash "$NEW" Bad_Slug --farm "$FARM" 2>&1)"
[[ $? -eq 2 ]] || fail "bad slug must refuse: $out"

printf '{ "setup-worktree-unix": ["exit 9"] }\n' >"$MAIN/.cursor/worktrees.json"
git -C "$MAIN" -c user.name=t -c user.email=t@t commit -qam red-setup
out="$(cd "$WT" && bash "$NEW" red-setup --farm "$FARM" 2>&1)"
[[ $? -eq 1 ]] || fail "failing setup must exit 1: $out"
[[ -d "$FARM/wt-red-setup" ]] || fail "failing setup keeps the tree for a retry"

if [[ "$failures" -gt 0 ]]; then
  echo "$failures failure(s)"
  exit 1
fi
echo "worktree-new: all cases pass"
