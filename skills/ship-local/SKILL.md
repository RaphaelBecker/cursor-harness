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

Goal: leave **local default branch (`main` or `master`) clean, up to date, and complete**
with all feature work (code, migrations, docs, harness, SemVer bumps, Phase 5
`project_memory.md`) collected from the feature branch — ready for the human to run
`/ship-prod` or the project's documented push/deploy scripts.

Remote ship stays human. This skill owns **local git workflow only**.

## Activation

Only when the human explicitly invokes `/ship-local` or clearly asks to ship local /
merge to local main (and clean up the worktree) after a merge-ready Phase 5 handoff.

Do **not** auto-run at the end of `@execute-approved-plan`.

## Already on default (fast path)

If this checkout **is already** the project default branch:

1. Acquire the exclusive lock. If acquire fails → **STOP**.
2. Classify leftovers the same way `/ship-prod` does: commit `project_memory.md` and
   uncommitted product that belongs to this tip; reset night-shift working files to
   the draft stub (do not commit them); restore generated noise.
3. Do **not** merge. Do **not** `git worktree remove` the primary checkout.
4. Release the lock (**always**, including failure — try/finally).
5. Chat handoff: default tip SHA; leftovers committed; night-shift reset. Next:
   `/ship-prod`. **Required last line:** `DONE` or `PARTIAL: <exact leftover>`.

## Scoped git / worktree authority

Agents must not create or manage branches/worktrees in general. **When human-invoked,
this skill alone may:**

1. Commit remaining ship-scoped work on the feature branch (including Phase 5
   `project_memory.md`).
2. Operate on the primary repo checkout (`move_agent_to_root` / `git -C <main-root>`).
3. Update local default branch (FF from `origin/<default>` when safe).
4. Merge default ↔ feature (including conflict resolution commits).
5. Delete the merged local feature branch if safe (`-d`).
6. Remove **only** the feature worktree used for this cycle (`git worktree remove --force`
   when the tree has submodules / vendor checkouts).

Never remove an unrelated worktree. Never stash/absorb unrelated dirty work — **STOP**
and ask if the tree has STOP-class dirt (secrets, other worktree, live merge). This
checkout's night-shift working files and `project_memory.md` are ship-scoped, not
unrelated.

## Preconditions

1. Phase 5 handoff exists with merge-ready evidence (prefer green **worktree proof**
   for test-relevant work; docs/harness-only may note N/A per contract). **Do not
   require idle-main complete on the feature worktree.**
2. `## Lessons learned` lives in `HANDOFF.md`; `@project-memory` Phase 5 Candidates /
   cycle status done (this skill does not invent lessons). Commit leftover
   `project_memory.md` if it is still dirty.
3. Feature worktree path, feature branch name, and primary default-branch root are known
   (skip on the already-on-default fast path).
4. No STOP-class dirty/staged files on feature or default-branch checkouts.
5. **Exclusive lock (mandatory, one `/ship-local` at a time).** Parallel worktrees
   must not land on local default together — merge conflicts become unresolvable.
   Before touching the default branch (protocol step 2), acquire the lock (see
   **Exclusive lock** below). If acquire fails → **STOP**. Do not merge, do not
   resolve, do not remove a worktree. Tell the human who holds the lock and to
   retry after that land finishes.
6. **Blast radius:** if the landed allowlist touches shared modules, lifecycle,
   money, auth, or wire formats, the handoff must contain `## Blast radius`
   with a safety fact at trust-ladder step 4 (ran it) or labeled **unproven**.
   If that block is missing, run `@blast-radius` and write it **before**
   merging. Skip copy-only and docs-only lands.

## Exclusive lock

Serialize all `/ship-local` runs onto one local default branch.

1. If `harness.project.yaml` sets `ship.lock`, run that command with `acquire`,
   then later `release`. Example: `./scripts/ship-local-lock.sh acquire`.
