#!/usr/bin/env bash
# Prove symlink install writes relative vendor links that match across checkouts.
set -euo pipefail

HARNESS="$(cd "$(dirname "$0")" && pwd)"
fails=0
pass() { echo "ok - $1"; }
fail() { echo "not ok - $1" >&2; fails=$((fails + 1)); }

ROOT="$(mktemp -d "${TMPDIR:-/tmp}/harness-symlink.XXXXXX")"
trap 'rm -rf "$ROOT"' EXIT

install_into() {
  local dest="$1"
  mkdir -p "$dest/vendor"
  ln -s "$HARNESS" "$dest/vendor/cursor-harness"
  cp "$HARNESS/templates/harness.project.yaml" "$dest/harness.project.yaml"
  "$HARNESS/install.sh" --target "$dest" --mode symlink >/dev/null
}

install_into "$ROOT/a"
install_into "$ROOT/b"

hook_a="$(readlink "$ROOT/a/.cursor/hooks/context-governor.sh")"
hook_b="$(readlink "$ROOT/b/.cursor/hooks/context-governor.sh")"
skill_a="$(readlink "$ROOT/a/.cursor/skills/clean-worktrees")"
skill_b="$(readlink "$ROOT/b/.cursor/skills/clean-worktrees")"

if [[ "$hook_a" == "../../vendor/cursor-harness/hooks/scripts/context-governor.sh" ]]; then
  pass "hook link goes through vendor/cursor-harness"
else
  fail "hook link is $hook_a"
fi
if [[ "$skill_a" == "../../vendor/cursor-harness/skills/clean-worktrees" ]]; then
  pass "skill link goes through vendor/cursor-harness"
else
  fail "skill link is $skill_a"
fi
if [[ "$hook_a" == "$hook_b" && "$skill_a" == "$skill_b" ]]; then
  pass "two checkouts get identical relative link text"
else
  fail "link text differs across checkouts ($hook_a vs $hook_b)"
fi

resolved="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$ROOT/a/.cursor/hooks/context-governor.sh")"
want="$(python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$HARNESS/hooks/scripts/context-governor.sh")"
if [[ "$resolved" == "$want" ]]; then
  pass "relative hook link resolves into this harness"
else
  fail "hook resolved to $resolved want $want"
fi

if [[ ! -e "$ROOT/a/.cursor/hooks/guard-destructive-shell.test.sh" ]] \
  && ! grep -q 'test\.sh' "$ROOT/a/.cursor/.gitignore"; then
  pass "hook tests are not installed"
else
  fail "hook test file was installed or ignored"
fi

ln -s ../../vendor/cursor-harness/hooks/scripts/guard-destructive-shell.test.sh \
  "$ROOT/b/.cursor/hooks/guard-destructive-shell.test.sh"
"$HARNESS/install.sh" --target "$ROOT/b" --mode symlink >/dev/null
if [[ ! -L "$ROOT/b/.cursor/hooks/guard-destructive-shell.test.sh" ]]; then
  pass "reinstall removes a stale hook test link"
else
  fail "stale hook test link survived reinstall"
fi

if [[ "$fails" -ne 0 ]]; then
  echo "$fails test(s) failed" >&2
  exit 1
fi
echo "all tests passed"
