---
name: feature-delivery
description: >-
  Prep-then-Nightshift spine for a new feature or page in a human-created Cursor
  worktree. Use during /prep when packing several trees, or for one tree.
  Packet grill, contract approval, then unattended execute after fire.
---

# Feature delivery

Thin orchestrator. Reuse existing skills — do not reinvent the lifecycle.
Prefer `/prep` when preparing several trees.

## Prep (HIL)

1. Confirm this is a **human-created** Cursor worktree. Do not create one.
2. Load domain memory (`@project-memory`) and route docs (`doc-routing`).
3. `@grill-me` in **packet mode** until material decisions are closed.
4. Draft `.cursor/night-shift/contract.md` (`status: draft`, `commits: authorized`,
   **Manual test** filled).
5. Wait for human `/implementation-plan-review`, then explicit contract approval
   (`status: approved`).
6. Do not implement before approval. Remind `/night-shift` fire (or stay and run
   `@execute-approved-plan` only if the human asks).

## Nightshift (after fire / approval)

1. `@execute-approved-plan`
2. Feature path: `@generate-bdd-test-spec` if the `bdd` pack is installed, else
   acceptance tests from the contract → tests RED → implement → GREEN
3. Verification ladder per `testing` rule.
4. Phase 4b: `@review-code`. Phase 4c: `/review-bugbot` report-only;
   `/review-security` when sensitive. Do not wait on 4c.
5. Phase 5: `@sync-spec-docs`, **`## Lessons learned`**, `@project-memory` Phase 5,
   `HANDOFF.md` with **Manual test** and `ready-for-manual-test` when true.
6. After: human tests, then `/ship-local` / `/ship-prod`.

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
