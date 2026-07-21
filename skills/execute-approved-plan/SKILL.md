---
name: execute-approved-plan
description: >-
  Autonomously executes an explicitly approved implementation contract from a
  default-branch-based feature branch through lifecycle Phases 2-5,
  verification, review, documentation, versioning, and local commits.
  Auto-activate whenever the current conversation contains an approved
  implementation contract ready for unattended or night-shift execution. Never
  pushes, merges, deploys, or weakens a required gate.
---

# Execute an approved implementation contract

Turn an approved, zero-open-question implementation contract into a reviewed,
locally committed feature branch. Work unattended only inside the contract.

## Activation gate

Auto-activate when the current conversation contains both:

1. An implementation contract that identifies the goal, allowed files/systems,
   acceptance criteria, required tests, documentation/version impact, and
   constraints.
2. Explicit developer approval to implement it.

The approval and contract may be in the current request or prior conversation.
Do not infer approval from a draft plan, exploratory discussion, or permission
to investigate. Do not edit `~/.cursor/plans`; treat any referenced plan as
read-only input.

Before changing files, restate the executable contract as a checklist. If any
decision would materially alter behavior, schema, public API, destructive data
handling, or scope, stop before editing and return one focused blocker decision.
Do not wait interactively during an unattended run.

## Non-negotiable boundaries

- Start from the project's default branch (`main` or `master`) on a dedicated
  local feature branch. Never implement directly on the default branch.
- Never push, merge, open a pull request, deploy, or sync production secrets
  unless the developer explicitly asks after handoff.
- Never target a production database or run a destructive reset without an
  explicit human request. Prefer the project's isolated test/dev database
  workflow when one exists.
- Never skip, mute, quarantine, weaken, or rewrite a test merely to make a gate
  pass. Do not use `--no-verify`, reduced coverage thresholds, focused tests,
  snapshots without review, or CI/config exclusions as repairs.
- Never hide pre-existing failures. Record them and hard stop if they prevent a
  required gate from proving the contract.
- Stage and commit only contract-scoped files. Leave unrelated developer
  changes untouched.

## Budgets

### Scope budget

- The contract's file/system allowlist is absolute.
- Read directly related callers, tests, rules, and canonical docs as needed,
  but write only approved paths and mandatory same-scope tests, docs, generated
  artifacts, or version files named by the contract.
- Any required write outside that budget is a scope expansion: stop and record
  the exact contract amendment required before making it.
- No opportunistic cleanup, dependency upgrades, broad formatting, or backlog
  work.

### Repair and retry budget

- At most **two code-repair attempts per failing gate** and **six code-repair
  attempts total** across the run.
- At most **one retry** for a command that failed for a clearly transient
  infrastructure reason; an infrastructure retry does not consume a
  code-repair attempt.
- At most **one Phase 4b review-fix cycle**. A new behavior requirement returns
  to Phase 1 and requires developer approval.
- After a budget is exhausted, stop with the command, failure evidence,
  attempted repairs, changed files, and recommended next decision.

One repair attempt is one coherent hypothesis and patch followed by the
smallest gate that can disprove it. Do not repeatedly rerun an unchanged
failure.

## Execution workflow

Track each phase explicitly and preserve command output as evidence.

### 0. Branch and workspace preflight

1. Confirm the repository root and inspect `git status`, current branch,
   remotes, and the merge base with the default branch.
2. Fetch `origin/<default-branch>` without changing remote state.
3. Never stash, discard, or absorb pre-existing work. If the current worktree
   has any tracked or untracked changes, create a separate Git worktree from
   `origin/<default-branch>` and leave the original worktree untouched.
4. If the contract names a branch, require that branch. Otherwise create a
   descriptive local feature branch from `origin/<default-branch>` in the clean
   current or separate worktree.
5. If the contract-named branch is already checked out in a dirty worktree,
   preserve it and stop with a request for a replacement branch name.
