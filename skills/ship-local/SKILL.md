---
name: ship-local
description: >-
  Human-triggered local ship that owns the git merge workflow: commit feature work,
  bring local default branch up to date, integrate main-ahead into the feature branch,
  auto-resolve merge conflicts, land everything on clean local default branch, then
  remove only the current feature worktree. Never remote push, deploy, or Phase 7.
  Use when the developer runs /ship-local after a merge-ready Phase 5 handoff.
---

# Ship local (reliable merge → clean default branch)

Goal: leave **local default branch (`main` or `master`) clean, up to date, and complete**
with all feature work (code, migrations, docs, harness, SemVer bumps) collected from the
feature branch — ready for the human to run `/ship-prod` or the project's documented
push/deploy scripts.

Remote ship stays human. This skill owns **local git workflow only**.

## Activation

Only when the human explicitly invokes `/ship-local` or clearly asks to ship local /
merge to local main (and clean up the worktree) after a merge-ready Phase 5 handoff.

Do **not** auto-run at the end of `@execute-approved-plan`.

## Scoped git / worktree authority

Agents must not create or manage branches/worktrees in general. **When human-invoked,
this skill alone may:**

1. Commit remaining ship-scoped work on the feature branch.
2. Operate on the primary repo checkout (`move_agent_to_root` / `git -C <main-root>`).
3. Update local default branch (FF from `origin/<default>` when safe).
4. Merge default ↔ feature (including conflict resolution commits).
5. Delete the merged local feature branch if safe (`-d`).
6. Remove **only** the feature worktree used for this cycle.

Never remove an unrelated worktree. Never stash/absorb unrelated dirty work — **STOP**
and ask if the tree has contract-irrelevant dirt.

## Preconditions

1. Phase 5 handoff exists with merge-ready evidence (prefer green **worktree proof**
   for test-relevant work; docs/harness-only may note N/A per contract). **Do not
   require idle-main complete on the feature worktree.**
2. `## Lessons learned` + `@project-memory` Phase 5 Candidates / cycle status done
   (this skill does not invent lessons).
3. Feature worktree path, feature branch name, and primary default-branch root are known.
4. No unrelated dirty/staged files on feature or default-branch checkouts.
5. **Blast radius:** if the landed allowlist touches shared modules, lifecycle,
   money, auth, or wire formats, the handoff must contain `## Blast radius`
   with a safety fact at trust-ladder step 4 (ran it) or labeled **unproven**.
   If that block is missing, run `@blast-radius` and write it **before**
   merging. Skip copy-only and docs-only lands.

## Reliable merge protocol (do in order)

Record SHAs at each step in the handoff. Use the project's default branch name
(`main` or `master`).

### 1) Commit feature tip

In the **feature** worktree:

1. `git status` — only ship-intended files.
2. Commit any remaining changes (why-focused message). Tree must be clean on the
   feature branch before merging.

### 2) Refresh local default branch (may be ahead of the feature)

On the **primary** checkout (default-branch worktree):

1. Ensure checkout is the default branch and clean.
2. `git fetch origin` (network OK for this skill when human-invoked).
3. If `origin/<default>` is ahead of local default and local can fast-forward:
   `git merge --ff-only origin/<default>`.
4. If local default has diverged from `origin/<default>` (non-FF): **do not reset or force**.
   Continue with local default as the integration base and note divergence in the handoff
   (human decides remote reconcile later). Still merge the feature into this local default.

### 3) Integrate default into the feature branch (absorb main-ahead)

Prefer **merge** (not rebase) so shared/Cursor history stays stable:

1. On the feature branch (feature worktree):  
   `git merge <default>` (or `git merge <default-tip-sha>`).
2. If already up to date → continue.
3. If conflicts → run **Conflict resolution** (below), commit the merge on the feature
   branch, continue.
4. Do **not** use blanket `git merge -X ours/theirs` for the whole merge.

### 4) Land feature onto local default

On the **primary** default checkout:

1. Prefer `git merge --ff-only <feature-branch>` after step 3 produced a tip that
   contains the default branch (FF is ideal).
2. If FF is impossible, `git merge --no-ff <feature-branch>` with a clear message
   (e.g. `merge: land <feature> onto main`).
