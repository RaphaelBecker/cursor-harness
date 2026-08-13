# Cursor harness map

**Harness** = the whole Cursor framework here: skills, rules, subagents/agents, hooks,
automations, workflows, and plans.

Simple inventory of what exists. Not a wiki. One line each. Details live in the linked
skill/rule file. Human catalogs: [docs/](docs/). Workflows: [README.md](README.md#workflows).

- **Quick cheat sheet:** type `/help` in Agent chat
- **Full map:** this file (installed as `.cursor/HARNESS.md`)
- **Terms:** `/glossary`

**Context tax:** always-on = core rules (`core-principles`, `doc-routing`, `deep-modules`,
`developer-communication`, plus portable `code-quality` / `testing` / `security-basics`).
Planning loads `feature-delivery` → domain `project_memory` slice → `grill-me` → **one**
routed doc row — do not bulk-read `docs/`.

---

## 1. How work runs

- **Day shift** — Plan with you: grill → plan → you run plan review → you approve.
  Board-text batch: `/batch-issue-refine` (two HIL gates; no implementation).
- **Night shift** — After approval: implement, ladder (`testing` rule), `@review-code` (4b),
  `/review-bugbot` (+ `/review-security` when sensitive) report-only (4c), sync docs,
  scored Candidates + cycle status, handoff. Local merge/cleanup via `/ship-local` when
  you ask; watched remote ship via `/ship-prod` when you ask.
- **Autonomous** — Scheduled cloud agents for quality (mostly report-only; draft PRs only on an allowlist).
- **Map rule** — Any new skill, rule, agent, workflow, or automation stub must update **this file**.

---

## 2. Workflows

| Name | When | Shift |
| --- | --- | --- |
| Cheat sheet | Anytime | `/help` |
| See what exists | Anytime | Open this file |
| Create a workflow | Add a new process | Day → `/create-workflow` |
| Sync from lab | Pull portable diffs from a live `.cursor` | Meta → `/sync` |
| Feature delivery | New feature / page | Day → Night → `feature-delivery` |
| Bug fix | Defect | Day → Night → `bugfix` |
| Batch issue refine | Ready-column GitHub texts → AI-ready, no code | Day → `/batch-issue-refine` |
| Ship prod | Clean local default → watched CI → green → Phase 7 | Hybrid → `/ship-prod` |
| Test harness optimize | Flakes, speed, coverage | Day or Autonomous |
| Daily quality automations | Recurring hygiene | Autonomous (see automations README) |

Proposed (not installed): [README workflow ideas](README.md#workflow-ideas) —
architecture, test suite, frontend tokens, docs-to-user-stories, performance.

---

## 3. Skills

### Spine (day / night)

| Skill | What it does |
| --- | --- |
| `grill-me` | Ask hard product questions before the plan |
| `implementation-plan-review` | Turn a plan into an executable contract (you trigger it) |
| `execute-approved-plan` | Night shift: build, ladder, 4b/4c review, docs, lessons → Candidates, handoff |
| `project-memory` | Phase 1 load; Phase 5 scored Candidates; Phase 7 Architecture + staged harness promote ask |
| `ship-local` | Human-triggered reliable local merge: refresh default, absorb main-ahead, auto-resolve conflicts, land feature, clean worktree (no remote push) |
| `generate-bdd-test-spec` | Write Given/When/Then before feature tests |
| `sync-spec-docs` | Update product acceptance / thin contracts after code changes |
| `review-code` | Phase 4b: fix-capable maintainability review after green ladder |
| `glossary` | Shared plain-language terms |
| `help` | Compact developer cheat sheet (`/help`) |

### Workflows & meta

| Skill | What it does |
| --- | --- |
| `create-workflow` | Guide a new workflow; update this HARNESS file |
| `sync` | Pull lab `.cursor` diffs into this portable pack; strip product leaks |
| `feature-delivery` | Thin orchestrator for full features |
| `bugfix` | Thin orchestrator for bugs |
| `batch-issue-refine` | Thin Day orchestrator: Ready-batch ingest → value gates → refined issue texts → HIL sync |
| `batch-issue-ingest` | Pull Ready-column issues; triage `BUG FIX` / `NEW FEATURE` |
| `market-ux-strategy` | Feature-only competitor benchmark, minimal UX, edge |
| `value-validator` | Feature-only `PROCEED` / `PRUNE` / `DISCARD` (HIL 1) |
| `issue-text-refiner` | Ambiguity-free AI-ready issue bodies + blockers |
| `issue-board-sync` | Preview + `gh issue edit` script; run only after HIL 2 |
| `ship-prod` | Human-triggered prod delivery: local green → project ship → watch CI → fix red (+ Bugbot) → Phase 7 |
| `review-docs` | Doc drift audit (report default) |
| `test-harness-optimize` | Faster/less flaky tests without weaker asserts |

---

## 4. Rules

| Rule | When | Job |
| --- | --- | --- |
| `core-principles` | Always | Lifecycle, hard stops, day/night |
| `deep-modules-clean-architecture` | Always | Deep modules, clean boundaries |
| `doc-routing` | Always | Which doc to read; product story first |
| `developer-communication` | Always | Plain talk with you |
| `code-quality` | Always | Architecture + craft defaults |
| `testing` | Always | Ladder SSOT, gates, bug regression |
| `security-basics` | Always | Secrets, boundaries, least privilege |

---

## 5. Subagents

| Agent | Job |
| --- | --- |
| `verifier` | Discover and run project typecheck/lint/tests; report only |
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

See [`automations/README.md`](automations/README.md). Create live ones in the Agents Window after install.

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
| Day | `/feature-delivery`, `/implementation-plan-review`, `/batch-issue-refine` |
| Night quality | `@review-code` then `/review-bugbot` (+ `/review-security` when sensitive) |
| Local ship | `/ship-local` after merge-ready Phase 5 |
| Prod ship | `/ship-prod` after clean local default is ready (watch + CI fix + Phase 7) |
| Ship / PR | `/autopilot`, `/split-to-prs`, `/loop` to watch CI/deploy |
| Cloud night jobs | `/automate` ← stubs in automations README |
| Meta | `/create-skill`, `/create-rule`, `/create-hook`, `/create-subagent` |

---

## 9. Docs ideology (short)

1. Product story / user acceptance first
2. Then the code
3. Thin system contracts only where the project needs them (security, money, ingest, critical E2E)

Full keyword map: `.cursor/rules/doc-routing.mdc` (+ consumer `doc-routing.local.mdc`).
