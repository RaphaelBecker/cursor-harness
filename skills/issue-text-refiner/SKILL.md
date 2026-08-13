---
name: issue-text-refiner
description: >-
  Rewrite approved GitHub issues into an ambiguity-free, AI-agent-ready body:
  context, user story, minimal-click UX, acceptance criteria, blockers, and
  market edge when applicable. Use from /batch-issue-refine after HIL 1, or
  when the developer asks to refine issue text. Does not push to GitHub.
---

# Issue text refiner

Apply to `BUG FIX` items and HIL-1-approved features (`PROCEED` / `PRUNE` with
the kept scope). Ignore `DISCARD`.

## Ambiguity

Resolve open questions from drafts, strategy, and the validation report using
code, routed docs, and notes. If a question still changes behavior and cannot
be closed, **STOP** that issue and ask — do not sync a hedged body.

## Blockers

Scan the rest of the batch plus linked issue numbers in bodies. Write blockers
as `Blocked by #N — reason` or `None`. Do not invent numbers.

## Body format (required)

Use the template in [`references/issue-body.md`](references/issue-body.md).
Every section must appear. Bugs omit **Market edge** (write `N/A — bug fix`).
`PRUNE` features describe only the kept scope. Acceptance criteria must be
strict, testable, and yes/no — no “should probably”.

## Output

- Per issue: `bodies/<number>.md` in the run dir (body only, no title heading
  unless the title itself must change — then note it separately).
- Index: `02-refined-issues.md` (title, tag, blockers, one-line change vs draft).

Do **not** run `gh issue edit`. Return control to `@batch-issue-refine`.
