---
name: create-workflow
disable-model-invocation: true
description: >-
  Guided authoring of a new Prep/Nightshift/Autonomous workflow. Use when the
  developer asks to create a workflow, add a process skill sequence, or wire
  skills and subagents into a repeatable path. Updates .cursor/HARNESS.md.
---

# Create workflow

Interactive. Do not invent parallel catalogs — [`.cursor/HARNESS.md`](../../HARNESS.md)
is the map.

## Steps (confirm with the developer)

1. **Intent** — feature, bug, audit, ops, quality, ship, or custom.
2. **Shift class** — Prep / Nightshift / After / Autonomous / Hybrid / ship hybrid.
3. **Safety** — report-only vs allowlist draft PR; apply hard denies (migrations, auth,
   billing/payments, secrets, broad product refactors).
4. **Sequence** — ordered steps. For each step, recommend skills and subagents from HARNESS
   (pre-select defaults; let the human adjust). Prefer portable spine skills; consumer
   domain agents stay in the project.
5. **Gates** — human approval points; TDD/RED; which ladder stage; ship-local / ship-prod.
6. **Outputs** — handoff shape; Lessons learned + Candidates for night implement; Automation
   stub if autonomous.
7. **Write**
   - New skill under `.cursor/skills/workflows/<name>/SKILL.md` (or a focused skill if not a
     thin orchestrator).
   - **Always update** `.cursor/HARNESS.md` in the same change.
   - If autonomous: add a stub under `.cursor/automations/README.md` for a **local**
     CLI/SDK job (`launchd` / cron). `/automate` is overflow when the laptop is off.

## Recommendation defaults

| Signal | Recommend |
| --- | --- |
| Night implement | `execute-approved-plan` + ladder in `testing` + Phase 5 lessons/Candidates |
| Non-trivial prep idea | packet `grill-me`; human triggers `implementation-plan-review` |
| Non-trivial bug | `@diagnose-bug` until one red command exists; then packet grill |
| Sensitive diff | `@blast-radius` after green ladder / before `/ship-local` |
| One module smell | `/architecture-improve` — audit, pick one, then the spine |
| Feature path | `generate-bdd-test-spec` if `bdd` pack installed; else acceptance tests from the contract |
| Quality pass | `@review-code` (4b) then `/review-bugbot` report-only (4c) |
| Local land | human `/ship-local` |
| Remote ship | human `/ship-prod` |
| Verification report | `verifier` (report-only) |
| Autonomous quality | Report-only unless step matches draft-PR allowlist |
| Ready-column issue texts | `/batch-issue-refine` (Day, two HIL gates; no code; not an Automation) |

## Write for agents (before you save)

The agent takes the same *process* every run. Keep the skill predictable.

- **Pointer first.** The `description` is the always-loaded pointer: leading
  word, what it does, the distinct branches that should fire it. Cut synonyms
  that rename one branch.
- **Steps vs reference.** Ordered actions stay in `SKILL.md`. Long rules go
  one level down behind a pointer. Inline only what every branch needs.
- **Completion criterion** on every step: checkable and exhaustive ("the
  named red command has been run once") not fuzzy ("understanding reached").
- **Prompt the positive.** State the target behaviour. A ban earns a line
  only as a hard guardrail, paired with what to do instead.
- **One meaning, one place.** Do not restate `testing` or `core-principles`.
  Discover commands from the project; do not cache `package.json`.
- **Leading word** when a pretrained token already holds the idea (`packet`,
  `tight`, `red`). Do not coin jargon.
- **Prune no-ops.** If a sentence does not change default agent behaviour,
  delete the sentence.
- Same rules apply to `contract.md` and AI-ready issue bodies.

## Style

- Plain words. Keep new workflow skills thin — orchestrate existing skills.
- **One job per skill.** Do not fold audit + fix + coverage + E2E merge into one playbook.
- Prefer a report-only skill plus HIL before a write skill. Fan out with subagents when
  tracks are independent (`verifier`, Bugbot, Security Review, `explore`, `ci-investigator`).
- No second wiki. One-line HARNESS entries only.
- Do not bake product names or one-repo scripts into shared workflow skills.
- Proposed backlog: [README workflow ideas](../../README.md#workflow-ideas)
  (test suite, frontend, docs-to-stories, performance).
  README flowcharts copy the theme in [CONTRIBUTING.md](../../CONTRIBUTING.md#readme-flowcharts).
