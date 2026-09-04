---
name: execute-approved-plan
description: >-
  Autonomously run an approved Cursor plan through Phases 2-5.
  Auto-activate in a worktree holding exactly one approved `.cursor/plans/`
  file, including unattended `night-shift fire` and Cursor Build after approval.
  Never push, merge, or deploy.
---

# Execute an approved plan

Turn an approved, zero-open-question Cursor plan into reviewed work
in the **current** Cursor workspace (human-created worktree). Work unattended
only inside that plan. Follow `core-principles.mdc` for hard stops; this
skill owns the night-shift checklist only.

Unattended runs (`CURSOR_HARNESS_UNATTENDED=1` or `/night-shift` fire): **never
wait**. Park `.cursor/night-shift/BLOCKED.md` and exit. Leave other worktrees
alone.

Attended Cursor **Build** in the same chat as `/prep` uses this same skill.
Skipping `/night-shift` is fine.

## One plan (SSOT)

If this chat already has a plan file URI, that file is the SSOT.
**Do not call CreatePlan.** Edit the existing file.
`/prep` may CreatePlan **once**, and only if no plan exists for this item.
Never write `.cursor/night-shift/contract.md` or `contract-*.md`.
Sidecars start with `SSOT: .cursor/plans/<slug>.md`.

## Activation gate

Activate when the current worktree has **exactly one** `.cursor/plans/*.md` with
`status: approved`, **and** that file is this chat’s item (`issue` / objective
matches), or the conversation contains that plan plus explicit approval.
Edit that repo plan. Do not edit unrelated plans under the user-home
`~/.cursor/plans` directory.

**This-item only.** If the only approved plan is for a **different** issue
(leftover from another tree or an earlier land) → treat it as foreign. Do not
execute it. If more than one plan is `approved`, park `BLOCKED.md` (do not guess).
Delete leftover `contract.md` / `contract-*.md` if present.

Before editing, restate the plan as a checklist. On material open decisions:
if unattended → BLOCKED.md; else stop.

## Non-negotiable boundaries

- Work only in the current Cursor-provided workspace. Do **not** create, switch,
  rename, delete, or otherwise manage git branches or git worktrees — humans and
  Cursor own isolation. Local merge + current-worktree cleanup is
  **`/ship-local` only**.
- **Local verification is always agent-allowed:** discover and run the project's
  typecheck/lint/test commands yourself. Do **not** ask the human for permission.
  Lease a shared test-pool slot only if a listed suite needs it (int / E2E /
  domain stack). Pure unit/UI must not take a slot. Do not skip tests. There is
  no harness-wide max agent count.
- **Verification ladder:** mandatory; run without asking. Normative order lives
  only in the `testing` rule (worktree proof on this tree; idle-main complete
  after `/ship-local`) — read it (not always-on).
- **`project_memory.md`:** do not edit **Architecture** during Phases 2–5. Phase 5
  **must** run `@project-memory` Candidates + cycle status write after lessons.
  That write is **ship-scoped** — commit it with the feature when
  `commits: authorized`. Do not leave it dirty for a later slash.
- Never push, merge, open a PR, deploy, or sync production secrets.
- Never skip/weaken tests or use `--no-verify`.
- Stage plan-scoped files **plus** Phase 5 `project_memory.md`. Do **not**
  stage night-shift working files (`contract.md`, `HANDOFF.md`, `BLOCKED.md`,
  `bug-ticket.md`, sidecars, `decisions.tsv`).
- **Commits:** if the plan has `commits: authorized` (prep default),
  make local commits as you go. Do not ask. If the field is missing in an
  unattended run, treat as authorized for this worktree.

## Do not drop out

A turn that only announces the next ladder or review step is a failure.
Invoke that command or skill in the same message. Wait for proof commands
to finish in this sitting — do not background them and stop.

## Budgets

- Scope allowlist is absolute.
- At most **one** Phase 4b review-fix cycle; **one** transient infra retry.
- Per-gate repair caps follow the `testing` rule.

