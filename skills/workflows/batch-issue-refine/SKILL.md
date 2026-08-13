---
name: batch-issue-refine
description: >-
  Day-shift batch of GitHub Ready-column issues: ingest and triage, strategy and
  value-validate features, rewrite AI-ready issue text, human-gated board sync.
  Use when the developer runs /batch-issue-refine, asks to refine a Ready batch,
  validate Kanban issue texts, or prepare issues for an implementation wave.
  Does not implement code or write an implementation contract.
---

# Batch issue refine

Thin **Day** orchestrator. Board-text hygiene only. Reuse the five phase skills
below — do not reinvent them here.

This is **not** `/feature-delivery` or `/bugfix`. Do **not** run `@grill-me`,
`/implementation-plan-review`, or `@execute-approved-plan`. Do **not** write
product code.

State `[Batch step: N — Name]` on each reply. Track steps with TodoWrite.

## Local config (required once)

Read `.cursor/batch-issue-refine.local.md` if present (copy from harness
`templates/batch-issue-refine.local.example.md`). If missing, ask once for:
GitHub owner, project number, Ready-column name, dogfooding-notes path (or skip).

## Sequence

1. **Ingest** — `@batch-issue-ingest` (5–10 Ready items; tag `BUG FIX` or `NEW FEATURE`).
2. **Strategy** — `@market-ux-strategy` on **features only**. Bugs skip to step 4 after the gate.
3. **Value** — `@value-validator` on **features only**. Status: `PROCEED` / `PRUNE` / `DISCARD`.
4. **HIL 1 — Value & strategy gate** (features in the batch):
   - Show the validation report.
   - **STOP.** Do not refine feature texts yet.
   - Wait until the human confirms discards and approves remaining features.
   - Bugs-only batch: skip this gate and continue.
5. **Refine** — `@issue-text-refiner` on bugs + approved features (`PRUNE` uses the cut scope).
6. **Preview** — `@issue-board-sync` builds the unified preview + `gh issue edit` script.
   Do **not** run the script yet.
7. **HIL 2 — Alignment & sync gate**:
   - Human reads every refined text.
   - **STOP.**
   - Run the sync script **only** after they explicitly say to execute / overwrite the board.

## Hard stops

- Never `gh issue edit` / close / delete before HIL 2 execute.
- Never invent GitHub project ids, competitors, or dogfooding notes.
- Never start technical implementation planning.
- Open questions at HIL 2 → do not sync; resolve or ask.

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