6. Require the branch to descend from current `origin/<default-branch>`. If it
   diverged, hard stop rather than rebasing or merging without approval.
7. Record the base commit and approved path allowlist.

### Phase 2 — Test design

1. Load only the canonical docs and file-scoped rules routed by the contract.
2. For a bug, add a failing regression test that reproduces the defect before
   implementation.
3. For a feature, produce acceptance/BDD scenarios, then implement tests at the
   correct layers for this project.
4. Run the narrow new test and capture the expected pre-implementation failure.
   If it passes unexpectedly, improve the test or stop; do not claim a
   regression guard without red evidence.
5. Do not locally commit a deliberately failing tree when hooks or repository
   policy require green commits.

### Phase 3 — Implement

1. Refactor before adding and extend existing architecture where practical.
2. Implement the smallest contract-complete change.
3. Check the changed-path list after each coherent patch. Revert only your own
   accidental out-of-scope edit; never overwrite developer work.
4. For schema changes, use the repository's versioned migration workflow. Never
   apply DDL manually to a hosted production database.

### Phase 4 — Verify

Discover and run the verification commands named in the contract (from README,
package scripts, Makefile, or CI). Typical order:

1. **Environment prerequisites** the project documents for local tests (test DB
   bootstrap, env files, etc.) — only when the contract or tests require them.
2. **Targeted tests** for the change.
3. **Fast/local gate** if the project defines one.
4. **Full/CI-parity gate** if the project defines one — required before
   finalizing an approved-plan run when available.
5. **Browser / manual acceptance** when user-visible behavior changed and the
   project supports it; supplements tests, never replaces them.
6. **Phase 4b review:** run `@review-code` against the diff. Apply
   behavior-preserving fixes and red-first fixes for introduced regressions or
   behavior expressly covered by the contract. Re-run affected gates after
   runtime-affecting fixes.

Do not convert a failing assertion into the new expected result unless the
approved contract explicitly changes that behavior.

### Phase 5 — Document, version, and commit

1. Synchronize canonical docs via `@sync-spec-docs`.
2. Apply SemVer only to touched packages/version files.
3. Recheck the allowlist, diff, generated artifacts, and secret scan. Confirm
   no credentials or environment files are staged.
4. If Phase 5 changed executable/generated behavior, rerun affected gates.
   Documentation-only and version-only edits do not invalidate already-green
   runtime gates; the commit hook still runs normally.
5. Create one or more cohesive **local** commits using repository message
   conventions. Before each commit, inspect the staged diff and ensure it
   contains only approved files. Never bypass hooks.
6. Finish on the feature branch with a clean worktree. Do not push.

## Hard stops

Stop immediately and preserve the worktree when any of these occurs:

- Missing approval, ambiguous acceptance criteria, or a material open decision.
- Pre-existing changes that were not isolated, wrong branch, branch divergence,
  or uncertain base.
- Required out-of-scope write, destructive operation, secret exposure, or
  production access.
- Migration drift that requires repair, data deletion, or policy changes not
  explicitly approved.
- A required test cannot run, was skipped, is flaky without a proven cause, or
  remains red after the repair budget.
- A required gate or review has an unresolved blocker.
- A commit hook fails after the repair budget. Never bypass it.
- Any instruction to push, merge, or deploy that is not a new explicit human
  command after handoff.

## Evidence report

Return a concise handoff containing:

- Contract goal and base/feature branch with base and final commit IDs.
- Files changed, grouped by implementation, tests, migrations/docs/version.
- Verification commands and results (including skipped-test counts).
- Browser/manual acceptance evidence or why it was not applicable.
- Review findings and repairs.
- Local commit IDs and messages.
- Remaining risks, hard stops, or manual verification.
- Explicit statement: **No remote push, merge, or deployment was performed.**

Never report completion if a required gate was skipped, weakened, unavailable,
or unresolved. Report a stopped run with the same evidence instead.
