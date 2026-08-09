---
name: execute-approved-plan
description: >-
  Autonomously executes an explicitly approved implementation contract through
  lifecycle Phases 2-5 (code, docs, review, versioning). Local verification is
  always agent-executable via the testing-rule ladder. Auto-activate whenever
  the current conversation contains an approved implementation contract ready
  for unattended or night-shift execution. Never pushes, merges, deploys, or
  weakens a required gate. Git branch and worktree isolation are owned by
  Cursor — do not create or manage them (local merge/cleanup is `/ship-local`
  only).
---

# Execute an approved implementation contract

Turn an approved, zero-open-question implementation contract into reviewed work
in the current Cursor workspace. Work unattended only inside the contract for
code/docs. Follow `core-principles.mdc` for hard stops and day/night authority;
this skill owns the night-shift checklist only.

## Activation gate

Auto-activate when the conversation contains both an executable implementation contract
and explicit developer approval to implement it. Do not edit `~/.cursor/plans`.

Before editing, restate the contract as a checklist. Stop on material open decisions.

## Non-negotiable boundaries

- Work only in the current Cursor-provided workspace. Do **not** create, switch,
  rename, delete, or otherwise manage git branches or git worktrees — Cursor owns
  isolation (parallel agents / New Worktree). Local merge + current-worktree cleanup
  is **`/ship-local` only**, when the human invokes it after this handoff.
- **Local verification is always agent-allowed:** discover and run the project's
  typecheck/lint/test commands yourself. Do **not** ask the human for permission.
- **Verification ladder:** mandatory; run without asking. Normative order, repair
  budgets, and gate composition live only in the `testing` rule — do not restate them here.
- **`project_memory.md`:** do not edit **Architecture** during Phases 2–5. Phase 5
  **must** run `@project-memory` Candidates + cycle status write after lessons. Soft
  Architecture consolidate remains Phase 7 only (after watched-green remote ship).
- Never push, merge, open a PR, deploy, or sync production secrets unless the developer
  explicitly asks after handoff (`/ship-local` for local merge only; `/ship-prod` for
  watched remote ship).
- Never skip/weaken tests or use `--no-verify`.
- Stage only contract-scoped files.

## Budgets

- Scope allowlist is absolute.
- At most **one** Phase 4b review-fix cycle; **one** transient infra retry.
- Per-gate repair caps follow the `testing` rule (do not invent a second ladder budget).

## Execution workflow

### 0. Workspace preflight

1. Confirm the working tree is usable for the contract (no staged/unstaged/untracked
   contract-irrelevant files). If dirty with unrelated work → **STOP** and ask the human.
   Never stash/absorb pre-existing work.
2. Do not fetch/rebase/merge for the sake of starting work, and do not create branches
   or worktrees.
3. Record allowlist and repo-root as the verification cwd.

### Phases 2–4

1. **Phase 2:** Bug → write failing regression first. Feature → `@generate-bdd-test-spec`
   then author tests. Run RED commands on the dedicated/targeted suite.
2. **Phase 3:** Smallest contract-complete change; follow project migration/regen rules when
   the contract requires them.
3. **Phase 4 — Verify:** Run the verification ladder without asking (order and budgets in
   the `testing` rule). Harness/docs-only contracts may document N/A per their test field.
4. **Phase 4b — `@review-code`:** After green ladder (or N/A), fix-capable maintainability
   review (behavior-preserving fixes; contract-scoped behavior fixes with red-first only).
5. **Phase 4c — Cursor second opinion (report only):**
   1. Run `/review-bugbot` (or the Bugbot subagent per Cursor's `review-bugbot` skill)
      on branch changes.
   2. If the contract allowlist touches auth, access control, billing/payments, admin,
      secrets, or other sensitive surfaces the project marks as such, also run
      `/review-security`.
   3. Summarize findings in the handoff (severity table). **Do not auto-fix** Bugbot
      or Security findings. Ask the human before any such edit, or fold into a follow-up
      contract.
   4. Re-run the ladder only if the human approves fixes that change runtime behavior.

### Phase 5 — Document, version, lessons, handoff

1. Sync docs (`@sync-spec-docs`); SemVer for touched versioned packages.
2. Local commits only when the human asks or the contract explicitly authorizes them.
3. Write handoff `## Lessons learned` (3–7 short actionable bullets).
4. Run **`@project-memory` Phase 5** — upsert Candidates, bump cited helps, stage check,
   refresh **Cycle status**. Echo cycle status in the handoff. Do not edit Architecture here.
5. Handoff **must** also include:
   - Verification commands executed and results for the ladder (per `testing` rule) or
     contract N/A
   - Phase 4b summary (fixes applied) and Phase 4c Bugbot/Security findings (report only)
   - **Merge-ready only if** required full gates are green with evidence (or harness/docs-only
     N/A); otherwise state not merge-ready and list what remains
   - Optionally note the current Cursor-provided branch name for the human (do not
     create or change it)
6. Do not push, merge, or remove worktrees. Remind human: `/ship-local` then
   `/ship-prod` (or the project's documented push/deploy scripts if they drive remote
   themselves).

## Ship path (after handoff)

```text
Phase 5 handoff (+ Candidates/cycle status)
  → (human) /ship-local  # reliable local merge onto clean default branch (+ worktree cleanup)
  → (human) /ship-prod   # watched remote ship → CI fix → Phase 7
  # alternate: human runs project deploy/push scripts themselves
```

## Evidence report

Contract goal, files changed, verification ladder commands and results (including
skipped/not-run and failing-only reruns), browser N/A or evidence, Phase 4b/4c review notes,
commit IDs, risks/hard stops, merge-ready yes/no, `## Lessons learned` (required), cycle
status echo.
**No remote push, merge, or deployment was performed.**
