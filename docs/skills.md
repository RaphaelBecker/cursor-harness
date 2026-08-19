# Skills

Playbooks the agent follows. Installed to `.cursor/skills/` (workflows under
`skills/workflows/`). Procedure lives in each `SKILL.md` — this page is a catalog.
How they chain: [README workflows](../README.md#workflows).

Default install is **`core`**. Optional pack sets: `github-board`, `market-ux`, `bdd`.

## Spine (prep / nightshift / ship)

| Skill | When | File |
| --- | --- | --- |
| `grill-me` | Prep packet (conversational grill is an escape hatch) | [grill-me](../skills/grill-me/SKILL.md) |
| `implementation-plan-review` | Human `/implementation-plan-review` after reading the draft plan | [implementation-plan-review](../skills/implementation-plan-review/SKILL.md) |
| `execute-approved-plan` | Nightshift after explicit contract approval | [execute-approved-plan](../skills/execute-approved-plan/SKILL.md) |
| `project-memory` | Phase 1 load; Phase 5 Candidates; Phase 7 promote ask | [project-memory](../skills/project-memory/SKILL.md) |
| `review-code` | Phase 4b after a green ladder | [review-code](../skills/review-code/SKILL.md) |
| `blast-radius` | Sensitive diff: one proven safety fact | [blast-radius](../skills/blast-radius/SKILL.md) |
| `diagnose-bug` | Non-trivial `/bugfix` prep: tight red command | [diagnose-bug](../skills/diagnose-bug/SKILL.md) |
| `sync-spec-docs` | Phase 5 product-story / acceptance updates | [sync-spec-docs](../skills/sync-spec-docs/SKILL.md) |
| `ship-local` | Human `/ship-local` — local merge + current worktree cleanup | [ship-local](../skills/ship-local/SKILL.md) |

## Workflow orchestrators

Thin sequences. Do not duplicate their steps here.

| Skill | Pack | When | File |
| --- | --- | --- | --- |
| `prep` | core | Short workpack HIL into existing worktrees | [prep](../skills/workflows/prep/SKILL.md) |
| `night-shift` | core | Fire / status; never creates worktrees | [night-shift](../skills/workflows/night-shift/SKILL.md) |
| `feature-delivery` | core | New feature / page | [feature-delivery](../skills/workflows/feature-delivery/SKILL.md) |
| `bugfix` | core | Defect | [bugfix](../skills/workflows/bugfix/SKILL.md) |
| `architecture-improve` | core | One module smell | [architecture-improve](../skills/workflows/architecture-improve/SKILL.md) |
| `ship-prod` | core | Watched remote ship + CI fix + Phase 7 | [ship-prod](../skills/workflows/ship-prod/SKILL.md) |
| `batch-issue-refine` | github-board | Ready-column GitHub texts (no code) | [batch-issue-refine](../skills/workflows/batch-issue-refine/SKILL.md) |

## Optional pack skills

| Skill | Pack | Job | File |
| --- | --- | --- | --- |
| `batch-issue-ingest` | github-board | Pull Ready items; tag `BUG FIX` / `NEW FEATURE` | [batch-issue-ingest](../skills/batch-issue-ingest/SKILL.md) |
| `issue-text-refiner` | github-board | AI-ready issue bodies + blockers | [issue-text-refiner](../skills/issue-text-refiner/SKILL.md) |
| `issue-board-sync` | github-board | Preview + `gh issue edit` script; run after HIL 2 | [issue-board-sync](../skills/issue-board-sync/SKILL.md) |
| `market-ux-strategy` | market-ux | Feature-only: competitors, minimal UX, edge | [market-ux-strategy](../skills/market-ux-strategy/SKILL.md) |
| `value-validator` | market-ux | Feature-only: `PROCEED` / `PRUNE` / `DISCARD` | [value-validator](../skills/value-validator/SKILL.md) |
| `generate-bdd-test-spec` | bdd | Write Given/When/Then before feature tests | [generate-bdd-test-spec](../skills/generate-bdd-test-spec/SKILL.md) |

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
| `review-docs` | Doc drift (report first). Shrink plan: [README — Docs to user stories](../README.md#docs-to-user-stories) | [review-docs](../skills/review-docs/SKILL.md) |
| `test-harness-optimize` | Flakes, speed, coverage without weaker asserts. Split plan: [README — Optimize test suite](../README.md#optimize-test-suite) | [test-harness-optimize](../skills/test-harness-optimize/SKILL.md) |
