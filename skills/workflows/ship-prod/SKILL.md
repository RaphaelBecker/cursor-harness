---
name: ship-prod
disable-model-invocation: true
description: >-
  Human-triggered production delivery of local default branch: classify and
  absorb this checkout's leftovers, verify local green, diagnose + Bugbot
  when complete stays red after isolate, run the project's documented
  push/deploy path, watch CI, fix red runs with bugfix + Bugbot sidekick,
  then Phase 7 memory after watched green. Use when the developer
  runs /ship-prod after work is on local default (often AFK).
---

# Ship prod (local default → watched CI → green → Phase 7)

Thin orchestrator for the **remote** delivery stage. Reuse existing skills and the
project's documented deploy/CI workflow — do not invent a second CI system.

`/ship-local` owns local merge. **`/ship-prod` owns watched remote ship** when the
human invokes it. If the human is already on default (built on `main`/`master`),
this skill commits leftovers and ships — do not send them back to `/ship-local`.

## Activation

Only when the human explicitly invokes `/ship-prod` or clearly asks to ship / deploy
production from local default branch (with CI watch and fix).

Invoking this skill **authorizes** leftover commits on this checkout, the project's
documented push/deploy commands, CI-fix commits on the default branch, and re-pushes
until watched green (or a hard stop).

Do **not** auto-run at the end of `/ship-local` or `@execute-approved-plan`.

## Do not drop out

A turn that only announces the next step is a failure. The Shell/tool call
must be in that same message.

Once `harness.project.yaml` is read, use `ship.leftovers`, `test.full`, and
the project's documented ship command. Do not rediscover them by reading
implementation files. Do not load `@project-memory` until watched green
(Phase 7).

Required moving commands (skip only when already proven for this `HEAD`):

1. Leftovers classify (`ship.leftovers` + `-- --apply` when set)
2. Wait until the test-pool lease is idle (project wait-idle, else harness
   `slots-status` poll)
3. Idle-main complete (`test.full`) on a test-relevant tip — wait for it.
   If the Shell tool has a wait budget, set it above the gate (often
   15–45+ minutes). If the tool backgrounds the process, keep polling
   until it exits. Do not read the test runner instead of running it.
4. Project ship/push command (watch until terminal if the project wraps
   watch into that command). Same wait rule as complete.
5. Phase 7 `@project-memory` only after watched green — list staged ids;
   do not stop to ask

Ignore compact nags until the current required command has been invoked.
Never run `/summarize` mid-ship.

Between "pool is idle" / "starting complete" and the `test.full` Shell
call, there must be no text-only turn.

## Dirt classifier (run first; do not ask)

If `harness.project.yaml` sets `ship.leftovers`, run that command. Add `-- --apply`
when absorbing (reset night-shift working files and generated noise; it must **not**
commit). Non-zero exit → **STOP**. Never stash.

If `ship.leftovers` is omitted: reset night-shift working files (do not commit);
commit `project_memory.md` and tip product; restore generated noise. Secrets /
`.env*` / vault / other worktree / live merge → **STOP**. Never stash.

Absorb **this checkout's** leftovers so the human can leave. After classify, the
tree must be clean before idle-main complete. Prefer the project's
`--reset-night-shift` when it exists.

## Preconditions

On the **primary** default-branch checkout:

1. Branch is the project default (`main`/`master`). Dirt classifier above has run;
   working tree is clean (or only STOP-class dirt remains — then stop).
2. Intended feature commits are ancestors of `HEAD` (post `/ship-local`, or commits
   already made on default).
3. **Live-lease check:** if another worktree holds a shared test-pool slot, **wait**
   (bounded, default 20 min) — do not abort the ship because a leftover gate is
   finishing. Prefer the project's `wait-idle` / equivalent; else poll
   `./vendor/cursor-harness/runtime/night-shift slots-status` (exit 0 = live, exit 1
   = idle). Dead PIDs are idle. If still held after the wait → **STOP**.
4. Unhealthy slot / leftover containers: run the project's documented recover path
   (warm the pool for **that** project id only). Do not ask.
5. Self-hosted runners: if the project uses them and they are not Listening, start
   them per project docs; leave them up.
6. **Test-relevant tip:** green **idle-main complete** evidence for **this** `HEAD`
   (`test.full` or the discovered CI-parity gate), or run it now — only after the
   lease wait is idle. Docs/harness-only tips may use the project's docs-only ship
   path when one exists. Restore generated noise the complete run rewrote.
7. `gh` authenticated. If a sandboxed `gh` call fails, **retry outside the sandbox**
   before treating it as a missing login.
8. If prod secrets changed: follow the project's documented vault/sync path — never
   invent one.

If STOP-class preconditions fail → **STOP** and report blockers. Do not push.

## Sequence

### 0) Local complete red (before first push)

If idle-main complete is red, do not push. Follow the `testing` rule
**Idle-main complete red** section. Do **not** call it a flake storm yet.