2. If `ship.lock` is omitted, use the portable lockfile:
   - Acquire: create `.cursor/ship-local.lock` containing `pid\tbranch\tworktree\tiso-ts`.
     `mkdir` the parent if needed. If the file exists, read it. If the holder
     worktree is gone, or the timestamp is older than 30 minutes, replace it
     (stale). Otherwise **STOP** and report the holder branch.
   - Release: delete `.cursor/ship-local.lock` only if this run created or owns it.
     Never delete another worktree’s live lock.
3. Acquire **before** protocol step 2 (refresh local default). **Release as soon as
   local default is clean, before worktree remove.** Always release on failure
   (try/finally) after a hard stop this run caused while holding the lock.

## Reliable merge protocol (do in order)

Record SHAs at each step in `HANDOFF.md`. Use the project's default branch name
(`main` or `master`). Skip this protocol on the already-on-default fast path.

### 0) Acquire exclusive lock

Run the lock acquire from **Exclusive lock**. Stop if it fails.

### 1) Commit feature tip

In the **feature** worktree:

1. `git status` — ship-intended files include the allowlist **and** `project_memory.md`.
2. Reset or delete night-shift working files; do not commit them.
3. Commit any remaining changes (why-focused message). Tree must be clean on the
   feature branch before merging.

### 2) Refresh local default branch (may be ahead of the feature)

On the **primary** checkout (default-branch worktree):

1. Ensure checkout is the default branch and clean (reset inherited night-shift
   executables if they are dirty).
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
4. Reset night-shift working files on default to the draft stub — do not leave an
   `approved` contract on default.
5. Do **not** run remote push. Do **not** run idle-main complete as part of landing
   one feature. If other feature worktrees or live test-pool leases remain, say so
   in the handoff. Optionally note which project push/deploy path applies
   (discover from README / CI / deploy docs).

### 6) Release lock, then cleanup

Only after step 5 succeeds. Use try/finally so a failed remove cannot hold the lock.

1. **Release the exclusive lock** (default is now clean).
2. `git worktree remove --force` for **this** feature worktree only (needed when the
   tree has submodules / vendor checkouts).
3. Delete the merged local feature branch with `git branch -d` (not `-D` unless the
   human explicitly confirms).
4. Leave the agent on the primary default-branch checkout.

If remove fails: lock is already free; report the leftover tree. Do not keep the
lock held for a 30 min TTL.

### 7) Handoff

Chat: ~8–12 short lines. Default tip SHA; feature tip merged; conflicts or none;
worktree removed; lock released. Next: `/ship-prod`.

**Required last line:** `DONE` or `PARTIAL: <exact leftover>`.

Long evidence (SHAs, conflict list, cycle status) stays in `HANDOFF.md` (do not commit).
State clearly: **local default is ready for idle-main complete / remote deliver**
when no other trees or live test-pool leases remain (or list blockers).

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
| Night-shift working files | Prefer delete / draft stub; do not land a foreign `approved` contract onto default |

### Hard stops (ask human — do not guess)

Stop with a clear question only if:

- Conflict involves secrets, `.env*`, credentials, or prod vault files
- Resolving would require deleting or rewriting security/billing/money invariants
  with no clear combined answer from code+docs
- Unrelated dirty files appeared mid-flight (STOP-class)
- Default vs `origin/<default>` needs a destructive reset to reconcile

After a hard stop: leave the repo in a recoverable state (conflicted merge still in
progress is OK if labeled); **release the lock**; do **not** remove the worktree;
do **not** force-push.

## Non-goals

- No `git push`, project deploy scripts, PR approval, deploy, or prod secrets sync
- No Phase 7 memory consolidate / harness promote
- No creating extra worktrees; no touching other agents’ worktrees
- No `git reset --hard`, force-push, or deleting unrelated branches
- No weakening test evidence from Phase 5 (do not claim tests were re-run unless you ran them)

## Evidence report

Protocol steps run, SHAs, conflict file list + resolutions, cleanup actions, lock
released, ready-for-remote-ship yes/no. Chat stays compact; details in `HANDOFF.md`.
**No remote push or deployment was performed.**
**Required last line:** `DONE` or `PARTIAL: <exact leftover>`.
