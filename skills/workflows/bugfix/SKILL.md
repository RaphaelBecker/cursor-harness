---
name: bugfix
description: >-
  Day-to-night spine for a bug fix. Use when reproducing a defect, writing a
  failing regression first, then fixing under an approved minimal contract.
---

# Bug fix

Thin orchestrator. Reuse existing skills.

## Day shift

1. Capture symptom, expected behavior, and where it shows up (unit / UI / E2E).
2. For non-trivial or unsafe fixes: `@grill-me` then plan; human
   `/implementation-plan-review` + approve.
3. **Trivial** path (skip full grill/plan/review) only when the human explicitly asks
   **and** the fix is single-file with no schema/auth/billing/security-sensitive surface.
   Still require RED regression → targeted green; merge-ready still needs the project's
   full gate per the `testing` rule.

## Night shift (after approval or explicit trivial ask)

1. **Failing regression first** (`testing` rule bug-fix protocol) — RED before code change.
2. `@execute-approved-plan` (or the same checklist for trivial approved fixes).
3. Implement the smallest fix → GREEN on the targeted test.
4. Verification ladder per `testing` rule (do not redefine steps or repair caps here).
5. Non-trivial path: Phase 4b `@review-code`, then Phase 4c `/review-bugbot` (and
   `/review-security` when sensitive) report-only — see `execute-approved-plan`.
6. `@sync-spec-docs` only if user-facing acceptance or thin contracts changed.
7. Handoff must include `## Lessons learned`, then `@project-memory` Phase 5
   (Candidates + cycle status). Human `/ship-local` then `/ship-prod` when ready.

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
