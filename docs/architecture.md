# Architecture

## Goals

- **Portable core** — general software-developer guidance; never project- or domain-bound
- **Maintainable packs** — one concern per rule/skill/hook
- **Easy to extend** — add a file, register in `manifest.yaml`, reinstall
- **Easy to integrate** — git submodule + `install.sh`
- **Cursor-native** — ship formats Cursor actually loads

## Portable vs local

| Lives in cursor-harness | Lives in the consumer project |
|-------------------------|-------------------------------|
| Lifecycle, day/night contract, hard stops | Product vision, domain rules |
| Doc-routing *protocol* + default keywords | Keyword → path map (`doc-routing.local.mdc`) |
| Testing/security/quality discipline | Framework/folder conventions, glob rules |
| Process skills (plan / execute / memory / review) | Stack-specific agents, MCP, autofix hooks |
| Secret + destructive-shell guards | Deploy scripts, private env layout |

Templates (`project_memory.example.md`, `doc-routing.local.example.mdc`) show how consumers
opt into memory and project-specific routing without editing harness-managed filenames.

## Why not root `.cursorrules`?

Modern Cursor project guidance lives in:

| Asset | Location |
|-------|----------|
| Rules | `.cursor/rules/*.mdc` |
| Skills | `.cursor/skills/<name>/SKILL.md` |
| Hooks | `.cursor/hooks.json` + `.cursor/hooks/*` |
| Optional agent pointer | `AGENTS.md` at project root |

A single root `.cursorrules` file does not scale for shared packs, file-scoped activation, or skill discovery. This harness targets the modern layout.

## Source vs installed tree

```text
cursor-harness/                 consumer project/
  rules/*.mdc          ──►        .cursor/rules/*.mdc
  skills/<name>/       ──►        .cursor/skills/<name>/
  hooks/scripts/*      ──►        .cursor/hooks/*
  hooks/hooks.json     ──merge──► .cursor/hooks.json
  templates/AGENTS.md  ──opt──►   AGENTS.md
```

Authoring paths mirror destinations so contributors do not learn a second schema.

## Distribution model

1. **Submodule** pins a harness revision in the consumer repo (`vendor/cursor-harness`).
2. **`install.sh`** materializes packs into `.cursor/`:
   - `symlink` (default) — consumer always sees the submodule contents
   - `copy` — snapshots files (better for environments that break symlinks)

Updates are: submodule bump + re-run install.

## Override strategy

Harness-managed paths may be symlinks. Project-specific guidance should use **new filenames** (see `templates/local-override.example.mdc`) so reinstalls do not fight local edits.

`install.sh` refuses to overwrite a non-symlink destination unless `--force` is passed.

## Hooks merge policy

Harness entries are identified by their `command` path (e.g. `.cursor/hooks/session-bootstrap.sh`). On install:

1. Load existing project `hooks.json` if present
2. Remove entries whose `command` is harness-managed
3. Append current harness entries
4. Leave unrelated project hooks untouched

## Pack registry

`manifest.yaml` is the install source of truth. If a file exists on disk but is not listed, it is not installed. That keeps experimental drafts from leaking into consumer projects.

## Lifecycle model (packs)

`core-principles` defines a phased workflow: plan (day shift) → approved implementation
contract → autonomous Phases 2–5 via `execute-approved-plan` (night shift) → human-owned
push/deploy → optional `project-memory` consolidation. Sibling rules cover doc routing,
code quality, testing, and security. Hooks reinforce secrets and destructive-shell safety.