3. If conflicts appear here → resolve with the same Conflict resolution rules, commit
   the merge on the default branch.

Success criterion: every intended feature commit (and its merge resolutions) is an
ancestor of local default, and the default branch’s working tree is **clean**.

### 5) Post-merge integrity check

On clean local default:

1. `git status` clean; `git log --oneline -5` shows the land/merge.
2. Confirm migrations/docs/code from the feature are present (spot-check paths from the
   Phase 5 allowlist / handoff).
3. Confirm no conflict markers remain: search for `<<<<<<<`, `=======`, `>>>>>>>`.
4. Do **not** run remote push. Do **not** run idle-main complete as part of landing
   one feature. If other feature worktrees or live test-pool leases remain, say so
   in the handoff. Optionally note which project push/deploy path applies
   (discover from README / CI / deploy docs).

### 6) Cleanup

Only after step 5 succeeds:

1. `git worktree remove` for **this** feature worktree only.
2. Delete the merged local feature branch with `git branch -d` (not `-D` unless the
   human explicitly confirms).
3. Leave the agent on the primary default-branch checkout.

### 7) Handoff

- Local default tip SHA; feature tip SHA that was merged
- Whether `origin/<default>` was FF’d into local default
- Conflicts resolved (file list + one-line how) or “none”
- Worktree removed / branch deleted
- Echo **Cycle status** from `project_memory.md`
- Next human step: `/ship-prod` (owns the one idle-main complete, then watched
  deliver), or project push/deploy scripts if they drive remote themselves
- State clearly: **local default is ready for idle-main complete / remote deliver**
  when no other trees or live test-pool leases remain (or list blockers)

## Conflict resolution (auto — required)

When Git reports conflicts, **resolve them in this skill** until the merge can complete.
Do not stop at the first conflict marker and hand the mess back unless a hard-stop
below applies.

### Method

1. List conflicted files (`git diff --name-only --diff-filter=U`).
2. For each file, open both sides / conflict markers and produce a correct combined
   result that preserves **default-ahead fixes** and **feature work**.
3. `git add` each resolved file; commit the merge when the index is fully resolved.
4. Re-run integrity check (no markers left).

### Per-path rules

| Situation | Resolution |
| --- | --- |
| New file added on both sides with **different paths** | Keep both |
| Versioned migrations | Never drop either side’s migration. Keep all distinct migration files. If the **same** filename conflicts, merge content so both intents survive (or rename the feature migration to a later timestamp and keep both). Never delete default’s migrations to “win”. |
| Lockfiles (`package-lock.json`, etc.) | Merge manifests first with real content resolution, then regenerate the lockfile with the project’s package manager and stage it |
| Generated types/artifacts | Prefer regenerate via project script rather than hand-merging huge diffs when practical |
| Product/source/docs/skills | Integrate both intents; do not silently discard default-ahead bugfixes or feature additions |
| `project_memory.md` Candidates / cycle status | Keep Architecture union; for Candidates table merge rows by `id` (union); refresh cycle status after merge |
| Duplicate SemVer bumps | Keep the correct single SemVer for the landed work; note the choice |

### Hard stops (ask human — do not guess)

Stop with a clear question only if:

- Conflict involves secrets, `.env*`, credentials, or prod vault files
- Resolving would require deleting or rewriting security/billing/money invariants
  with no clear combined answer from code+docs
- Unrelated dirty files appeared mid-flight
- Default vs `origin/<default>` needs a destructive reset to reconcile

After a hard stop: leave the repo in a recoverable state (conflicted merge still in
progress is OK if labeled); do **not** remove the worktree; do **not** force-push.

## Non-goals

- No `git push`, project deploy scripts, PR approval, deploy, or prod secrets sync
- No Phase 7 memory consolidate / harness promote
- No creating extra worktrees; no touching other agents’ worktrees
- No `git reset --hard`, force-push, or deleting unrelated branches
- No weakening test evidence from Phase 5 (do not claim tests were re-run unless you ran them)

## Evidence report

Protocol steps run, SHAs, conflict file list + resolutions, cleanup actions, cycle
status echo, ready-for-remote-ship yes/no.
**No remote push or deployment was performed.**
