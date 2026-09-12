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

Goal: leave the **primary default-branch checkout** ready for a new batch of
human-created worktrees. Remove leftover feature trees, half-deleted ghost
folders, and stale Cursor project/workspace artifacts for **this repo only**.

This skill does **not** land work. `/ship-local` still owns merge + one-tree
cleanup after a merge-ready handoff.

## Activation

Only when the human explicitly invokes `/clean-worktrees` or clearly asks to
reset leftover worktrees / workspaces / farm artifacts before a new parallel
batch.

Do **not** auto-run after `/ship-local`, Nightshift, or `@execute-approved-plan`.

## Do not drop out

A turn that only promises the cleanup is a failure. Resolve the primary root,
`move_agent_to_root` if this chat is bound to a feature tree, then run the
bundled script in the same turn.

## Scoped authority

Agents must not create or manage worktrees in general. **When human-invoked,
this skill may:**

1. Operate on the primary default checkout (`move_agent_to_root` / `git -C`).
2. Remove **clean, already-landed** feature worktrees for this repo.
3. Delete ghost leftover folders under this repo’s Cursor farm.
4. Delete matching Cursor project caches and workspaceStorage folders whose
   `folder` URI points at a removed tree.
5. Delete a **stale** `.cursor/ship-local.lock` (holder gone or older than 30
   minutes).

Never create a worktree. Never merge, rebase, push, or deploy. Never delete the
primary checkout. Never write files back into a deleted tree. Never sweep
unrelated repos under `~/.cursor/worktrees/`.

## Preconditions

1. This checkout is the **primary** default branch (`main` or `master`, `.git`
   is a directory). If the chat is bound to a feature tree: `move_agent_to_root`
   first.
2. No live `/ship-local` lock. If the lock’s holder tree still exists and the
   stamp is younger than 30 minutes → **STOP**.
3. Dirty or unmerged feature trees are **spared** (not force-deleted).

## Protocol

### 1) Resolve roots

- `MAIN` = primary default-branch path (`git rev-parse --show-toplevel` after
  moving to root). Refuse a linked worktree (`.git` file).
- Optional `--keep PATH` when the human named a tree to spare.
- `--dry-run` only when the human asked for a preview.

### 2) Run the bundled script

From the primary checkout (never with cwd inside a feature tree):

```bash
bash .cursor/skills/clean-worktrees/clean-worktrees.sh \
  --main-root "$MAIN"
```

Preview:

```bash
bash .cursor/skills/clean-worktrees/clean-worktrees.sh \
  --main-root "$MAIN" --dry-run
```

Spare a live tree:

```bash
bash .cursor/skills/clean-worktrees/clean-worktrees.sh \
  --main-root "$MAIN" --keep "$PATH"
```

Shell description must cite `/clean-worktrees` and
`$MAIN/.cursor/skills/clean-worktrees/SKILL.md`. Human `/clean-worktrees` is the
authorization. If Auto-review blocks: same turn, retry with
`request_smart_mode_approval` and that block reason. Do not stop.

Do **not** hand-roll `git worktree remove` or `rm -rf` of worktrees. The script
calls `ship-local/cleanup-worktree.sh` per tree.

Do **not** Write hook scripts (or anything else) into an orphan
`.cursor/hooks/` after a delete. That recreates the ghost folder.

### 3) Read the report

| Line | Meaning |
| --- | --- |
| `remove:` / `would-remove:` | Deleted (or preview) |
| `skip: … (dirty)` / `(unmerged)` / `(merge-in-progress)` | Spared — human must ship or discard |
| `skip: … (keep)` | Spared on request — not a failure |
| `skip: … (standalone-clone)` | Refused — not this repo’s linked tree |
| `lock: live` | STOP — wait for `/ship-local` |
| `gone:` / `skipped:` | Counts |

Exit `0` = ready for a new batch (or dry-run preview). Exit `1` = partial
(skipped dirty/unmerged/clone). Exit `2` = refused (wrong root, live lock).

### 4) Handoff

Chat: ~8–12 short lines. Primary tip + branch. What was removed. What was
spared. Cursor’s Worktrees sidebar may still show a stale row — the human
dismisses it; there is no API for that list.

**Required last line:** `DONE` or `PARTIAL: <exact leftover>`.

## Safety rails (script-enforced)

- Primary checkout and default branch names are never removed.
- Unique unmerged commits and dirty trees are skipped.
- Standalone clones (`.git` directory) are skipped.
- Cursor farm default is `$HOME/.cursor/worktrees/<repo-basename>` only.
- Tests must pass `--cursor-worktrees-root` (never touch the real farm).

## Tests

```bash
bash .cursor/skills/clean-worktrees/clean-worktrees.test.sh
```
