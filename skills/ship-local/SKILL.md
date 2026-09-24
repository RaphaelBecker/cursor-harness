---
name: ship-local
disable-model-invocation: true
description: >-
  Human-triggered local ship that owns the git merge workflow: commit feature work,
  bring local default branch up to date, integrate main-ahead into the feature branch,
  auto-resolve merge conflicts, land everything on clean local default branch, then
  remove only the current feature worktree. Already on default: commit leftovers only.
  Never remote push, deploy, or Phase 7.
  Use when the developer runs /ship-local after a merge-ready Phase 5 handoff.
---

# Ship local (reliable merge → clean default branch)

Goal: local default (`main`/`master`) is clean, up to date, and holds all feature
work (code, migrations, docs, harness, SemVer, Phase 5 `project_memory.md`), and
the feature worktree is gone. Remote ship stays human.

Only when the human invokes `/ship-local` (or clearly asks to land on local main).
Never auto-run at the end of `@execute-approved-plan`.

**Do not drop out.** Commit, `move_agent_to_root`, and `land.sh` run as Shell calls
in the same turn as their announcement. Exit 3/4 means fix and re-run in this turn.

## Already on default (fast path)

1. `ship.lock acquire` (portable: `.git/ship-local.lock`). Busy → **STOP**.
2. Run `ship.leftovers -- --apply` when set; else commit `project_memory.md` and
   tip product, reset night-shift working files (do not commit), restore
   generated noise.
3. No merge, no worktree remove. Release the lock (always, try/finally).
4. Handoff: default tip SHA, leftovers committed. Next: `/ship-prod`.

## Authority (human-invoked only)

Commit ship-scoped work on the feature branch; operate on the primary checkout;
FF default from `origin/<default>`; merge default ↔ feature with conflict
resolution; delete the merged feature branch (`-d`); remove **only** this cycle's
feature worktree via the bundled scripts. Never touch other worktrees; never stash
or absorb unrelated dirt (secrets, other worktree, live merge → **STOP**).

## Preconditions

1. Phase 5 handoff with merge-ready evidence (green worktree proof; docs/harness
   may be N/A). Do **not** require idle-main complete on the feature tree.
2. `## Lessons learned` in `HANDOFF.md`; `@project-memory` Phase 5 done.
3. **Blast radius:** shared modules, lifecycle, money, auth, or wire formats need
   `## Blast radius` in the handoff (trust-ladder step 4, or labeled **unproven**).
   Missing → run `@blast-radius` before landing. Skip copy/docs-only lands.

## Protocol

### 1) Commit the feature tip

In the feature tree: `ship.leftovers -- --apply` when set (archives the approved
plan, resets night-shift files), then commit everything ship-scoped (allowlist +
`project_memory.md` + archived plan). Why-focused message.

### 2) Land (one script)

`move_agent_to_root` to the primary checkout **while the feature tree is intact**,
then with `working_directory=<main-root>`:

```bash
bash .cursor/skills/ship-local/land.sh \
  --main-root "$MAIN" --worktree "$FEATURE" --branch "$BRANCH"
```

Shell description cites `/ship-local` and this SKILL.md (human `/ship-local` is
the authorization; if Auto-review blocks, retry with `request_smart_mode_approval`).

The script holds the exclusive lock (`ship.lock` or `.git/ship-local.lock`) for
its own run only, runs leftovers on both trees, FFs default from origin (notes
divergence, never resets), merges default into the feature, lands FF or
`--no-ff`, checks conflict markers, releases the lock, then removes the tree and
merged branch via `cleanup-worktree.sh`.

| Exit | Meaning | Do |
| --- | --- | --- |
| 0 | Landed, tree + branch gone | Handoff |
| 2 | Refused (lock busy, STOP leftovers, markers, wrong root) | Report; lock busy → retry after the holder |
| 3 | Conflicts in the feature tree | **Conflict resolution** below, commit the merge there, re-run |
| 4 | Dirty tree (listed paths) | Commit ship-scoped paths, re-run; STOP-class → stop |
| 5 | Landed, tree still on disk | Run `/clean-worktrees` in the same sitting |

Do not hand-roll `git worktree remove` / `rm -rf`. Do not write files into a
deleted tree (recreates a ghost folder). If Shell cannot spawn because the chat
is bound to a half-deleted tree: `move_agent_to_root`, re-run from main.

After exit 0: spot-check landed paths from the allowlist. Do not run idle-main
complete for one land; list other live trees or pool leases in the handoff.

## Conflict resolution (auto — required)

Resolve in the feature tree until the merge commits. List files with
`git diff --name-only --diff-filter=U`; combine both sides; `git add`; commit; no
markers left. Never blanket `-X ours/theirs`.

| Situation | Resolution |
| --- | --- |
| Distinct new files | Keep both |
| Versioned migrations | Keep every distinct migration. Same filename → merge both intents, or move the feature migration to a later timestamp. Never delete default's |
| Lockfiles | Merge manifests, regenerate the lockfile with the project's package manager |
| Generated types/artifacts | Regenerate via project script |
| Product/source/docs/skills | Integrate both intents; keep default-ahead fixes |
| `project_memory.md` | Union Architecture; merge Candidates rows by `id`; refresh cycle status |
| Duplicate SemVer bumps | One correct SemVer for the landed work; note the choice |
| Night-shift / plans | Delete leftover `contract.md`; never land a foreign `approved` plan |

**Hard stops (ask):** secrets / `.env*` / vault; security, billing, or money
invariants with no clear combined answer; unrelated dirt mid-flight; default vs
origin needs a destructive reset. Leave the merge recoverable, do not remove the
tree, do not force-push. The script already released the lock.

## Non-goals

No push, deploy, PR approval, prod secrets, Phase 7, extra worktrees, `reset
--hard`, or deleting unrelated branches. Do not claim tests you did not run.

## Handoff

Chat ~8 lines: default tip SHA, feature tip merged, conflicts (or none), tree
removed (only after exit 0), lock released, ready for idle-main complete / remote
ship when no other trees or leases remain. Long evidence in `HANDOFF.md` (do not
commit). **No remote push or deployment was performed.**
**Required last line:** `DONE` or `PARTIAL: <exact leftover>`.
