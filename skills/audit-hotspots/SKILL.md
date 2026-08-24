---
name: audit-hotspots
disable-model-invocation: true
description: >-
  Rank files by git churn times size and overlay coverage when already on disk.
  Use during codebase health audit or when prioritizing refactor debt.
  Report only — no patches.
---

# Audit hotspots

Report only. No patches.

## Scope

Discover source roots from the repo (typical: `src/`, `lib/`, `app/`, `services/`).
Last **90 days**. Skip lockfiles, generated types, and `vendor/`.

## Method

1. **Churn** — `git log --since=90.days --numstat --pretty=format: -- <roots>`
   Count a file once per commit. Sum inserted+deleted lines.
2. **Size** — line count on the top-churn files. Hotspot = high churn × high size.
3. **Coverage overlay** — if coverage JSON already exists on disk, note thin
   tests on hot files. Do **not** run a coverage gate just for this report.

## Output

Top N (default **15**): path | commits | lines changed | size | coverage if known | why.

Suggested next human contract per hotspot — no patches.
