---
status: draft
commits: authorized
kind: feature
issue: ""
---

# Implementation contract

Fill during `/prep`. `kind` is `feature` (default), `bug`, or `architecture`.
Set `status: approved` only after the human explicitly accepts this contract.
Night fire skips worktrees that are not `approved`.

Working `contract.md` / `HANDOFF.md` / `BLOCKED.md` are per-tree artifacts —
gitignore them in the consumer repo so a new worktree never inherits another
item's approved pack. Always overwrite `contract.md`. Never write sidecars.

## Objective

## Allowlist

## Non-goals

## Acceptance

## Tests

List the **worktree-proof** suites (typecheck + unit / int / UI / one E2E flow /
domain gate). Empty is not merge-ready. Docs/harness-only: `N/A` or docs-only.
Do not list the fast/local coverage slice or idle-main complete here.

- `feature`: BDD if the `bdd` pack is installed, else acceptance tests.
- `bug`: the named red command from `@diagnose-bug`, then the failing regression.
- `architecture`: prove the one extract **or** the one cycle fix on the allowlist.

## Docs / SemVer

## Permissions

- Local commits: authorized
- Merge / push / deploy: human only (`/ship-local`, `/ship-prod`)

## Manual test

How to run the app in this worktree, and which acceptance to click in the morning.

## Handoff evidence
