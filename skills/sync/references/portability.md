# Portability reference for `/sync`

Use when classifying SOURCE packs and rewriting them into this portable repo.

## PORT (generalize into TARGET)

Process / craft that applies to any software project:

| Kind | Examples |
| --- | --- |
| Lifecycle spine | `core-principles`, `grill-me`, `implementation-plan-review`, `execute-approved-plan`, `project-memory` |
| Ship spine | `ship-local`, `workflows/ship-prod` |
| Workflows | `prep`, `night-shift`, `feature-delivery`, `bugfix`, `architecture-improve`, `create-workflow` |
| Optional packs | `github-board`, `market-ux`, `bdd` (`generate-bdd-test-spec`) stay optional |
| Quality helpers | `review-code`, `review-docs`, `test-harness-optimize`, `blast-radius`, `diagnose-bug` |
| DX | `help`, `glossary` (process terms only), `HARNESS.md`, automations stubs |
| Portable agents | Generic report-only verifiers that **discover** project commands |
| Architecture rules | Deep modules, developer communication, doc-routing *protocol* (not product keyword dumps) |

Rewrite rules when porting:

- Commands → discover from README / package scripts / Makefile / CI
- Default branch → `main` or `master` (detect; do not hardcode a product ship script)
- Sensitive surfaces → auth / access-control / billing / secrets (generic), not product routes
- Glossary → process terms only; drop product/domain glossaries
- Automations → generic allowlist/deny + paste prompts without product names

## SKIP (stay in the consumer project)

| Kind | Examples |
| --- | --- |
| Product brand / UI | Corporate design tokens, product data-design, marketing tone |
| Stack domain | Product-specific DB/SQL pipelines, MDS/ingest, ticker universe, chart vendors |
| Framework globs tied to one app layout | App-router-only rules, one-service Python trees |
| Domain agents | Finance-math, community, product DB architects, brand auditors |
| Domain skills | Migrations against a named pool, RLS scanners, regen-types for one ORM layout |
| Infra wiring | `mcp.json`, vault/env hosts, deploy machine names |
| Artifacts | `plans/*`, hook caches, product autofix that assumes one lint/ruff layout |
| Keyword dumps | Full product `doc-routing` tables pointing at private doc trees |

Optional: mention in the sync report that the consumer should keep these locally.

## Leak denylist (must not remain in shared packs)

Search and remove/rewrite:

- Product or brand names (e.g. project codenames)
- One-repo scripts used as hard requirements: `push:main`, `push:docs`, `test:fast`,
  `test:complete`, `db:test:*`, product CI policy paths
- Private infra: hostnames, vault paths, self-hosted runner names, prod project IDs
- Absolute personal paths inside pack bodies (`/Users/...`)
- Stack-private folders presented as universal SSOT (`services/<product>-*`, brand JSON)

Allowed in TARGET:

- Generic tool names (`gh`, `git`, ESLint/ruff as *examples* when clearly optional)
- Portable discovery language and lifecycle terms (Day/Night, Candidates, ship-local)
- Example paths like `docs/specs/` as *typical* locations

## Prefer TARGET when SOURCE regresses

Do **not** make the portable pack less general. Keep TARGET if SOURCE:

- Hardcodes framework/test runners where TARGET discovers them
- Drops always-apply `code-quality` / `testing` / `security-basics`
- Replaces portable doc-routing with a product keyword encyclopedia
- Narrows deep-modules guidance to one framework

## Manifest + HARNESS checklist

After porting:

1. Every installed pack is listed in `manifest.yaml` `pack_sets`
2. Nested skills use paths like `workflows/<name>`
3. `HARNESS.md` has one-line inventory rows for new packs
4. Copy `templates/harness.project.yaml` then
   `./install.sh --target /tmp/harness-smoke --mode symlink --with-agents` succeeds
