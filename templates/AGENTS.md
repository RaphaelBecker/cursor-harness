# Agent guidance

This repository uses **cursor-harness** for shared Cursor rules, skills, agents, hooks,
and automation stubs. Cursor is the current coding platform.

- Project interface: `harness.project.yaml` (required)
- Inventory: `.cursor/HARNESS.md` (type `/help` for a cheat sheet; `/glossary` for terms)
- Domain overlay: `.cursor/HARNESS.local.md` when present (read after the portable map)
- Rules: `.cursor/rules/`
- Skills: `.cursor/skills/` (including `workflows/`)
- Agents: `.cursor/agents/`
- Automations: `.cursor/automations/` (hygiene stubs; Nightshift engine is `runtime/night-shift`)
- Hooks: `.cursor/hooks.json` and `.cursor/hooks/`

## Lifecycle

Follow `core-principles`:

- **Prep** (anytime, about 2h max): you create Cursor worktrees. `/prep` packet grill →
  **you** run `implementation-plan-review` → approve `.cursor/night-shift/contract.md`
- **Nightshift:** `night-shift fire` → `execute-approved-plan` unattended (park `BLOCKED.md`,
  never wait). Local Cursor CLI — see harness `docs/runtime-policy.md`.
- **After:** `night-shift status` + manual tests. Then `/ship-local` (merge-ready =
  **worktree proof**) → one **idle-main complete** on idle local default → `/ship-prod`
- Agents do not create or manage git worktrees except during human-triggered `/ship-local`
- Remote push and deploy stay human-owned unless you explicitly ask via `/ship-prod`

Thin orchestrators: `/prep`, `/night-shift`, `/ship-prod`.
Author new ones with `/create-workflow`. Flavor of the delivery spine is
contract `kind` (`feature` / `bug` / `architecture`), not a second slash.

## Useful skills

- `prep` — batch packets + contracts into trees you already opened
- `night-shift` — fire / status; never creates worktrees
- `grill-me` — packet of product questions (conversational grill is an escape hatch)
- `implementation-plan-review` — human-triggered contract approval gate
- `execute-approved-plan` — autonomous Phases 2–5 in the current workspace
- `project-memory` — Phase 1 load / Phase 5 Candidates / Phase 7 promote ask
- `ship-local` — reliable local merge onto clean default branch
- `ship-prod` — watched remote ship + CI fix + Phase 7
- `review-code` — Phase 4b fix-capable review
- `blast-radius` — proven safety fact on a sensitive diff
- `diagnose-bug` — tight red command before a non-trivial bug plan
- `wait-what` — re-pitch the last message
- `help` / `glossary` — cheat sheet and shared process terms
- `sync` — (harness maintainers) pull lab `.cursor` diffs into the portable pack

## Project-specific overrides

Copy `templates/harness.project.yaml` to the repo root first. Add local rules under
`.cursor/rules/` with names that do **not** collide with harness-managed files.
Copy `templates/project_memory.example.md` to root `project_memory.md` when you want
the memory overlay. Copy `templates/HARNESS.local.example.md` to `.cursor/HARNESS.local.md`
for domain inventory. Optional packs: `bdd`, `vitest`,
`playwright`, `supabase`, `nextjs`, `github-actions`, `quality-audit`.

Domain agents, MCP servers, and stack-specific autofix hooks belong in this project —
not in the portable harness pack. Autofix template: `templates/hooks/autofix.example.sh`.

Preferred: gitignored clone at `vendor/cursor-harness/` (consumer git never tracks harness
file contents). Optional: tracked git submodule. After clone/update, re-run
`./vendor/cursor-harness/install.sh --target .`.
