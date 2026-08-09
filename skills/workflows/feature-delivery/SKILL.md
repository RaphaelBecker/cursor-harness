---
name: feature-delivery
description: >-
  Day-to-night spine for a new feature or page. Use when the developer wants a
  full feature delivery workflow from grilling through approved implementation,
  TDD, verification, docs sync, scored lessons, local ship, and Phase 7 memory.
---

# Feature delivery

Thin orchestrator. Reuse existing skills — do not reinvent the lifecycle.

## Day shift

1. Load domain memory (`@project-memory`) and route docs (`doc-routing`).
2. `@grill-me` until material decisions are closed.
3. Draft the implementation plan for the human to read.
4. Wait for human `/implementation-plan-review`, then explicit contract approval.
5. Do not implement before approval.

## Night shift (after approval)

1. `@execute-approved-plan`
2. Feature path: `@generate-bdd-test-spec` → tests RED → implement → GREEN
3. Verification ladder per `testing` rule (do not redefine steps or repair caps here).
4. Phase 4b: `@review-code` (fix-capable). Phase 4c: `/review-bugbot` report-only;
   also `/review-security` when the allowlist touches auth, access control, billing,
   admin, or secrets. Do not auto-fix 4c findings.
5. Phase 5: `@sync-spec-docs` (product story / acceptance — not file trees).
6. Handoff must include `## Lessons learned`, then `@project-memory` Phase 5
   (Candidates upsert/bump/stage + cycle status). Do not edit Architecture here.
7. Stop for human `/ship-local` (local default merge + current worktree cleanup). After a
   batch is on local default, human `/ship-prod` (watched remote ship, CI fix loop,
   Phase 7) — or they drive project push/deploy scripts themselves.

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
