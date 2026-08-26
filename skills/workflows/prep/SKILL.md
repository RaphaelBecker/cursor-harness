---
name: prep
disable-model-invocation: true
description: >-
  Short workpack preparation (about 2h max, anytime): decision packets with
  recommended answers, contracts in human-created Cursor worktrees, then ready
  to fire Nightshift. Do not create worktrees. Do not implement code.
---

# Prep

Short human sitting to assemble the workpack. Not tied to a time of day — run
it when you have a block (keep it to about **2h max**). Nightshift then executes
fully autonomously in those worktrees.

Humans create Cursor worktrees (one tree, one agent, one feature). This skill
never runs `git worktree add` and never tells an agent to create a worktree.

Thin orchestrator. Reuse `@grill-me` (packet mode), `@implementation-plan-review`,
`@project-memory`. Fire is `/night-shift` or
`./vendor/cursor-harness/runtime/night-shift fire`.

Flavor is a contract `kind`, not a second slash command. Agents that hear
“new feature”, “bug fix”, or “architecture change” point at **this skill only**.

## Preconditions

1. `harness.project.yaml` at the repo root. If missing, **park a note** and tell
   the human to copy `templates/harness.project.yaml` — do not invent product
   paths.
2. Discover existing git worktrees (`git worktree list`). If the human has not
   created a Cursor worktree per item, **list the gap and wait** — do not create
   trees.
3. Load domain memory (`@project-memory`) and `doc-routing` (read that rule; it
   is not always-on).

## Steps

1. **Items** — from `issue_source` in `harness.project.yaml`:
   - `files`: read `files.path`.
   - `none`: use the worktrees the human already opened and any issue ids they
     named.
2. **Match trees** — one human-created worktree per item. Skip unmatched items
   with a clear “create a Cursor worktree first” line.
3. **Classify `kind`** — `feature` (default), `bug`, or `architecture`. Write it
   on the contract. Then:
   | `kind` | Extra before the packet grill |
   | --- | --- |
   | `feature` | none — grill next |
   | `bug` | `@diagnose-bug` until one named red command exists. Tiny one-file skip only if **the human** asks |
   | `architecture` | `@architecture-audit` (report) → human picks **one** smell. Allowlist = one extract **or** one cycle fix |
4. **Packet grill** — `@grill-me` in **packet mode** (all material questions at
   once, each with a recommended answer). Not one-question-at-a-time unless the
   human asks for conversational grill.
5. **Draft contract** — write `.cursor/night-shift/contract.md` in that
   worktree (`status: draft`, `commits: authorized`, `kind:` set). Copy shape
   from `templates/night-shift-contract.example.md`. Include **Manual test**
   (how to run the app + which acceptance to click).
6. **Review** — wait for human `/implementation-plan-review` (or batch review of
   packets in this sitting). Then explicit approval.
7. **Approve** — set `status: approved` only after that yes. That yes does
   **not** authorize merge, push, or production.
8. **Stop** — remind: `./vendor/cursor-harness/runtime/night-shift fire`
   (or the launchd unit). Do not start Phases 2–5 in this chat unless the human
   asks to run one tree now.

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
