# Architecture

## Goals

- **Portable core** — general software-developer guidance; never project- or domain-bound
- **Maintainable packs** — one concern per rule/skill/hook
- **Easy to extend** — add a file, register in `manifest.yaml` `pack_sets`, update `HARNESS.md`, reinstall
- **Easy to integrate** — gitignored vendor clone (or optional submodule) + `install.sh` + `harness.project.yaml`
- **Cursor-native (this pass)** — ship formats Cursor actually loads; night executor is local `agent -p`

Cursor is the current coding platform. The pack stays injectable into any **app**
repo via a strict project interface. Leaving Cursor is deferred.

## Portable vs local

| Lives in cursor-harness | Lives in the consumer project |
|-------------------------|-------------------------------|
| Lifecycle, prep then nightshift, hard stops | Product vision, domain rules |
| Doc-routing *protocol* + default keywords | Keyword → path map (`doc-routing.local.mdc`) |
| Testing/security/quality discipline | Framework/folder conventions; `harness.project.yaml` test commands |
| Process skills + workflows (plan / execute / memory / review) | Stack-specific agents, MCP, autofix hooks |
| Portable `verifier` agent + automation stubs + **night-shift CLI** | Domain auditors, product MCP servers |
| Secret + destructive-shell guards | Deploy scripts, private env layout |
| `.cursor/HARNESS.md` inventory | `.cursor/HARNESS.local.md` for domain packs |
| Optional packs (`bdd`, stack packs) | Whether to opt in via `packs:` |

The only **required** consumer file is [`harness.project.yaml`](../templates/harness.project.yaml).
Templates (`project_memory.example.md`, `doc-routing.local.example.mdc`) remain optional
overlays. `project_memory.md` is the project **summary**.

## Why not root `.cursorrules`?

Modern Cursor project guidance lives in:

| Asset | Location |
|-------|----------|
| Project interface | `harness.project.yaml` at repo root |
| Inventory map | `.cursor/HARNESS.md` |
| Rules | `.cursor/rules/*.mdc` |
| Skills | `.cursor/skills/<name>/SKILL.md` |
| Agents | `.cursor/agents/*.md` |
| Automations stubs | `.cursor/automations/` |
| Hooks | `.cursor/hooks.json` + `.cursor/hooks/*` |
| Optional agent pointer | `AGENTS.md` at project root |

A single root `.cursorrules` file does not scale for shared packs, file-scoped activation, or skill discovery. This harness targets the modern layout.

## Source vs installed tree

```text
cursor-harness/                 consumer project/
  HARNESS.md           ──►        .cursor/HARNESS.md
  rules/*.mdc          ──►        .cursor/rules/*.mdc  (filtered by pack set)
  skills/<name>/       ──►        .cursor/skills/<name>/
  agents/*.md          ──►        .cursor/agents/*.md
  automations/*        ──►        .cursor/automations/*  (files, not a dir symlink)
  hooks/scripts/*      ──►        .cursor/hooks/*
  hooks/hooks.json     ──merge──► .cursor/hooks.json
  (managed paths)      ──►        .cursor/.gitignore (BEGIN/END markers)
  templates/AGENTS.md  ──opt──►   AGENTS.md
  templates/HARNESS.local.example.md  ──copy──►  .cursor/HARNESS.local.md (optional)
  templates/harness.project.yaml  ──copy──►  harness.project.yaml (required)
  runtime/night-shift  (not installed; run from vendor path)
  runtime/log-decision (not installed; appends decisions.tsv)
```

Authoring paths mirror destinations so contributors do not learn a second schema.
Nested skills (e.g. `workflows/prep`) install under `.cursor/skills/workflows/`.
Human catalogs in `docs/` are **not** installed into `.cursor/` — they stay in the vendor
tree and are linked from [README.md](../README.md#contents).

## Distribution model

Preferred: **gitignored nested clone** at `vendor/cursor-harness/`. Consumer git never
tracks harness contents. Optional: tracked **submodule** that pins a SHA.

1. Clone (or submodule-add) into `vendor/cursor-harness`.
2. **Copy** `templates/harness.project.yaml` to the repo root and fill it.
3. **`install.sh`** checks that file (fail closed), then materializes packs into `.cursor/`:
   - `symlink` (default) — consumer always sees the vendor contents
   - `copy` — snapshots files (better for environments that break symlinks)
   - `--packs` or `packs:` in the YAML selects `core` plus optional sets
   - writes a managed block in `.cursor/.gitignore` for harness paths
   - installs automations as **files** so local stubs can sit beside them

Updates are: pull (or submodule bump) + re-run install. Harness commits happen only
inside the vendor clone.

## Override strategy

Harness-managed paths may be symlinks. Project-specific guidance should use **new filenames** (see `templates/local-override.example.mdc`) so reinstalls do not fight local edits. Domain map: `.cursor/HARNESS.local.md`.

`install.sh` refuses to overwrite a non-symlink destination unless `--force` is passed.

## Hooks merge policy

Harness entries are identified by their `command` path (e.g. `.cursor/hooks/session-bootstrap.sh`). On install:

1. Load existing project `hooks.json` if present
2. Remove entries whose `command` is harness-managed
3. Append current harness entries
4. Leave unrelated project hooks untouched

## Pack registry

`manifest.yaml` `pack_sets` is the install source of truth. Default install is **`core`**.
Optional: `bdd`, `vitest`, `playwright`, `supabase`,
`nextjs`, `github-actions`, `quality-audit`. If a file exists on disk but is not in the
selected sets, it is not installed.

## Worktrees

Humans create Cursor worktrees. Agents and `runtime/night-shift` must not run
`git worktree add`. One tree, one agent, one feature.

## Lifecycle vs catalogs

- **Workflow sequences** (human): [README.md](../README.md#workflows)
- **Prep then Nightshift contract** (normative): [core-principles.mdc](../rules/core-principles.mdc)
- **Where agents run** (local CLI vs Cursor VMs): [runtime-policy.md](runtime-policy.md)
- **Pack catalogs:** [rules](rules.md) · [skills](skills.md) · [agents](agents.md) ·
  [hooks](hooks.md) · [automations](automations.md)
- **Agent one-liners:** [HARNESS.md](../HARNESS.md)
