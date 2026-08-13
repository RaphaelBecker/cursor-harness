---
name: value-validator
description: >-
  Challenge NEW FEATURE issues for measurable value now, prune ~20% bloat, and
  mark PROCEED, PRUNE, or DISCARD. Use from /batch-issue-refine after market/UX
  strategy, or when the developer asks to grill a feature batch for value.
  Does not edit GitHub. Stops for the human only via the parent workflow HIL 1.
---

# Value validator & scope pruner (features only)

Skip `BUG FIX` items. This is **agent-side** grilling of the *feature*, not
`@grill-me` (do not interview the human here).

## Tests (per feature)

Answer from ingest + strategy + routed product story + notes. If a fact is
unknowable, record it as an open question — do not stall.

1. **Necessity now** — Does this add measurable value to the product *this
   wave*? Who feels it, in what job, how would we notice?
2. **Prune** — Cut about 20% of scope (nice-to-haves, extra states, extra
   settings) while keeping ~80% of the core job. List **cuts** vs **kept**.
3. **Status** — exactly one of:
   - `PROCEED` — ship the draft scope (tiny cuts optional)
   - `PRUNE` — ship only the kept list
   - `DISCARD` — drop from this batch (do not refine; do not auto-close)

Default to `PRUNE` when the edge is weak but the core job is real. Default to
`DISCARD` when there is no user, no edge, or it is the wrong time.

## Output

Write `01-validation-report.md` in the run dir:

- Summary counts: proceed / prune / discard / bugs (passthrough)
- Per feature: status, why, kept, cuts, open questions
- Bugs listed as auto-forward to refine

Return control to `@batch-issue-refine` for **HIL 1**. Do not start
`@issue-text-refiner` on features until the human confirms.
