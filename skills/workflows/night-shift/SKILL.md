---
name: night-shift
disable-model-invocation: true
description: >-
  Fire and status for unattended Nightshift execute in existing human-created
  Cursor worktrees. Use when the developer wants to launch, check, or read the
  status board. Never creates worktrees.
---

# Night shift

One local Cursor agent per **existing** worktree that has
`.cursor/night-shift/contract.md` with `status: approved`.

This skill does not implement the feature. The CLI does the fire. Agents inside
each tree follow `@execute-approved-plan`.

## Never

- `git worktree add` / switch / delete (humans + Cursor UI own isolation)
- `agent … &` (Cursor cloud handoff)
- Waiting for the human — park `BLOCKED.md` instead

## Commands (from the consumer repo root)

```bash
./vendor/cursor-harness/runtime/night-shift discover
./vendor/cursor-harness/runtime/night-shift fire
./vendor/cursor-harness/runtime/night-shift status
./vendor/cursor-harness/runtime/night-shift slots-status
./vendor/cursor-harness/runtime/night-shift check
```

`fire` sets `CURSOR_HARNESS_UNATTENDED=1` and runs `agent -p "@execute-approved-plan"`
in each approved worktree (model from `harness.project.yaml` executor). Concurrency
equals the number of ready trees. Custom `slots.lease` is a test-pool script:
acquire at **worktree proof** only when a listed suite needs the stack — not at
fire. Pure unit/UI must not take a slot. Do not skip tests. About **3** parallel
agents has been comfortable on a laptop; that is experience, not a harness cap.
`slots-status` exit 0 means another worktree holds a pool slot (`/ship-prod` STOP).

Optional schedule: copy
`templates/launchd/com.cursor-harness.night-shift.plist.example`.

## After Nightshift

1. `night-shift status` — board plus the last few `.cursor/night-shift/decisions.tsv`
   rows per tree (forks, gates, BLOCKED). Do not read the full transcript first.
2. Manual-test every `ready-for-manual-test` tree (recipe is in the contract /
   handoff)
3. Human `/ship-local` per finished tree, then `/ship-prod` when the batch
   should leave the machine

## Map

See [`.cursor/HARNESS.md`](../../../HARNESS.md).
