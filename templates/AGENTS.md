# Agent guidance

This repository uses **cursor-harness** for shared Cursor rules, skills, agents, hooks,
and automation stubs.

- Inventory: `.cursor/HARNESS.md` (type `/help` for a cheat sheet; `/glossary` for terms)
- Rules: `.cursor/rules/`
- Skills: `.cursor/skills/` (including `workflows/`)
- Agents: `.cursor/agents/`
- Automations: `.cursor/automations/` (local CLI/SDK prompt stubs; `/automate` is overflow)
- Hooks: `.cursor/hooks.json` and `.cursor/hooks/`

## Lifecycle

Follow `core-principles`:

- **Day shift:** auto `grill-me` → draft plan → **you** run `implementation-plan-review` →
  approve the implementation contract
- **Night shift:** `execute-approved-plan` for Phases 2–5 (BDD → implement → verification
  ladder → `@review-code` 4b → `/review-bugbot` 4c → `sync-spec-docs` + Lessons learned +
  Phase 5 Candidates). Unattended: local Cursor CLI/SDK in the current worktree — see
  harness `docs/runtime-policy.md`. Do not default to cloud Automations.
- **Ship:** you run `/ship-local` then `/ship-prod` (or project push/deploy scripts)
- Agents do not create or manage git branches/worktrees except during human-triggered
  `/ship-local`
- Remote push and deploy stay human-owned unless you explicitly ask via `/ship-prod`

Thin orchestrators: `/feature-delivery`, `/bugfix`, `/batch-issue-refine`, `/ship-prod`.
Author new ones with `/create-workflow`.

## Useful skills

- `grill-me` — one-decision-at-a-time knowledge parity (auto in Phase 1)
- `implementation-plan-review` — human-triggered contract approval gate
- `execute-approved-plan` — autonomous Phases 2–5 in the current workspace
- `generate-bdd-test-spec` — Given/When/Then before feature tests
- `project-memory` — Phase 1 load / Phase 5 Candidates / Phase 7 promote ask
- `ship-local` — reliable local merge onto clean default branch
- `ship-prod` — watched remote ship + CI fix + Phase 7
- `review-code` — Phase 4b fix-capable review
- `review-docs` / `test-harness-optimize` — docs drift and flake/speed helpers
- `sync-spec-docs` — Phase 5 product-story / canonical doc updates
- `help` / `glossary` — cheat sheet and shared process terms
- `batch-issue-refine` — Ready-column GitHub texts → AI-ready (two human gates; no code)
- `sync` — (harness maintainers) pull lab `.cursor` diffs into the portable pack via `/sync`

## Project-specific overrides

Add local rules under `.cursor/rules/` with names that do **not** collide with
harness-managed files (see harness `templates/doc-routing.local.example.mdc` and
`templates/local-override.example.mdc`). Copy `templates/project_memory.example.md` to
root `project_memory.md` when you want the memory overlay (Candidates + cycle status).
For `/batch-issue-refine`, copy `templates/batch-issue-refine.local.example.md` to
`.cursor/batch-issue-refine.local.md` (project number, Ready column, notes path).

Domain agents, MCP servers, and stack-specific autofix hooks belong in this project — not in
the portable harness pack.

Update the harness submodule, then re-run `./vendor/cursor-harness/install.sh --target .`.
