---
status: draft
commits: authorized
kind: feature
issue: ""
---

# Implementation plan

One file per item under `.cursor/plans/<slug>.md`. This is the SSOT.
Never write `.cursor/night-shift/contract.md`. Never call CreatePlan twice.

`kind` is `feature` (default), `bug`, or `architecture`.
Set `status: approved` only after `/implementation-plan-review`.
Night fire runs only when **exactly one** plan in that worktree is `approved`.
On ship, set `status: archived` (keep the file).

## Objective

## Allowlist

## Non-goals

## Acceptance

## Tests

List the **worktree-proof** suites (typecheck + unit / int / UI / one E2E flow /
domain gate). Empty is not merge-ready. Docs/harness-only: `N/A` or docs-only.

## Docs / SemVer

## Permissions

- Local commits: authorized
- Merge / push / deploy: human only (`/ship-local`, `/ship-prod`)

## Manual test

How to run the app in this worktree, and which acceptance to click in the morning.

## Handoff evidence
