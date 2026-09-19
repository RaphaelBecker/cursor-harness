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
bundled script in the same turn. If the script skips a tree with real project
work, ask Keep vs Discard in that same sitting and re-run with `--discard`.

## Scoped authority

Agents must not create or manage worktrees in general. **When human-invoked,
this skill may:**

1. Operate on the primary default checkout (`move_agent_to_root` / `git -C`).
2. Remove **already-landed** feature worktrees for this repo (including trees
   whose only git dirt is a harness vendor-symlink retarget).
3. After an explicit Keep/Discard answer, remove a tree that still has unshipped
   commits or project files (`--discard PATH`).
4. Delete ghost leftover folders under this repo’s Cursor farm.
5. Delete matching Cursor project caches and workspaceStorage folders whose
   `folder` URI points at a removed tree.
6. Delete a **stale** `.cursor/ship-local.lock` (holder gone or older than 30
   minutes).

Never create a worktree. Never merge, rebase, push, or deploy. Never delete the
primary checkout. Never write files back into a deleted tree. Never sweep
unrelated repos under `~/.cursor/worktrees/`. Never pass `--discard` unless the
human just chose Discard for that path.

## Preconditions

1. This checkout is the **primary** default branch (`main` or `master`, `.git`
   is a directory). If the chat is bound to a feature tree: `move_agent_to_root`
   first.
2. No live `/ship-local` lock. If the lock’s holder tree still exists and the
   stamp is younger than 30 minutes → **STOP**.
3. Vendor-symlink retargets (install rewrote a tracked link to this worktree’s
   `vendor/` copy of the same file) are **not** project dirt.
4. Real project dirt or unique unmerged commits: spare until the human chooses
   Keep or Discard. A merge in progress is never discarded.

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

Discard after the human said yes:

```bash
bash .cursor/skills/clean-worktrees/clean-worktrees.sh \
  --main-root "$MAIN" --discard "$PATH"
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
| `remove: … (discard)` | Deleted after the human chose Discard |
| `skip: … (dirty)` / `(unmerged)` | Real unshipped work — ask Keep vs Discard |
| `skip: … (merge-in-progress)` | Spare — finish or abort the merge |
| `skip: … (keep)` | Spared on request — not a failure |
| `skip: … (standalone-clone)` | Refused — not this repo’s linked tree |
| `lock: live` | STOP — wait for `/ship-local` |
| `gone:` / `skipped:` | Counts |

Exit `0` = ready for a new batch (or dry-run preview). Exit `1` = partial
(skipped dirty/unmerged/clone). Exit `2` = refused (wrong root, live lock).

### 4) Ask before dropping project work

If the report has `skip: … (dirty)` or `(unmerged)` (not `keep`):

1. For each path, summarize unique commits vs default (`git log main..HEAD`)
   and real dirty paths (`git status --porcelain`).
2. Ask the human, one choice per tree: **Keep** or **Discard anyway**. Weak or
   abandoned work may be discarded. Do not skip the question.
3. Keep → leave it. Discard → re-run the bundled script with `--discard PATH`
   (repeat the flag for each chosen tree). Do not invent a second remove path.

A merge-in-progress skip is not offered Discard.

### 5) Handoff

Chat: ~8–12 short lines. Primary tip + branch. What was removed. What was
spared. What the human chose on leftover project work. Cursor’s Worktrees
sidebar may still show a stale row — the human dismisses it; there is no API
for that list.

**Required last line:** `DONE` or `PARTIAL: <exact leftover>`.

## Safety rails (script-enforced)

- Primary checkout and default branch names are never removed.
- Unique unmerged commits and real project dirt are skipped unless `--discard`.
- Vendor-symlink retargets to the same `vendor/` file do not count as dirt.
- Standalone clones (`.git` directory) are skipped.
- Cursor farm default is `$HOME/.cursor/worktrees/<repo-basename>` only.
- Tests must pass `--cursor-worktrees-root` (never touch the real farm).

## Tests

```bash
bash .cursor/skills/clean-worktrees/clean-worktrees.test.sh
```
