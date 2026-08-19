---
name: architecture-improve
description: >-
  Incremental structure work: audit, pick one smell, packet grill, approve
  a contract, then one extract or one dependency fix. Use when the
  developer runs /architecture-improve. Not a rewrite.
disable-model-invocation: true
---

# Architecture improve

Thin orchestrator. One smell per run. Reuse existing skills.

## Prep (HIL)

1. Confirm a **human-created** Cursor worktree. Do not create one.
2. `@architecture-audit` — hot-spot scan, deletion test, report only.
3. **STOP.** Wait until the human picks one candidate.
4. `@grill-me` packet mode for that slice. Draft
   `.cursor/night-shift/contract.md` (`status: draft`, **Manual test**).
   Allowlist is one extract **or** one dependency-direction fix — not both.
5. Wait for human `/implementation-plan-review` and explicit
   `status: approved`.
6. Do not implement before approval. Remind `/night-shift` fire.

## Nightshift (after fire / approval)

1. `@execute-approved-plan`
2. Phase 3 is **only** `@extract-deep-module` or
   `@dependency-direction-fix` as the contract named.
3. Ladder, `@review-code`, Phase 4c report-only, Phase 5 handoff.
4. After: human tests, then `/ship-local` / `/ship-prod`.

Do not add a skill that "improves architecture" in general. Sensitive
boundary moves wait for `/review-security`; do not auto-fix.

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
