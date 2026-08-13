# Skills

Playbooks the agent follows. Installed to `.cursor/skills/` (workflows under
`skills/workflows/`). Procedure lives in each `SKILL.md` — this page is a catalog.
How they chain: [README workflows](../README.md#workflows).

## Spine (day / night / ship)

| Skill | When | File |
| --- | --- | --- |
| `grill-me` | Auto at Phase 1 for non-trivial ideas | [grill-me](../skills/grill-me/SKILL.md) |
| `implementation-plan-review` | Human `/implementation-plan-review` after reading the draft plan | [implementation-plan-review](../skills/implementation-plan-review/SKILL.md) |
| `execute-approved-plan` | Night shift after explicit contract approval | [execute-approved-plan](../skills/execute-approved-plan/SKILL.md) |
| `project-memory` | Phase 1 load; Phase 5 Candidates; Phase 7 promote ask | [project-memory](../skills/project-memory/SKILL.md) |
| `generate-bdd-test-spec` | Before feature tests | [generate-bdd-test-spec](../skills/generate-bdd-test-spec/SKILL.md) |
| `review-code` | Phase 4b after a green ladder | [review-code](../skills/review-code/SKILL.md) |
| `sync-spec-docs` | Phase 5 product-story / acceptance updates | [sync-spec-docs](../skills/sync-spec-docs/SKILL.md) |
| `ship-local` | Human `/ship-local` — local merge + current worktree cleanup | [ship-local](../skills/ship-local/SKILL.md) |

## Workflow orchestrators

Thin sequences. Do not duplicate their steps here.

| Skill | When | File |
| --- | --- | --- |
| `feature-delivery` | New feature / page | [feature-delivery](../skills/workflows/feature-delivery/SKILL.md) |
| `bugfix` | Defect | [bugfix](../skills/workflows/bugfix/SKILL.md) |
| `batch-issue-refine` | Ready-column GitHub texts (no code) | [batch-issue-refine](../skills/workflows/batch-issue-refine/SKILL.md) |
| `ship-prod` | Watched remote ship + CI fix + Phase 7 | [ship-prod](../skills/workflows/ship-prod/SKILL.md) |

## Batch issue refine (phase skills)

Used only from `/batch-issue-refine` (or when named). Config:
[batch-issue-refine.local.example.md](../templates/batch-issue-refine.local.example.md).

| Skill | Job | File |
| --- | --- | --- |
| `batch-issue-ingest` | Pull Ready items; tag `BUG FIX` / `NEW FEATURE` | [batch-issue-ingest](../skills/batch-issue-ingest/SKILL.md) |
| `market-ux-strategy` | Feature-only: competitors, minimal UX, edge | [market-ux-strategy](../skills/market-ux-strategy/SKILL.md) |
| `value-validator` | Feature-only: `PROCEED` / `PRUNE` / `DISCARD` | [value-validator](../skills/value-validator/SKILL.md) |
| `issue-text-refiner` | AI-ready issue bodies + blockers | [issue-text-refiner](../skills/issue-text-refiner/SKILL.md) |
| `issue-board-sync` | Preview + `gh issue edit` script; run after HIL 2 | [issue-board-sync](../skills/issue-board-sync/SKILL.md) |

## Meta / helpers

| Skill | When | File |
| --- | --- | --- |
| `help` | `/help` cheat sheet | [help](../skills/help/SKILL.md) |
| `glossary` | Shared process terms | [glossary](../skills/glossary/SKILL.md) |
| `create-workflow` | Author a new workflow; update `HARNESS.md` | [create-workflow](../skills/create-workflow/SKILL.md) |
| `sync` | Pull lab `.cursor` diffs into this portable pack | [sync](../skills/sync/SKILL.md) |
| `review-docs` | Doc drift (report first). Shrink plan: [README — Docs to user stories](../README.md#docs-to-user-stories) | [review-docs](../skills/review-docs/SKILL.md) |
| `test-harness-optimize` | Flakes, speed, coverage without weaker asserts. Split plan: [README — Optimize test suite](../README.md#optimize-test-suite) | [test-harness-optimize](../skills/test-harness-optimize/SKILL.md) |
