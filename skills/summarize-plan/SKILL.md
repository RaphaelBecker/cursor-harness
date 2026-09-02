---
name: summarize-plan
disable-model-invocation: true
description: >-
  Restates an existing implementation plan in very simple words and compact
  bullets. Bug plans: what will be fixed, and which tests will be added,
  updated, fixed, or removed. Feature plans: what the feature does and what
  pain it solves for the user. Use when the developer runs /summarize-plan
  or asks to summarize a plan after the plan exists. Do not auto-invoke.
---

# Summarize plan

Read-only. The plan must already exist. Before or after
`/implementation-plan-review` is fine. Do not review, edit, implement, or
start Nightshift.

## Find the plan

1. Use the plan the developer attached or named.
2. Else the newest file under `.cursor/plans/`.
3. Else `.cursor/night-shift/contract.md` if it is this item.

If none: ask for the plan file or a paste. Stop.

## Classify

Use the plan’s `kind`, title, or acceptance. Then print **one** template
(`bug`, `feature`, or `architecture`). A mixed plan may use two.

## Output (chat only)

Everyday words. Short bullets. No jargon, file trees, options, or extra
sections. Do not invent test names. Omit an empty test group. If the plan
names no tests on a bug, write **Tests: not listed**.
Identify trade offs if existing and name them.

### Bug

**Bugs to fix**
- one bullet per user-visible break the plan fixes

**Tests that lock the fix**
- add: …
- update: …
- fix: …
- remove: …

### Feature

**What it does**
- what the user can do after this ships

**Pain it solves**
- what was hard or missing today

### Architecture (or process)

**What changes**
- the one smell or process change

**Why it helps you**
- how work gets easier or safer
