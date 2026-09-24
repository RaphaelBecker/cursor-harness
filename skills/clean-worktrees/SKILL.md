---
name: clean-worktrees
description: >-
  Removes leftover feature worktrees, ghost Cursor farm folders, and stale
  workspace artifacts so the primary checkout is ready for a new parallel
  batch. Use when the developer runs /clean-worktrees, asks to reset leftover
  worktrees or workspaces, or wants a clean slate before creating new agent
  worktrees. Never creates worktrees, never merges, never pushes.
disable-model-invocation: true
---

# Clean worktrees (reset the farm)

Goal: the **primary default-branch checkout** is ready for a new batch of
human-created worktrees. Removes leftover feature trees, half-deleted ghost
folders, and stale Cursor project/workspace artifacts for **this repo only**.
`/ship-local` still owns merge + one-tree cleanup (its exit 5 hands off here).

Only when the human invokes `/clean-worktrees` (or `/ship-local` exit 5 in the
same sitting). Never auto-run after Nightshift or `@execute-approved-plan`.

**Do not drop out.** `move_agent_to_root` if bound to a feature tree, then run
the script in the same turn. Skipped real work → ask Keep vs Discard now.

## What the script decides

Removed: landed trees (tip on default) whose only dirt is noise — night-shift
working files, files identical to default's `HEAD` (e.g. the archived plan),
project `ship.leftovers` `reset` rows (generated files), or a vendor-symlink
retarget. Ghost farm folders. Cursor project caches / workspaceStorage for
removed paths. A stale lock (`.git/ship-local.lock`, holder gone or > 30 min).

Spared: real project dirt, unique unmerged commits, merge in progress, a live
night agent (`.cursor/night-shift/agent.pid`), standalone clones, `--keep PATH`.
A live lock (`ship.lock status` = held, or a fresh portable lock) refuses the run.

Never: create a worktree, merge, push, delete the primary checkout, sweep other
repos under `~/.cursor/worktrees/`, or pass `--discard` without the human's
Discard for that path.

## Run

From the primary checkout (`.git` directory, on `main`/`master`):

```bash
bash .cursor/skills/clean-worktrees/clean-worktrees.sh --main-root "$MAIN" \
  [--dry-run] [--keep PATH]... [--discard PATH]...
```

`--dry-run` only when the human asked for a preview. Shell description cites
`/clean-worktrees` and this SKILL.md (the human command is the authorization;
if Auto-review blocks, retry with `request_smart_mode_approval`). Never hand-roll
`git worktree remove` / `rm -rf`; never Write into an orphan `.cursor/`.

| Line | Meaning |
| --- | --- |
| `remove:` / `would-remove:` | Deleted (or preview); `(discard)` after human Discard |
| `skip: … (dirty)` / `(unmerged)` | Unshipped work — ask Keep vs Discard |
| `skip: … (merge-in-progress)` / `(night-agent-running)` | Spare; not offered Discard |
| `skip: … (keep)` / `(standalone-clone)` | Spared on request / not this repo's tree |
| `lock: live` | STOP — wait for `/ship-local` |

Exit `0` ready (or preview), `1` partial (skips), `2` refused (root, live lock).

## Keep vs Discard

For each `dirty` / `unmerged` skip: summarize `git log main..HEAD` and real
`git status --porcelain` paths, ask **Keep** or **Discard anyway** (one choice per
tree). Discard → re-run with `--discard PATH`. No second remove path.

## Handoff

~8 lines: primary tip + branch, removed, spared, the human's choices. Cursor's
Worktrees sidebar may keep a stale row (human dismisses it).
**Required last line:** `DONE` or `PARTIAL: <exact leftover>`.

## Tests

`bash .cursor/skills/clean-worktrees/clean-worktrees.test.sh` (temp farm only;
tests pass `--cursor-worktrees-root`, never the real farm).