1. Isolate only the failing listed suite (project's existing runner).
2. Isolate **green** → suite-load flake. Re-run complete once (the one
   transient infra retry). If green, continue the ship.
3. Isolate **still red** (same or related assertion) → read `@diagnose-bug`.
   Always run `/review-bugbot` in this sitting (and `/review-security` if
   the surface is auth, access control, billing, admin, or secrets).
   Write the red command + hypotheses to `HANDOFF.md` immediately.
4. After diagnose names the seam: smallest fix on this tip → prove with
   the isolated suite → re-run complete. Repair caps stay in the `testing`
   rule. Apply only sound, in-scope fixes from Bugbot.
5. **STOP** only for true hard-stops (secrets, live payments, production,
   vault) or when diagnose cannot name a seam after the probes. Do **not**
   STOP merely because the suite is billing or the failures look mixed.
   Do not invoke `/fix-flaky-test` from this spine.

### 1) Classify and push

1. Prefer the project's documented ship/deploy script over bare `git push`.
2. Discover the correct command from README, Makefile, package scripts, or deploy docs
   (test-relevant vs docs-only when the project distinguishes them).
3. Streamed terminal / CI output is the primary evidence.

### 2) Watch

1. Stay with `gh run watch` (or the project's equivalent) until terminal state.
   Optional: `/loop` if the human wants a longer keep-alive session.
2. Never ask the human to paste CI logs or open the GitHub UI unless CLI tooling is unavailable.
3. If watch refuses a stale run id, list runs for the pushed SHA and watch that id —
   do not re-push.

### 3) On red — fix loop (Bugbot sidekick)

Treat CI failure as a bug fix (`core-principles` / `@diagnose-bug` when the
seam is unnamed), scoped to the failing check and this tip:

1. Fetch failed logs via `gh run view --log-failed` (or project equivalent).
2. Optional first pass: `ci-investigator` for a short root-cause summary.
   If logs do not name the seam → read `@diagnose-bug`.
3. **RED first** when the failure reveals an untested path (regression before product fix).
4. Smallest fix → prove with the narrowest relevant check, then ladder per `testing` rule
   as required for the change class (do not weaken gates).
5. **Bugbot sidekick:** always run `/review-bugbot` when isolate stayed red, when
   root cause is unclear after reading logs, after one failed fix/re-push, or
   when the human asks. Also `/review-security` if the failing surface is auth,
   access control, billing, admin, or secrets. Bugbot stays a report-capable
   reasoning aid — apply only sound, in-scope fixes.
6. Commit on default branch → re-run the project's ship command → return to Watch.
7. Repair budget: follow the `testing` rule. **STOP** only for true hard-stops
   (secrets, live payments, production, vault) or when diagnose cannot name a
   seam. Do not STOP merely because the suite is billing or failures look mixed.

Leftover-container / slot-unhealthy infra: recover via the project path, then
`gh run rerun --failed` (or equivalent). Do not re-push for that class.

### 4) On watched green

1. **Test-relevant** green (including final green after a fix loop): enter **Phase 7**
   via `@project-memory`. Write Architecture if needed. Commit + docs-only push when
   memory files changed. **Do not wait** for staged-harness approve/reject — list
   staged ids in the short ship handoff for a later sitting.
2. **Docs-only** ship success: do **not** enter Phase 7.
3. Emit a short ship handoff (below).

## Gates / hard stops

| Gate | Rule |
| --- | --- |
| Human trigger | Required — this skill never self-starts |
| Local green | Idle-main complete for test-relevant `HEAD` before first push. Complete red + isolate red → diagnose-bug + Bugbot, then re-prove complete |
| Live test-pool lease | Wait (bounded), then STOP only if still held |
| Secrets / vault | Do not invent or copy local env to prod; stop if vault/auth unclear |
| Scope of CI fixes | Only what the red run needs; no drive-by refactors |
| Hard denies | Do not weaken tests/CI to go green; no force-push; no destructive prod DB ops |
| Phase 7 promote | List staged ids; do not wait for approve/reject in this sitting |
| STOP-class dirt | Secrets, other worktree, live `/ship-local` merge — never stash |

## Non-goals

- No feature planning (`grill-me` / plan review) — that is `/prep`
- No local merge / worktree cleanup — that is `/ship-local` (skip when already on default)
- No autonomous cloud deploy; no draft-PR automation path
- No claiming Phase 7 after docs-only pushes

## Outputs (chat handoff)

8–12 short lines. Local default SHA; ship command; complete evidence; CI run id +
status; fix commits (or none); Phase 7 done/skipped; staged ids if any.

**Required last line:**

- `DONE` — fully shipped (watched green, Phase 7 done or correctly skipped)
- `PARTIAL: <exact leftover>` — only what was not done

Put the long evidence in `.cursor/night-shift/HANDOFF.md` (working artifact; do not
commit). Do not dump 4b/4c, lessons, or cycle status into chat.

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
