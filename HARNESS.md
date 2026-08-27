# Cursor harness map

**Harness** = the whole Cursor framework here: skills, rules, subagents/agents, hooks,
automations, workflows, and plans.

Simple inventory of what exists. Not a wiki. One line each. Details live in the linked
skill/rule file. Human catalogs: [docs/](docs/). Workflows: [README.md](README.md#workflows).
Project interface: **`harness.project.yaml`** (required). Night CLI:
`runtime/night-shift`. Decision rows: `runtime/log-decision`.

- **Quick cheat sheet:** type `/help` in Agent chat
- **Full map:** this file (installed as `.cursor/HARNESS.md`)
- **Domain overlay:** `.cursor/HARNESS.local.md` when present (consumer-only; read after this file)
- **Terms:** `/glossary`

**Context tax:** always-on **from this pack** = `core-principles` +
`developer-communication`. Consumer projects may add their own `alwaysApply` rules —
count those too before adding another. Everything else loads on globs or when a skill
says to read it, and human-only skills carry `disable-model-invocation: true` so they
cost nothing until invoked. Prep loads `prep` → domain `project_memory` slice → packet
`grill-me` → **one** routed doc row — do not bulk-read `docs/`.

---

## 1. How work runs

One path. Flavor is contract `kind` (`feature` | `bug` | `architecture`), not a
second slash.

- **Prep** (anytime, about 2h max) — human creates Cursor worktrees (one tree,
  one agent, one feature). `/prep`: classify `kind` → packet grill → plan review →
  ready `.cursor/night-shift/contract.md` (this item only; never sidecars).
- **Nightshift** — Cursor **Build** or `night-shift fire` runs `@execute-approved-plan`
  (fire is the unattended multi-tree launcher). Ladder (`testing` rule: **worktree proof**,
  then **idle-main complete** after `/ship-local`), `@review-code` (4b), `/review-bugbot`
  4c report-only, docs, Candidates, compact chat last line `DONE`/`PARTIAL`. Append-only
  `decisions.tsv`. Park `BLOCKED.md` instead of waiting. Working `contract.md` /
  `HANDOFF.md` are gitignored so new trees start clean.
- **After** — `night-shift status` + manual tests, then `/ship-local` (worktree) or
  leftover-commit on default; one **idle-main complete** on idle local default
  (wait live leases, bounded), then `/ship-prod`.
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
| Prep | Packets + contracts into existing worktrees | `/prep` |
| Nightshift | Fire / status local `agent -p` in those trees | `/night-shift` |
| Ship prod | Classify leftovers on default → idle-main complete (wait live lease) → watched CI → green → Phase 7 | Hybrid → `/ship-prod` |
| Codebase health audit | Whole-repo scorecard (hotspots + layer leaks) | Prep (report) → Nightshift if contracted |
| Test harness optimize | Flakes, speed, coverage | Prep or Autonomous |
| Daily quality jobs | Recurring hygiene | Autonomous (local CLI/SDK; see automations README) |

Proposed (not installed): [README workflow ideas](README.md#workflow-ideas) —
test suite, frontend tokens, docs-to-user-stories, performance.

Agents that hear “new feature”, “bug”, or “architecture change” point at `/prep`
only.

---

## 3. Skills

### Spine (prep / nightshift / ship)

| Skill | What it does |
| --- | --- |
| `grill-me` | Packet of hard questions (conversational grill is an escape hatch) |
| `implementation-plan-review` | Review a plan, pause for A/B/C, write approved contract, say ready |
| `execute-approved-plan` | Nightshift / Build: honor `kind`, worktree proof, 4b/4c, docs, lessons → Candidates, compact chat last line, HANDOFF.md |
| `project-memory` | Phase 1 load; Phase 5 scored Candidates (commit with feature); Phase 7 Architecture; list staged ids without waiting |
| `ship-local` | Human-triggered local merge, or leftover-commit when already on default; release lock before worktree remove |
| `sync-spec-docs` | Update product acceptance / thin contracts after code changes |
| `review-code` | Phase 4b: fix-capable maintainability review after green ladder |
| `blast-radius` | Explicit: one proven safety fact beyond the diff (skip copy/docs) |
| `diagnose-bug` | Tight red command before a non-trivial bug plan (`kind: bug`) |
| `glossary` | Shared plain-language terms |
| `help` | Compact developer cheat sheet (`/help`) |

### Workflows & meta

| Skill | What it does |
| --- | --- |
| `prep` | Thin prep orchestrator: `kind` + packets + contracts in human-created worktrees |
| `night-shift` | Fire/status CLI wrapper; never creates worktrees |
| `create-workflow` | Guide a new workflow; update this HARNESS file |
| `sync` | Pull lab `.cursor` diffs into this portable pack; strip product leaks |
| `architecture-audit` | Report shallow modules, cycles, layer leaks — no edits |
| `extract-deep-module` | One extract or collapse per run (`kind: architecture`) |
| `dependency-direction-fix` | One cycle or wrong-way dependency per run (`kind: architecture`) |
| `wait-what` | Re-pitch the last message in plain words |
| `ship-prod` | Human-triggered prod delivery: classify leftovers → wait live lease → idle-main complete → project ship → watch CI → Phase 7 |
| `review-docs` | Doc drift audit (report default) |
| `test-harness-optimize` | Faster/less flaky tests without weaker asserts |

### Optional packs (not in default `core` install)

| Skill | Pack | What it does |
| --- | --- | --- |
| `generate-bdd-test-spec` | `bdd` | Write Given/When/Then before feature tests |
| `generate-vitest-test` | `vitest` | Scaffold a Vitest file matching project globs |
| `implement-unit-tests` | `vitest` | Implement unit/UI scenarios from a BDD or bug contract |
| `implement-e2e-tests` | `playwright` | Playwright user-journey craft (selectors, auth, anti-flake) |
| `e2e-single-test-triage` | `playwright` | Interactive one-failure E2E design review |
| `fix-flaky-test` | `playwright` | Isolation vs full-suite flake protocol (standalone) |
| `add-supabase-migration` | `supabase` | Migration + RLS + types on isolated test DB |
| `regen-db-types` | `supabase` | Regenerate TS types from test schema |
| `verify-rls-policies` | `supabase` | Static RLS coverage over migrations |
| `inspect-db-schema` | `supabase` | Read-only schema inspect |
| `review-database` | `supabase` | Schema / thin-backend review |
| `review-sql-performance` | `supabase` | Faster SQL, identical results |
| `review-performance` | `nextjs` | App runtime perf (not the test suite) |
| `review-github-actions` | `github-actions` | CI workflow audit (pins, cache, parallelism) |
| `audit-hotspots` | `quality-audit` | Git churn × size ranking |
| `audit-module-boundaries` | `quality-audit` | Import graph vs project layering |
| `codebase-health-audit` | `quality-audit` | Whole-repo scorecard; delegates gates |

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
| `database-sql` | `supabase` pack / migrations | RLS, thin-backend views, isolated-test migrate |
| `typescript-react` | `nextjs` pack | SoC, RSC fetch, no logic in presentational components |
| `nextjs-api-routes` | `nextjs` pack | Thin handlers, explicit returns, no vendor calls from the app |
| `github-actions` | `github-actions` pack | Pins, least privilege, fail-closed paths |

---

## 5. Subagents

| Agent | Job |
| --- | --- |
| `verifier` | Discover and run worktree proof; report only |
| `architecture-health-auditor` | `quality-audit`: hotspots + boundary leaks; report only |
| `supabase-architect` | `supabase`: SQL/RLS/view design; report only |
| `db-schema-auditor` | `supabase`: dead/orphan DB objects; report only |
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
| Codebase / architecture health | Weekly | Report only (`quality-audit` pack) |

---

## 8. Built-in Cursor skills we use

| When | Use |
| --- | --- |
| Prep | `/prep`, `/implementation-plan-review` |
| Nightshift | Cursor Build or `/night-shift` + `@execute-approved-plan`; `@review-code` then `/review-bugbot` |
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
Domain inventory: `.cursor/HARNESS.local.md` when present. Consumer contract: `harness.project.yaml`.
