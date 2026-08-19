---
name: execute-approved-plan
description: >-
  Autonomously executes an explicitly approved implementation contract through
  lifecycle Phases 2-5 (code, docs, review, versioning). Local verification is
  always agent-executable via the testing-rule ladder. Auto-activate in a
  worktree that has an approved night-shift contract, including unattended
  `night-shift fire` (CURSOR_HARNESS_UNATTENDED=1). Never pushes, merges,
  deploys, or weakens a required gate. Do not create or manage git worktrees.
---

# Execute an approved implementation contract

Turn an approved, zero-open-question implementation contract into reviewed work
in the **current** Cursor workspace (human-created worktree). Work unattended
only inside the contract. Follow `core-principles.mdc` for hard stops; this
skill owns the night-shift checklist only.

Unattended runs (`CURSOR_HARNESS_UNATTENDED=1` or `/night-shift` fire): **never
wait**. Park `.cursor/night-shift/BLOCKED.md` and exit. Leave other worktrees
alone.

## Activation gate

Activate when the current worktree has `.cursor/night-shift/contract.md` with
`status: approved`, or the conversation contains that contract plus explicit
approval. Do not edit `~/.cursor/plans`.

Before editing, restate the contract as a checklist. On material open decisions:
if unattended → BLOCKED.md; else stop.

## Non-negotiable boundaries

- Work only in the current Cursor-provided workspace. Do **not** create, switch,
  rename, delete, or otherwise manage git branches or git worktrees — humans and
  Cursor own isolation. Local merge + current-worktree cleanup is
  **`/ship-local` only**.
- **Local verification is always agent-allowed:** discover and run the project's
  typecheck/lint/test commands yourself. Do **not** ask the human for permission.
  If `harness.project.yaml` declares `slots`, wait for a slot rather than skipping
  tests. There is no harness-wide max agent count.
- **Verification ladder:** mandatory; run without asking. Normative order lives
  only in the `testing` rule — read it (not always-on).
- **`project_memory.md`:** do not edit **Architecture** during Phases 2–5. Phase 5
  **must** run `@project-memory` Candidates + cycle status write after lessons.
- Never push, merge, open a PR, deploy, or sync production secrets.
- Never skip/weaken tests or use `--no-verify`.
- Stage only contract-scoped files.
- **Commits:** if the contract has `commits: authorized` (prep default),
  make local commits as you go. Do not ask. If the field is missing in an
  unattended run, treat as authorized for this worktree.

## Budgets

- Scope allowlist is absolute.
- At most **one** Phase 4b review-fix cycle; **one** transient infra retry.
- Per-gate repair caps follow the `testing` rule.

## Execution workflow

### 0. Workspace preflight

1. Confirm the working tree is usable for the contract (no staged/unstaged/untracked
   contract-irrelevant files). If dirty with unrelated work → **park BLOCKED.md**
   (unattended) or stop (attended). Never stash/absorb pre-existing work.
2. Do not fetch/rebase/merge for the sake of starting work, and do not create
   branches or worktrees.
3. Record allowlist and repo-root as the verification cwd.
4. Clear a previous `.cursor/night-shift/BLOCKED.md` only if you can proceed.
5. **Decision log** — append-only `.cursor/night-shift/decisions.tsv`. Copy the
   header from `templates/night-shift-decisions.example.tsv` on first use. Log
   forks, pivots, gate results, BLOCKED, and one-way doors — not every tool
   call. One row is one decision. Never edit or delete old rows. Evidence is a
   pointer (SHA, `file:line`, command), not a paragraph. Prefer:

   `./vendor/cursor-harness/runtime/log-decision <phase> <decision> <why> <evidence> <result>`

   Do not commit the TSV unless the human asks. It is a working artifact.

### Phases 2–4

1. **Phase 2:** Bug → write failing regression first at the contract's named
   red command / seam. If the contract is a non-trivial bug and that command
   is missing → park `BLOCKED.md` (do not hypothesise). Feature → if
   `@generate-bdd-test-spec` is installed (`bdd` pack), use it; otherwise write
   acceptance tests from the contract. Run RED commands on the dedicated/targeted
   suite.
2. **Phase 3:** Smallest contract-complete change; follow project migration/regen
   rules when the contract requires them.
3. **Phase 4 — Verify:** Run the verification ladder without asking.
4. **Phase 4b — `@review-code`:** After green ladder (or N/A), fix-capable
   maintainability review. Sensitive allowlists also run `@blast-radius`
   (shared modules, lifecycle, money, auth, wire formats). Skip copy/docs.
5. **Phase 4c — Cursor second opinion (report only):**
   1. Run `/review-bugbot` (or the Bugbot subagent) on branch changes.
   2. If the allowlist touches auth, access control, billing/payments, admin,
      secrets, or other sensitive surfaces, also run `/review-security`.
   3. Summarize findings in the handoff. **Do not auto-fix** Bugbot or Security
      findings. Do **not** wait for the human — leave 4c for after Nightshift.
   4. Re-run the ladder only if a human later approves behavior-changing fixes.

### Phase 5 — Document, version, lessons, handoff

1. Sync docs (`@sync-spec-docs`); SemVer only if the project versions packages
   you touched.
2. Local commits when `commits: authorized`.
3. Write handoff `## Lessons learned` (3–7 short actionable bullets).
4. Run **`@project-memory` Phase 5**.
5. Handoff **must** also include:
   - **Manual test** — commands to run the app in this worktree and which
     acceptance to click (from the contract; update if you learned more)
   - Verification commands and results
   - Phase 4b summary and Phase 4c Bugbot/Security findings (report only)
   - **`## Blast radius`** when the allowlist was sensitive (from `@blast-radius`);
     omit for copy/docs
   - **ready-for-manual-test** if required gates are green; otherwise not
     merge-ready and list what remains
6. Write `.cursor/night-shift/HANDOFF.md` with the same content (include the
   phrase `ready-for-manual-test` when true).
7. Do not push, merge, or remove worktrees. Remind: morning `night-shift status`,
   then `/ship-local` then `/ship-prod`.

## Park (unattended hard stop)

Write `.cursor/night-shift/BLOCKED.md` with: reason, last command, what the
human should decide. Append a `decisions.tsv` row (`phase=park`). Exit the
run. Do not ping. Do not ask.

## Evidence report

Contract goal, files changed, verification ladder, browser N/A or evidence,
Phase 4b/4c notes, blast-radius when required, commit IDs, **Manual test**,
merge-ready / ready-for-manual-test, `## Lessons learned`, cycle status echo,
pointer to `decisions.tsv`.
**No remote push, merge, or deployment was performed.**
