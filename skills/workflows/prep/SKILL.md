---
name: prep
disable-model-invocation: true
description: >-
  Short workpack preparation (about 2h max, anytime): decision packets with
  recommended answers, one Cursor plan in human-created worktrees, then ready
  to fire Nightshift or Cursor Build. Do not create worktrees. Do not implement code.
---

# Prep

Short human sitting to assemble the workpack. Not tied to a time of day — run
it when you have a block (keep it to about **2h max**). Nightshift then executes
fully autonomously in those worktrees. Cursor **Build** in this same chat also
runs `@execute-approved-plan` once the plan is approved. `/night-shift` fire
is only the unattended multi-tree launcher — skipping it is fine.

Humans create Cursor worktrees (one tree, one agent, one feature). This skill
never runs `git worktree add` and never tells an agent to create a worktree.
Prep on the default branch is valid when the human already opened the chat there.

Thin orchestrator. Reuse `@grill-me` (packet mode), `@implementation-plan-review`,
`@project-memory`. Fire is Cursor Build, `/night-shift`, or
`./vendor/cursor-harness/runtime/night-shift fire`.

Flavor is a plan `kind`, not a second slash command. Agents that hear
“new feature”, “bug fix”, or “architecture change” point at **this skill only**.

## One plan (SSOT)

The only implementation plan is this worktree’s `.cursor/plans/<slug>.md`.
Create it with Write; edit it with StrReplace.
**Never call CreatePlan.** That tool writes a different file under
`~/.cursor/plans/<name>_<hash>.plan.md` and is not the SSOT.
Never copy, sync, or edit `~/.cursor/plans`.
If a hashed plan URI is already attached to the chat, ignore it for content.
Never write `.cursor/night-shift/contract.md` or `contract-*.md`.
Sidecars start with `SSOT: .cursor/plans/<slug>.md`.

Write the live plan under `.cursor/plans/<slug>.md` in this worktree
(`status: draft`, `commits: authorized`, `kind:` set, `issue:` this item).
If a leftover plan is `status: approved` for a **different** `issue`, do not
execute it — archive it or leave it and Write a new slug file for this item.

## Preconditions

1. `harness.project.yaml` at the repo root. If missing, **park a note** and tell
   the human to copy `templates/harness.project.yaml` — do not invent product
   paths.
2. Discover existing git worktrees (`git worktree list`). If the human has not
   created a Cursor worktree per item **and** this checkout is not already the
   intended workspace, **list the gap and wait** — do not create trees. If they
   opened the chat on default, continue here.
3. Load domain memory (`@project-memory`) and `doc-routing` (read that rule; it
   is not always-on).

## Steps

1. **Items** — from `issue_source` in `harness.project.yaml`:
   - If `.cursor/night-shift/bug-ticket.md` exists in this worktree, that file
     **is** the item text (it replaces the typed bug explanation). Classify
     `kind: bug`. The ticket's **Test coverage gap** may seed the plan
     **Tests** field; it does not replace diagnose, grill, or review.
   - If the file is missing, `/prep` behaves exactly as today.
   - `files`: read `files.path`.
   - `none`: use the worktrees the human already opened and any issue ids they
     named.
2. **Match trees** — one human-created worktree per item. Skip unmatched items
   with a clear “create a Cursor worktree first” line, unless this chat is
   already on the intended checkout (including default).
3. **Classify `kind`** — `feature` (default), `bug`, or `architecture`. Write it
   on the plan. Then:
   | `kind` | Extra before the packet grill |
   | --- | --- |
   | `feature` | none — grill next |
   | `bug` | `@diagnose-bug` until one named red command exists. Tiny one-file skip only if **the human** asks |
   | `architecture` | `@architecture-audit` (report) → human picks **one** smell. Allowlist = one extract **or** one cycle fix |
4. **Packet grill** — `@grill-me` in **packet mode** (all material questions at
   once, each with a recommended answer). Not one-question-at-a-time unless the
   human asks for conversational grill.
5. **Draft plan** — edit this item’s `.cursor/plans/<slug>.md` (`status: draft`,
   `commits: authorized`, `kind:` set, `issue:` this item). Include **Manual test**
   (how to run the app + which acceptance to click). Delete leftover
   `contract.md` / `contract-*.md` if present. Do not write a second plan file.
6. **Review** — wait for human `/implementation-plan-review` (or batch review of
   packets in this sitting). That skill pauses once for Option A/B/C, then sets
   the **same plan file** to `status: approved`, says `Implementation plan is ready.`,
   and stops. Do not ask a second yes. That write does **not** authorize merge,
   push, or production.
7. **Stop** — do not start Phases 2–5. Do not say “hit Build”.

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
