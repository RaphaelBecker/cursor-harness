---
name: sync
description: >-
  Pull harness diffs from a live project `.cursor` lab into this portable
  cursor-harness pack: add new generalizable skills/rules/agents/workflows,
  update existing spine packs, strip product-specific leaks, refresh HARNESS.md
  and manifest.yaml, then smoke-install. Use when the developer runs /sync or
  asks to sync/pull harness changes from another repo's .cursor directory.
disable-model-invocation: true
---

# /sync — portable harness sync

Human-triggered only. Bring process improvements from a **live project harness**
into this **portable** pack without leaking product, stack, or private paths.

## Goal

1. Diff SOURCE `.cursor` against this repo’s packs.
2. Port every **generalizable** new/changed pack into this repo.
3. Ensure the result stays usable for **any** software project.
4. Leave a short sync report (ported / skipped / leaks fixed).

Do **not** copy a project’s domain rules, agents, MCP, plans, or one-repo scripts as-is.

## Path map

| SOURCE (lab) | TARGET (this repo) |
| --- | --- |
| `<source>/.cursor/HARNESS.md` | `HARNESS.md` |
| `<source>/.cursor/rules/*.mdc` | `rules/*.mdc` |
| `<source>/.cursor/skills/<name>/` | `skills/<name>/` |
| `<source>/.cursor/skills/workflows/<name>/` | `skills/workflows/<name>/` |
| `<source>/.cursor/agents/*.md` | `agents/*.md` (portable only) |
| `<source>/.cursor/automations/` | `automations/` |
| SOURCE hooks / mcp / plans | usually **SKIP** (consumer-local) |

This skill runs with workspace root = **cursor-harness** (the portable pack repo).

## Activation

Only when the human invokes `/sync` or clearly asks to sync/pull harness changes
from another project’s `.cursor`.

Optional arg: `/sync <absolute-path-to-project-or-.cursor>`.

If SOURCE is missing, ask once for the lab path (project root or its `.cursor` dir).
Resolve to the `.cursor` directory before continuing.

## Hard portability doctrine

Shared packs must stay project-agnostic:

- No product/brand names
- No private hosts, vault paths, or personal absolute paths (except ephemeral SOURCE
  for this run — never commit them into pack bodies)
- No one-repo npm/make script names as requirements (`test:fast`, `push:main`, …)
- No stack-only paths (`services/<product>-*`, brand token files, MDS/TWR/Stripe
  product policy, etc.) unless rewritten as discoverable/generic guidance
- Prefer “discover from README / package scripts / CI” over hardcoded commands

Leak patterns and PORT/SKIP tables: [`references/portability.md`](references/portability.md).

## Workflow

Track with TodoWrite. Work in the cursor-harness repo only (read SOURCE; write TARGET).

### 1) Resolve SOURCE and inventory

1. Confirm SOURCE `.cursor` exists and list: `HARNESS.md`, `rules/`, `skills/`,
   `agents/`, `automations/`, hooks, `mcp.json`, `plans/`.
2. List TARGET packs from `manifest.yaml` + on-disk `rules/`, `skills/`, `agents/`,
   `automations/`, `HARNESS.md`.
3. Build three buckets (file-level):
   - **NEW** — in SOURCE, no TARGET equivalent
   - **CHANGED** — both exist; meaningful process/lifecycle drift
   - **SOURCE-ONLY DOMAIN** — product/stack packs with no portable home

### 2) Classify each item: PORT or SKIP

For each NEW/CHANGED file, decide using [`references/portability.md`](references/portability.md):

- **PORT** — process spine, portable craft, generic agents/automation stubs
- **SKIP** — domain rules/skills/agents, MCP, plans, product hooks, brand/UI policy

When unsure, **SKIP** and list in the report for the human — do not guess product policy
into the portable pack.

Prefer keeping TARGET wording when SOURCE is **less** portable (regressions).

### 3) Port generalizable changes

For each PORT item:

1. Read SOURCE and the current TARGET (if any).
2. Rewrite into TARGET form:
   - Strip product names, private paths, one-repo scripts
   - Replace hardcoded gates with discovery language (`testing` rule / README / CI)
   - Keep Day/Night/ship/Candidates/4b/4c process when present
   - Do not drop portable always-apply packs (`code-quality`, `testing`, `security-basics`)
     just because SOURCE uses a thinner always-on set
3. Write/update files under TARGET (`rules/`, `skills/`, `agents/`, `automations/`,
   `HARNESS.md`, templates as needed).
4. Register new packs in `manifest.yaml`.
5. Update root `HARNESS.md` one-liners in the same change.
6. Touch consumer-facing docs only when install/layout behavior changed
   (`README.md`, `docs/architecture.md`, `docs/install.md`, `CONTRIBUTING.md`,
   `templates/AGENTS.md`).

### 4) Leak scan (mandatory)

After edits, search the portable tree (exclude `.git`, smoke temps):

```bash
rg -i 'ratiofolio|push:main|push:docs|test:fast|test:complete|polestar|hetzner|mds-pipeline|supabase-prod|knip' \
  --glob '!.git/**' --glob '!.smoke-tmp/**' .
```

Also spot-check for other product brands, private URLs, vault paths, and absolute
user home paths inside pack bodies.

Fix every hit in shared packs before finishing. Personal SOURCE path in chat is fine;
committed pack text is not.

### 5) Smoke install

```bash
./install.sh --target /tmp/harness-smoke --mode symlink --with-agents
```

Confirm new/changed packs materialize under `/tmp/harness-smoke/.cursor/`.
Fix installer/manifest issues if anything listed fails to install.

### 6) Sync report (required handoff)

```markdown
## /sync report

- SOURCE: <path>
- Ported: <paths + one-line each>
- Updated: <paths + one-line each>
- Skipped (domain/local): <paths + reason>
- Leak scan: clean | fixed <list>
- Smoke install: ok | failed <why>
- Follow-ups for human: <optional>
```

Do not commit or push unless the human asks.

## Non-goals

- Do not delete TARGET portable packs solely because SOURCE lacks them
- Do not overwrite TARGET with SOURCE byte-for-byte
- Do not import `mcp.json`, `plans/*`, or product hook scripts
- Do not auto-run day/night feature delivery — this is a meta harness-maintain skill
