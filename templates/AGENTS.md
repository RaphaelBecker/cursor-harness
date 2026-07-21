# Agent guidance

This repository uses **cursor-harness** for shared Cursor rules, skills, and hooks.

- Rules: `.cursor/rules/`
- Skills: `.cursor/skills/`
- Hooks: `.cursor/hooks.json` and `.cursor/hooks/`

## Lifecycle

Follow `core-principles`: day-shift planning produces an **implementation contract**; one
explicit approval authorizes night-shift `execute-approved-plan` for Phases 2–5 and local
commits. Merge, push, and deploy stay human-owned unless you explicitly ask.

## Useful skills

- `implementation-plan-review` — grill → harden → contract approval gate
- `grill-me` — one-decision-at-a-time knowledge parity
- `execute-approved-plan` — autonomous Phases 2–5 on a feature branch
- `project-memory` — Phase 1 load / Phase 7 consolidate into `project_memory.md`
- `review-code` — Phase 4b diff-scoped review
- `sync-spec-docs` — Phase 5 canonical doc updates via `doc-routing`

## Project-specific overrides

Add local rules under `.cursor/rules/` with names that do **not** collide with
harness-managed files (see harness `templates/doc-routing.local.example.mdc` and
`templates/local-override.example.mdc`). Copy `templates/project_memory.example.md` to
root `project_memory.md` when you want the memory overlay.

Update the harness submodule, then re-run `./vendor/cursor-harness/install.sh --target .`.
