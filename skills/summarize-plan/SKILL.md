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

## One plan (SSOT)

The only implementation plan is this worktree’s `.cursor/plans/<slug>.md`.
Create it with Write; edit it with StrReplace.
**Never call CreatePlan.** That tool writes a different file under
`~/.cursor/plans/<name>_<hash>.plan.md` and is not the SSOT.
Never copy, sync, or edit `~/.cursor/plans`.
If a hashed plan URI is already attached to the chat, ignore it for content.
Never write `.cursor/night-shift/contract.md` or `contract-*.md`.
Sidecars start with `SSOT: .cursor/plans/<slug>.md`.

This skill is read-only — do not edit the plan.

## Find the plan

1. Use the plan the developer attached or named.
2. Else this item’s live plan under `.cursor/plans/` (`status: draft` or
   `approved`, matching `issue`).
3. If none: ask for the plan file or a paste. Stop.

Never pick “the newest file” when more than one plan exists. Ignore
`status: archived`.

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
