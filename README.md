# cursor-harness

A **portable**, project-agnostic pack of Cursor **rules**, **skills**, **agents**,
**hooks**, and **automation stubs** for AI-accelerated software engineering. It encodes a
day/night lifecycle (plan contract → autonomous execution), a HARNESS inventory map, doc
routing, testing/security discipline, and safe shell guards — without binding to any one
product stack.

Install into any project as a git submodule, then run `install.sh` to materialize packs under
`.cursor/`. Put product- or stack-specific guidance in consumer-owned local overrides.

## What's included

### Inventory

| Pack | Purpose |
|------|---------|
| `HARNESS.md` | Installed as `.cursor/HARNESS.md` — short map of skills/rules/agents/workflows |

### Rules

| Pack | Purpose |
|------|---------|
| `core-principles` | Lifecycle, day/night contract, hard stops, SemVer |
| `deep-modules-clean-architecture` | Deep modules + clean boundaries |
| `doc-routing` | Keyword → canonical doc protocol (product story first) |
| `developer-communication` | Plain, short language with the human |
| `code-quality` | Architecture + clean-code defaults |
| `testing` | Regression-first bugs, BDD design, gate hygiene |
| `security-basics` | Secrets, boundaries, least privilege |

### Skills

| Pack | Purpose |
|------|---------|
| `grill-me` | Auto Phase 1 hard questions (human triggers plan review) |
| `implementation-plan-review` | Human-triggered contract gate (Gates A–C) |
| `execute-approved-plan` | Autonomous Phases 2–5 + 4b/4c + Candidates handoff |
| `project-memory` | Phase 1 load / Phase 5 Candidates / Phase 7 promote ask |
| `ship-local` | Human-triggered reliable local merge + worktree cleanup |
| `generate-bdd-test-spec` | Given/When/Then before feature tests |
| `review-code` | Diff-scoped Phase 4b fix-capable review |
| `sync-spec-docs` | Phase 5 product-story / canonical doc sync |
| `help` / `glossary` | Cheat sheet + shared process terms |
| `create-workflow` | Author new workflows; update HARNESS |
| `sync` | Pull lab `.cursor` diffs into this portable pack (`/sync`) |
| `review-docs` / `test-harness-optimize` | Doc drift + flake/speed helpers |
| `workflows/feature-delivery` | Thin day→night feature orchestrator |
| `workflows/bugfix` | Thin day→night bug orchestrator |
| `workflows/ship-prod` | Watched remote ship + CI fix + Phase 7 |

### Agents & automations

| Pack | Purpose |
|------|---------|
| `verifier` | Report-only typecheck/lint/test discovery |
| `automations/README.md` | Cron/CI quality stubs (draft-PR allowlist + hard deny) |

### Hooks

| Pack | Event | Purpose |
|------|-------|---------|
| `session-bootstrap` | `sessionStart` | Lifecycle/skills reminder |
| `protect-secrets-prompt` | `beforeSubmitPrompt` | Secret-pattern guard |
| `guard-destructive-shell` | `beforeShellExecution` | Confirm destructive DB / force-push |

## Quick install (submodule)

From your project root:

```bash
git submodule add git@github.com:RaphaelBecker/cursor-harness.git vendor/cursor-harness
./vendor/cursor-harness/install.sh --target . --mode symlink --with-agents
```

Optional: copy `vendor/cursor-harness/templates/project_memory.example.md` to
`project_memory.md`, and add a local doc map from
`templates/doc-routing.local.example.mdc`.

Commit the submodule entry, `.cursor/` links (or copied files), and optional `AGENTS.md`.

### Update

```bash
git submodule update --remote vendor/cursor-harness
./vendor/cursor-harness/install.sh --target .
```

### Copy mode (CI / no symlinks)

```bash
./vendor/cursor-harness/install.sh --target . --mode copy
```

## Layout

```text
cursor-harness/
├── HARNESS.md          # inventory SSOT → .cursor/HARNESS.md
├── install.sh          # install into a project
├── manifest.yaml       # pack registry
├── rules/              # *.mdc project rules
├── skills/             # skill packs (SKILL.md) + workflows/
├── agents/             # portable subagent templates
├── automations/        # cloud automation stubs
├── hooks/              # hooks.json + scripts/
├── templates/          # AGENTS.md, memory + override examples
└── docs/               # architecture and install notes
```

See [docs/install.md](docs/install.md) and [docs/architecture.md](docs/architecture.md).

## Design doctrine

- **Portable core** — never ship product names, private paths, or one-repo npm scripts.
- **Local overrides** — stack and domain policy live in the consumer project.
- **Docs over always-apply topic rules** — extend keyword routing; do not multiply global rules.
- **Map sync** — any new pack updates root `HARNESS.md` in the same change.

## Adding packs

See [CONTRIBUTING.md](CONTRIBUTING.md). Short version: add the rule/skill/hook under the
matching directory, register it in `manifest.yaml`, update `HARNESS.md`, re-run `install.sh`
in a consumer project.

## Requirements

- bash
- python3 (stdlib only — used by `install.sh` and hook scripts)
- git (for submodule workflow)

## License

MIT — see [LICENSE](LICENSE).
