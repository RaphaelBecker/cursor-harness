---
name: ship-prod
description: >-
  Human-triggered production delivery of clean local default branch: verify local
  green, run the project's documented push/deploy path, watch CI, fix red runs
  with bugfix + Bugbot sidekick, then Phase 7 memory after watched green. Use
  when the developer runs /ship-prod after one or more /ship-local lands are
  ready to ship.
---

# Ship prod (local default → watched CI → green → Phase 7)

Thin orchestrator for the **remote** delivery stage. Reuse existing skills and the
project's documented deploy/CI workflow — do not invent a second CI system.

`/ship-local` owns local merge. **`/ship-prod` owns watched remote ship** when the
human invokes it.

## Activation

Only when the human explicitly invokes `/ship-prod` or clearly asks to ship / deploy
production from clean local default branch (with CI watch and fix).

Invoking this skill **authorizes** the project's documented push/deploy commands,
CI-fix commits on the default branch, and re-pushes until watched green (or a hard stop).

Do **not** auto-run at the end of `/ship-local` or `@execute-approved-plan`.

## Preconditions

On the **primary** default-branch checkout:

1. Branch is the project default (`main`/`master`); working tree clean (no unrelated
   dirty/staged files).
2. Intended feature commits are ancestors of `HEAD` (post one or more `/ship-local`).
3. **Live-lease check:** if another worktree holds a shared test-pool slot → **STOP**.
   Do not start idle-main complete on a noisy host. Prefer
   `./vendor/cursor-harness/runtime/night-shift slots-status` (exit 0 = live / STOP,
   exit 1 = idle). Or run `slots.status` / `slots.lease has-live-leases` from
   `harness.project.yaml`.
4. **Test-relevant tip:** green **idle-main complete** evidence for **this** `HEAD`
   (`test.full` or the discovered CI-parity gate), or run it now before push — only
   after the live-lease check is idle. Docs/harness-only tips may use the project's
   docs-only ship path when one exists.
5. `gh` authenticated (`gh auth login`) so watch + failed logs work when GitHub CI is used.
6. If prod secrets changed: follow the project's documented vault/sync path — never invent one.

If preconditions fail → **STOP** and report blockers. Do not push.

## Sequence

### 1) Classify and push

1. Prefer the project's documented ship/deploy script over bare `git push`.
2. Discover the correct command from README, Makefile, package scripts, or deploy docs
   (test-relevant vs docs-only when the project distinguishes them).
3. Streamed terminal / CI output is the primary evidence.

### 2) Watch

1. Stay with `gh run watch` (or the project's equivalent) until terminal state.
   Optional: `/loop` if the human wants a longer keep-alive session.
2. Never ask the human to paste CI logs or open the GitHub UI unless CLI tooling is unavailable.

### 3) On red — fix loop (Bugbot sidekick)

Treat CI failure as a bug fix (`core-principles` / `bugfix`), scoped to the failing
check and this tip:

1. Fetch failed logs via `gh run view --log-failed` (or project equivalent).
2. Optional first pass: `ci-investigator` for a short root-cause summary.
3. **RED first** when the failure reveals an untested path (regression before product fix).
4. Smallest fix → prove with the narrowest relevant check, then ladder per `testing` rule
   as required for the change class (do not weaken gates).
5. **Bugbot sidekick:** run `/review-bugbot` when root cause is unclear after reading
   logs, after one failed fix/re-push, or when the human asks. Also `/review-security`
   if the failing surface is auth, access control, billing, admin, or secrets.
   Bugbot stays report-capable reasoning aid — apply only sound, in-scope fixes.
6. Commit on default branch → re-run the project's ship command → return to Watch.
7. Repair budget: follow the `testing` rule. If blocked (flake storm, infra, secrets,
   ambiguous security/billing), **STOP** and ask the human.

### 4) On watched green

1. **Test-relevant** green (including final green after a fix loop): enter **Phase 7**
   via `@project-memory` (exact trigger line + Architecture / staged promote ask).
   Commit/push docs-only follow-up only if memory/harness files changed and the human/
   project path allows it.
2. **Docs-only** ship success: do **not** enter Phase 7.
3. Emit a short ship handoff (below).

## Gates / hard stops

| Gate | Rule |
| --- | --- |
| Human trigger | Required — this skill never self-starts |
| Local green | Idle-main complete for test-relevant `HEAD` before first push |
| Live test-pool lease | STOP — do not start complete on a noisy host |
| Secrets / vault | Do not invent or copy local env to prod; stop if vault/auth unclear |
| Scope of CI fixes | Only what the red run needs; no drive-by refactors |
| Hard denies | Do not weaken tests/CI to go green; no force-push; no destructive prod DB ops |
| Phase 7 promote | Staged harness edits still need explicit human approve/reject |
| Unrelated dirty tree | Stop and ask — never stash/absorb |

## Non-goals

- No feature planning (`grill-me` / plan review) — that is `/feature-delivery`
- No local merge / worktree cleanup — that is `/ship-local`
- No autonomous cloud deploy; no draft-PR automation path
- No claiming Phase 7 after docs-only pushes

## Outputs (handoff)

- Local default SHA pushed; which ship command was used
- Idle-main complete evidence (ran / reused / N/A docs-only)
- CI run id(s); final watched status
- Fix commits + Bugbot/security reviews used (or “none”)
- Phase 7 done / skipped (reason)
- Next: keep default branch clean; resume features via `/feature-delivery` as needed

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