## Execution workflow

### 0. Workspace preflight

1. Confirm the working tree is usable for this plan. If `ship.leftovers` is
   set, run it **without** `--apply` (do not archive this item's live plan).
   STOP-class dirt (secrets, other worktree, live merge) → **park BLOCKED.md**
   (unattended) or stop (attended). Never stash. Inherited night-shift sidecars:
   delete them. Leftover `contract.md`: delete it. Foreign approved plan: do
   not execute it.
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

1. **Phase 2:** Honor plan `kind` (`feature` if missing):
   - `feature` — if `@generate-bdd-test-spec` is installed (`bdd` pack), use it;
     otherwise write acceptance tests from the plan. Run RED on the
     dedicated/targeted suite.
   - `bug` — write the failing regression first at the plan's named red
     command / seam. If that command is missing → park `BLOCKED.md` (do not
     hypothesise).
   - `architecture` — run **one** of `@extract-deep-module` or
     `@dependency-direction-fix` as the allowlist names. Do not do both. Then
     prove. If the allowlist is neither → park `BLOCKED.md`.
2. **Phase 3:** Smallest plan-complete change; follow project migration/regen
   rules when the plan requires them. Architecture `kind` already did the
   one refactor in Phase 2 — do not add extra extracts.
3. **Phase 4 — Verify:** Run the verification ladder without asking.
4. **Phase 4b — `@review-code`:** After green ladder (or N/A), fix-capable
   maintainability review. Sensitive allowlists also run `@blast-radius`
   (shared modules, lifecycle, money, auth, wire formats). Skip copy/docs.
5. **Phase 4c — Cursor second opinion (report only):**
   1. Run `/review-bugbot` (or the Bugbot subagent) on branch changes.
   2. If the allowlist touches auth, access control, billing/payments, admin,
      secrets, or other sensitive surfaces, also run `/review-security`.
   3. Put findings in `HANDOFF.md`. **Run 4c in this sitting** — do not skip
      or defer the Bugbot/Security run. **Do not auto-fix** those findings
      in Nightshift (report-only). Do **not** wait for the human to apply
      them before finishing the handoff.
   4. Re-run the ladder only if a human later approves behavior-changing fixes.

### Phase 5 — Document, version, lessons, handoff

1. Sync docs (`@sync-spec-docs`); SemVer only if the project versions packages
   you touched.
2. Write `HANDOFF.md` (working artifact; do not commit). First line:
   `SSOT: .cursor/plans/<slug>.md`. Then the long evidence:
   Manual test, verification commands/results, Phase 4b/4c, blast radius when
   required, `## Lessons learned` (3–7 short actionable bullets), cycle status,
   commit SHAs, `ready-for-manual-test` when the worktree proof is green (or
   docs/harness N/A).
3. Run **`@project-memory` Phase 5**. Commit `project_memory.md` with the
   feature when `commits: authorized`.
4. Local commits when `commits: authorized` (allowlist + memory; not night-shift
   working files).
5. **Chat handoff** — 8–12 short lines: product result, proof command +
   green/red, version if bumped, one-line next step (`/ship-local` on a feature
   tree, `/ship-prod` if already on default). Do not dump 4b/4c, lessons, or
   cycle status into chat.
6. **Required last line:**
   - `DONE` — plan fully implemented
   - `PARTIAL: <exact leftover>` — only what was not done
7. Do not push, merge, or remove worktrees.

## Park (unattended hard stop)

Write `.cursor/night-shift/BLOCKED.md` with first line
`SSOT: .cursor/plans/<slug>.md`, then: reason, last command, what the
human should decide. Append a `decisions.tsv` row (`phase=park`). Exit the
run. Do not ping. Do not ask.

## Evidence report

Chat stays compact (see Phase 5). Long evidence lives in `HANDOFF.md`.
**No remote push, merge, or deployment was performed.**
**Required last line:** `DONE` or `PARTIAL: <exact leftover>`.
