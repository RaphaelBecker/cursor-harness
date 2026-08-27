# Skills

Playbooks the agent follows. Installed to `.cursor/skills/` (workflows under
`skills/workflows/`). Procedure lives in each `SKILL.md` — this page is a catalog.
How they chain: [README workflows](../README.md#workflows).

Default install is **`core`**. Optional pack sets: `bdd`, `vitest`, `playwright`,
`supabase`, `nextjs`, `github-actions`, `quality-audit`.

## Spine (prep / nightshift / ship)

| Skill | When | File |
| --- | --- | --- |
| `grill-me` | Prep packet (conversational grill is an escape hatch) | [grill-me](../skills/grill-me/SKILL.md) |
| `implementation-plan-review` | Human `/implementation-plan-review` after reading the draft plan | [implementation-plan-review](../skills/implementation-plan-review/SKILL.md) |
| `execute-approved-plan` | Nightshift / Build after explicit contract approval; honors `kind`; compact chat last line | [execute-approved-plan](../skills/execute-approved-plan/SKILL.md) |
| `project-memory` | Phase 1 load; Phase 5 Candidates; Phase 7 promote ask | [project-memory](../skills/project-memory/SKILL.md) |
| `review-code` | Phase 4b after a green worktree proof | [review-code](../skills/review-code/SKILL.md) |
| `blast-radius` | Sensitive diff: one proven safety fact | [blast-radius](../skills/blast-radius/SKILL.md) |
| `diagnose-bug` | `/prep` (`kind: bug`), or idle-main complete isolate-red / `/ship-prod` unnamed seam: tight red command | [diagnose-bug](../skills/diagnose-bug/SKILL.md) |
| `sync-spec-docs` | Phase 5 product-story / acceptance updates | [sync-spec-docs](../skills/sync-spec-docs/SKILL.md) |
| `ship-local` | Human `/ship-local` — land feature, or leftover-commit when already on default | [ship-local](../skills/ship-local/SKILL.md) |

## Workflow orchestrators

Thin sequences. Do not duplicate their steps here.

| Skill | Pack | When | File |
| --- | --- | --- | --- |
| `prep` | core | Short workpack HIL into existing worktrees | [prep](../skills/workflows/prep/SKILL.md) |
| `night-shift` | core | Fire / status; never creates worktrees | [night-shift](../skills/workflows/night-shift/SKILL.md) |
| `ship-prod` | core | Classify leftovers → wait live lease → idle-main complete → diagnose+Bugbot if isolate-red → watched remote ship + CI fix + Phase 7 | [ship-prod](../skills/workflows/ship-prod/SKILL.md) |
| `codebase-health-audit` | quality-audit | Whole-repo health scorecard | [codebase-health-audit](../skills/workflows/codebase-health-audit/SKILL.md) |

## Optional pack skills

| Skill | Pack | Job | File |
| --- | --- | --- | --- |
| `generate-bdd-test-spec` | bdd | Write Given/When/Then before feature tests | [generate-bdd-test-spec](../skills/generate-bdd-test-spec/SKILL.md) |
| `generate-vitest-test` | vitest | Scaffold Vitest matching project globs | [generate-vitest-test](../skills/generate-vitest-test/SKILL.md) |
| `implement-unit-tests` | vitest | Implement unit/UI from BDD or bug contract | [implement-unit-tests](../skills/implement-unit-tests/SKILL.md) |
| `implement-e2e-tests` | playwright | Playwright user-journey craft | [implement-e2e-tests](../skills/implement-e2e-tests/SKILL.md) |
| `e2e-single-test-triage` | playwright | Interactive one-failure E2E review | [e2e-single-test-triage](../skills/e2e-single-test-triage/SKILL.md) |
| `fix-flaky-test` | playwright | Isolation vs suite flake protocol | [fix-flaky-test](../skills/fix-flaky-test/SKILL.md) |
| `add-supabase-migration` | supabase | Migration + RLS + types | [add-supabase-migration](../skills/add-supabase-migration/SKILL.md) |
| `regen-db-types` | supabase | Regen TS types from test schema | [regen-db-types](../skills/regen-db-types/SKILL.md) |
| `verify-rls-policies` | supabase | Static RLS coverage | [verify-rls-policies](../skills/verify-rls-policies/SKILL.md) |
| `inspect-db-schema` | supabase | Read-only schema inspect | [inspect-db-schema](../skills/inspect-db-schema/SKILL.md) |
| `review-database` | supabase | Schema / thin-backend review | [review-database](../skills/review-database/SKILL.md) |
| `review-sql-performance` | supabase | Faster SQL, identical results | [review-sql-performance](../skills/review-sql-performance/SKILL.md) |
| `review-performance` | nextjs | App runtime perf | [review-performance](../skills/review-performance/SKILL.md) |
| `review-github-actions` | github-actions | CI workflow audit | [review-github-actions](../skills/review-github-actions/SKILL.md) |
| `audit-hotspots` | quality-audit | Git churn × size | [audit-hotspots](../skills/audit-hotspots/SKILL.md) |
| `audit-module-boundaries` | quality-audit | Import graph vs layering | [audit-module-boundaries](../skills/audit-module-boundaries/SKILL.md) |
| `codebase-health-audit` | quality-audit | Whole-repo scorecard | [codebase-health-audit](../skills/workflows/codebase-health-audit/SKILL.md) |

## Meta / helpers

| Skill | When | File |
| --- | --- | --- |
| `help` | `/help` cheat sheet | [help](../skills/help/SKILL.md) |
| `glossary` | Shared process terms | [glossary](../skills/glossary/SKILL.md) |
| `create-workflow` | Author a new workflow; update `HARNESS.md` | [create-workflow](../skills/create-workflow/SKILL.md) |
| `wait-what` | Re-pitch the last message | [wait-what](../skills/wait-what/SKILL.md) |
| `architecture-audit` | Report shallow modules / cycles (no edits) | [architecture-audit](../skills/architecture-audit/SKILL.md) |
| `extract-deep-module` | One extract or collapse | [extract-deep-module](../skills/extract-deep-module/SKILL.md) |
| `dependency-direction-fix` | One cycle or wrong-way dependency | [dependency-direction-fix](../skills/dependency-direction-fix/SKILL.md) |
| `sync` | Pull lab `.cursor` diffs into this portable pack | [sync](../skills/sync/SKILL.md) |
| `review-docs` | Doc drift (report first) | [review-docs](../skills/review-docs/SKILL.md) |
| `test-harness-optimize` | Flakes, speed, coverage without weaker asserts | [test-harness-optimize](../skills/test-harness-optimize/SKILL.md) |
