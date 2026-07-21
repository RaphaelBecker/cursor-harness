# cursor-harness

A **portable**, project-agnostic pack of Cursor **rules**, **skills**, and **hooks** for
AI-accelerated software engineering. It encodes a day/night lifecycle (plan contract →
autonomous execution), doc routing, testing/security discipline, and safe shell guards —
without binding to any one product stack.

Install into any project as a git submodule, then run `install.sh` to materialize packs under
`.cursor/`. Put product- or stack-specific guidance in consumer-owned local overrides.

## What's included

### Rules

| Pack | Purpose |
|------|---------|
| `core-principles` | Lifecycle, day/night contract, hard stops, SemVer |
| `doc-routing` | Keyword → canonical doc protocol |
| `code-quality` | Architecture + clean-code defaults |
| `testing` | Regression-first bugs, acceptance design, gate hygiene |
| `security-basics` | Secrets, boundaries, least privilege |

### Skills

| Pack | Purpose |
|------|---------|
| `implementation-plan-review` | Grill → harden → implementation contract |
| `grill-me` | One-decision knowledge parity |
| `execute-approved-plan` | Autonomous Phases 2–5 + local commits |
| `project-memory` | Phase 1 load / Phase 7 consolidate |
| `review-code` | Diff-scoped Phase 4b review |
| `sync-spec-docs` | Phase 5 canonical doc sync |

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
├── install.sh          # install into a project
├── manifest.yaml       # pack registry
├── rules/              # *.mdc project rules
├── skills/             # skill packs (SKILL.md)
├── hooks/              # hooks.json + scripts/
├── templates/          # AGENTS.md, memory + override examples
└── docs/               # architecture and install notes
```

See [docs/install.md](docs/install.md) and [docs/architecture.md](docs/architecture.md).

## Design doctrine

- **Portable core** — never ship product names, private paths, or one-repo npm scripts.
- **Local overrides** — stack and domain policy live in the consumer project.
- **Docs over always-apply topic rules** — extend keyword routing; do not multiply global rules.

## Adding packs

See [CONTRIBUTING.md](CONTRIBUTING.md). Short version: add the rule/skill/hook under the
matching directory, register it in `manifest.yaml`, re-run `install.sh` in a consumer project.

## Requirements

- bash
- python3 (stdlib only — used by `install.sh` and hook scripts)
- git (for submodule workflow)

## License

MIT — see [LICENSE](LICENSE).
