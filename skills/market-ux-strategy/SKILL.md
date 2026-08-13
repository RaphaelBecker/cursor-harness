---
name: market-ux-strategy
description: >-
  Benchmark NEW FEATURE issues against public competitors, map a minimal-click
  UX flow, and extract the sales/value edge. Use from /batch-issue-refine on
  features only, or when the developer asks for market/UX strategy on issue
  drafts. Does not edit GitHub or write implementation plans.
---

# Market & UX strategy (features only)

Skip `BUG FIX` items.

## Inputs

Ingest table + issue bodies + dogfooding notes. Load **one** routed product-story
doc via `doc-routing` (plus local map). Load a small `@project-memory` slice if
present. Optional competitor names from local config.

## Work (per feature)

1. **Benchmark** — Search the public web for how comparable products do this job.
   Name 2–3 real competitors (or closest substitutes). Say what they do well and
   where this draft is weaker or copycat. Do not invent products or reviews.
2. **UX flow** — Map the shortest user-centric path (fewest clicks/screens).
   List steps as the user sees them. Cut setup the user does not need.
3. **Edge** — One tight value line: why this is the better execution *now*
   (speed, clarity, fewer steps, or a job others skip). If there is no edge,
   say so — the value skill may `DISCARD`.

## Output

Append `01-strategy.md` in the run dir: one section per feature (`#`, title,
benchmark, UX flow, edge, risks). Return control to `@batch-issue-refine`.
Do **not** STOP for the human here — HIL 1 comes after `@value-validator`.
