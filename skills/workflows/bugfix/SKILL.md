---
name: bugfix
disable-model-invocation: true
description: >-
  Prep-then-Nightshift spine for a bug fix in a human-created Cursor worktree.
  Failing regression first, then fix under an approved minimal contract.
---

# Bug fix

Thin orchestrator. Reuse existing skills.

## Prep (HIL)

1. Capture symptom, expected behavior, and where it shows up (unit / UI / E2E).
   Prefer `/prep` when this bug is one of several Nightshift trees.
2. **Non-trivial diagnose first:** run `@diagnose-bug` until one named command
   is already red on the user's symptom. Record that command in the contract
   **Tests** field. Do not grill or plan before that command exists.
3. For non-trivial or unsafe fixes: `@grill-me` **packet mode** then plan; human
   `/implementation-plan-review` + approve into `.cursor/night-shift/contract.md`.
4. **Trivial** path (skip diagnose/grill/plan/review) only when the human explicitly asks
   **and** the fix is single-file with no schema/auth/billing/security-sensitive surface.
   Still require RED regression → targeted green; write `commits: authorized`.

## Nightshift (after fire / approval or explicit trivial ask)

1. **Failing regression first** (`testing` rule bug-fix protocol) — RED before
   code change. Use the contract's named red command. If that command is
   missing in an unattended run → park `BLOCKED.md` (do not hypothesise).
2. `@execute-approved-plan` (or the same checklist for trivial approved fixes).
3. Implement the smallest fix → GREEN on the targeted test.
4. Verification ladder per `testing` rule (do not redefine steps or repair caps here).
5. Non-trivial path: Phase 4b `@review-code`, then Phase 4c `/review-bugbot` (and
   `/review-security` when sensitive) report-only — see `execute-approved-plan`.
6. `@sync-spec-docs` only if user-facing acceptance or thin contracts changed.
7. Handoff must include **Manual test**, `## Lessons learned`, then
   `@project-memory` Phase 5. Write `.cursor/night-shift/HANDOFF.md`. After:
   human tests, then `/ship-local` / `/ship-prod`.

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
