# Cursor harness map

**Harness** = the whole Cursor framework here: skills, rules, subagents/agents, hooks,
automations, workflows, and plans.

Simple inventory of what exists. Not a wiki. One line each. Details live in the linked
skill/rule file. Human catalogs: [docs/](docs/). Workflows: [README.md](README.md#workflows).
Project interface: **`harness.project.yaml`** (required). Night CLI:
`runtime/night-shift`. Decision rows: `runtime/log-decision`.

- **Quick cheat sheet:** type `/help` in Agent chat
- **Full map:** this file (installed as `.cursor/HARNESS.md`)
- **Terms:** `/glossary`

**Context tax:** always-on = `core-principles` + `developer-communication` only.
Other rules load on globs or when a skill says to read them. Prep loads
`prep` → domain `project_memory` slice → packet `grill-me` → **one**
routed doc row — do not bulk-read `docs/`.

---

## 1. How work runs

- **Prep** (anytime, about 2h max) — human creates Cursor worktrees (one tree,
  one agent, one feature). `/prep`: packet grill → plan review → approve
  `.cursor/night-shift/contract.md`. Optional board text: `/batch-issue-refine`
  (`github-board` pack).
- **Nightshift** — `night-shift fire` runs `@execute-approved-plan` unattended in
  each approved worktree. Ladder (`testing` rule: **worktree proof**, then
  **idle-main complete** after `/ship-local`), `@review-code` (4b), `/review-bugbot`
  4c report-only, docs, Candidates, **Manual test** handoff. Append-only
  `decisions.tsv`. Park `BLOCKED.md` instead of waiting.
- **After** — `night-shift status` + manual tests, then `/ship-local` (worktree
  proof is merge-ready), one **idle-main complete** on idle local default, then
  `/ship-prod`.
- **Autonomous** — local CLI/SDK hygiene stubs. Cloud `/automate` is overflow.
- **Map rule** — Any new skill, rule, agent, workflow, or automation stub must update **this file**.

---

## 2. Workflows

| Name | When | Shift |
| --- | --- | --- |
| Cheat sheet | Anytime | `/help` |
| See what exists | Anytime | Open this file |
| Create a workflow | Add a new process | `/create-workflow` |
| Sync from lab | Pull portable diffs from a live `.cursor` | Meta → `/sync` |
| Prep | Batch packets + contracts into existing worktrees | `/prep` |
| Nightshift | Fire / status local `agent -p` in those trees | `/night-shift` |
| Feature delivery | New feature / page (one tree) | Prep → Nightshift → `feature-delivery` |
| Bug fix | Defect (one tree) | Prep → Nightshift → `bugfix` |
| Architecture improve | One module smell | Prep → Nightshift → `architecture-improve` |
| Batch issue refine | Ready-column GitHub texts → AI-ready, no code | Optional `github-board` → `/batch-issue-refine` |
| Ship prod | Clean local default → watched CI → green → Phase 7 | Hybrid → `/ship-prod` |
| Test harness optimize | Flakes, speed, coverage | Prep or Autonomous |
| Daily quality jobs | Recurring hygiene | Autonomous (local CLI/SDK; see automations README) |

Proposed (not installed): [README workflow ideas](README.md#workflow-ideas) —
test suite, frontend tokens, docs-to-user-stories, performance.

---

## 3. Skills

### Spine (prep / nightshift / ship)

| Skill | What it does |
| --- | --- |
| `grill-me` | Packet of hard questions (conversational grill is an escape hatch) |
| `implementation-plan-review` | Turn a plan into an executable contract (you trigger it) |
| `execute-approved-plan` | Nightshift: build, worktree proof, 4b/4c, docs, lessons → Candidates, HANDOFF.md, decisions.tsv |
| `project-memory` | Phase 1 load; Phase 5 scored Candidates; Phase 7 Architecture + staged harness promote ask |
| `ship-local` | Human-triggered local merge: worktree proof is merge-ready; land feature; clean worktree (no remote push, no idle-main complete) |
| `sync-spec-docs` | Update product acceptance / thin contracts after code changes |
| `review-code` | Phase 4b: fix-capable maintainability review after green ladder |
| `blast-radius` | Explicit: one proven safety fact beyond the diff (skip copy/docs) |
| `diagnose-bug` | Tight red command before a non-trivial bug plan |
| `glossary` | Shared plain-language terms |
| `help` | Compact developer cheat sheet (`/help`) |

### Workflows & meta

| Skill | What it does |
| --- | --- |
| `prep` | Thin prep orchestrator: packets + contracts in human-created worktrees |
| `night-shift` | Fire/status CLI wrapper; never creates worktrees |
| `create-workflow` | Guide a new workflow; update this HARNESS file |
| `sync` | Pull lab `.cursor` diffs into this portable pack; strip product leaks |
| `feature-delivery` | Thin orchestrator for full features |
| `bugfix` | Thin orchestrator for bugs |
| `architecture-improve` | Thin orchestrator: one smell → audit → grill → one extract or one cycle fix |
| `architecture-audit` | Report shallow modules, cycles, layer leaks — no edits |
| `extract-deep-module` | One extract or collapse per run |
| `dependency-direction-fix` | One cycle or wrong-way dependency per run |
| `wait-what` | Re-pitch the last message in plain words |
| `ship-prod` | Human-triggered prod delivery: idle-main complete (STOP if live lease) → project ship → watch CI → fix red (+ Bugbot) → Phase 7 |
| `review-docs` | Doc drift audit (report default) |
| `test-harness-optimize` | Faster/less flaky tests without weaker asserts |

### Optional packs (not in default `core` install)

| Skill | Pack | What it does |
| --- | --- | --- |
| `batch-issue-refine` | `github-board` | Ready-batch ingest → refined issue texts → HIL sync |
| `batch-issue-ingest` | `github-board` | Pull Ready-column issues; triage `BUG FIX` / `NEW FEATURE` |
| `issue-text-refiner` | `github-board` | Ambiguity-free AI-ready issue bodies + blockers |
| `issue-board-sync` | `github-board` | Preview + `gh issue edit` script; run only after HIL 2 |
| `market-ux-strategy` | `market-ux` | Feature-only competitor benchmark, minimal UX, edge |
| `value-validator` | `market-ux` | Feature-only `PROCEED` / `PRUNE` / `DISCARD` (HIL 1) |
| `generate-bdd-test-spec` | `bdd` | Write Given/When/Then before feature tests |

---

## 4. Rules

| Rule | When | Job |
| --- | --- | --- |
| `core-principles` | Always | Lifecycle, hard stops, prep then nightshift |
| `developer-communication` | Always | Plain talk with you |
| `deep-modules-clean-architecture` | Code globs | Deep modules, clean boundaries |
| `doc-routing` | On demand | Which doc to read; product story first |
| `code-quality` | Code globs | Architecture + craft defaults |
| `testing` | Code/test globs | Ladder SSOT: worktree proof vs idle-main complete |
| `security-basics` | Code globs | Secrets, boundaries, least privilege |

---

## 5. Subagents

| Agent | Job |
| --- | --- |
| `verifier` | Discover and run worktree proof; report only |
| Bugbot / Security Review | Built-in Cursor reviewers (Phase 4c) |
| `ci-investigator` | Built-in: short root-cause of one failed CI check |
| `explore` | Built-in: fast codebase map |

Stack- or domain-specific agents belong in the consumer project (not this portable pack).

---

## 6. Hooks

| Hook | Job |
| --- | --- |
| `sessionStart` → `session-bootstrap.sh` | Lifecycle/skills reminder |
| `beforeSubmitPrompt` → `protect-secrets-prompt.sh` | Secret-pattern guard |
| `beforeShellExecution` → `guard-destructive-shell.sh` | Confirm destructive DB / force-push / `gh issue edit` |

---

## 7. Automations (stubs in repo)

See [`automations/README.md`](automations/README.md) and
[docs/runtime-policy.md](docs/runtime-policy.md). The **night engine** is
`runtime/night-shift fire`, not these stubs. `/automate` is overflow (Cursor VM).

| Stub | Trigger | Output |
| --- | --- | --- |
| Daily test health | Weekday nightly | Draft PR if allowlisted |
| Lint hygiene | Weekday nightly | Draft PR autofix-safe |
| CI failure triage | CI failed | Diagnose; draft PR only for tests/flakes |
| Dead code hygiene | 2–3×/week | Draft PR if proven |
| Security scan | Weekly | Report only |
| Spec acceptance drift | Weekly | Report only |
| Harness + doc-routing integrity | Weekly | Report only |

---

## 8. Built-in Cursor skills we use

| When | Use |
| --- | --- |
| Prep | `/prep`, `/feature-delivery`, `/implementation-plan-review` |
| Nightshift | `/night-shift` + `@execute-approved-plan`; `@review-code` then `/review-bugbot` |
| Sensitive diff | `/blast-radius` (or via Phase 4b / `/ship-local`) |
| Unclear reply | `/wait-what` |
| Local ship | `/ship-local` after manual tests |
| Prod ship | `/ship-prod` after clean local default is ready |
| Ship / PR | `/autopilot`, `/split-to-prs`, `/loop` to watch CI/deploy |
| Night hygiene | Local `agent -p` ← stubs in automations README. `/automate` only if the laptop is off |
| Meta | `/create-skill`, `/create-rule`, `/create-hook`, `/create-subagent` |

---

## 9. Docs ideology (short)

1. Product story / user acceptance first
2. Then the code
3. Thin system contracts only where the project needs them (security, money, ingest, critical E2E)

Full keyword map: `.cursor/rules/doc-routing.mdc` (+ consumer `doc-routing.local.mdc`).
Consumer contract: `harness.project.yaml`.
