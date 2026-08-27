# Install guide

Workflows: [README.md](../README.md#workflows). Pack catalogs: [docs/](.).
Interface: [templates/harness.project.yaml](../templates/harness.project.yaml).

## Requirements

- `bash`
- `python3` (stdlib only)
- `git`
- Cursor CLI `agent` on PATH for `night-shift fire` (not required merely to install)

## Gitignored vendor clone (preferred)

Consumer git never tracks harness file contents. Skills/rules still load because Cursor
reads the filesystem (resolved symlinks under `.cursor/`), not git.

```bash
# from the consumer project root
git clone git@github.com:RaphaelBecker/cursor-harness.git vendor/cursor-harness
echo 'vendor/cursor-harness' >> .gitignore
./vendor/cursor-harness/install.sh --target . --init --mode symlink --with-agents
```

Edit `harness.project.yaml` (`issue_source`, `packs`, test commands). Commit the YAML,
`AGENTS.md` if created, overlay files (`*.local.mdc`, `HARNESS.local.md`, domain skills),
and `.cursor/.gitignore` (managed block is written by install). Do **not** commit
`vendor/cursor-harness/`.

HTTPS remote alternative:

```bash
git clone https://github.com/RaphaelBecker/cursor-harness.git vendor/cursor-harness
```

`--init` copies the YAML if missing. Install **fails closed** without a valid
`harness.project.yaml` (unless `--no-check`).

### Fresh clone of a consumer that gitignores the vendor

```bash
git clone <your-project-url>
git clone git@github.com:RaphaelBecker/cursor-harness.git vendor/cursor-harness
./vendor/cursor-harness/install.sh --target .
```

Until bootstrap, harness-managed `.cursor/` paths may be missing or dangling. That is
expected.

### Update the harness

```bash
git -C vendor/cursor-harness pull
./vendor/cursor-harness/install.sh --target .
```

Commit harness changes **inside** `vendor/cursor-harness` (its own git). Never
`git add` consumer overlays into the harness remote.

## Tracked submodule (optional)

Pins a harness SHA in the consumer repo. Use when other clones must get the vendor
via `--recurse-submodules`.

```bash
git submodule add git@github.com:RaphaelBecker/cursor-harness.git vendor/cursor-harness
cp vendor/cursor-harness/templates/harness.project.yaml harness.project.yaml
./vendor/cursor-harness/install.sh --target . --mode symlink --with-agents
git add .gitmodules vendor/cursor-harness harness.project.yaml AGENTS.md .cursor/.gitignore
```

Prefer still gitignoring harness-managed `.cursor/` paths (install writes that block)
so product overlays stay the only committed Cursor files.

Update:

```bash
git submodule update --remote vendor/cursor-harness
./vendor/cursor-harness/install.sh --target .
git add vendor/cursor-harness
```

## What gets installed

| Source | Destination |
|--------|-------------|
| `HARNESS.md` | `.cursor/HARNESS.md` |
| selected `rules/*.mdc` | `.cursor/rules/` |
| selected `skills/**` | `.cursor/skills/` (including `workflows/`) |
| `agents/*.md` | `.cursor/agents/` |
| `automations/*` (files) | `.cursor/automations/` (not a directory symlink) |
| `hooks/scripts/*` + merge `hooks.json` | `.cursor/hooks/` + `.cursor/hooks.json` |
| managed gitignore block | `.cursor/.gitignore` |
| `templates/AGENTS.md` (optional) | project root `AGENTS.md` |

Not installed (run from the vendor path): `runtime/night-shift`,
`runtime/log-decision`.

Default pack set is **`core`**. Optional: `bdd`,
`vitest`, `playwright`, `supabase`, `nextjs`, `github-actions`, `quality-audit`.

Domain inventory: copy
[templates/HARNESS.local.example.md](../templates/HARNESS.local.example.md) →
`.cursor/HARNESS.local.md`. Keyword maps:
[templates/doc-routing.local.example.mdc](../templates/doc-routing.local.example.mdc).
Autofix hook (consumer-owned):
[templates/hooks/autofix.example.sh](../templates/hooks/autofix.example.sh).

## install.sh flags

| Flag | Description |
|------|-------------|
| `--target <path>` | Project root (default: parent of `vendor/cursor-harness`, else cwd) |
| `--mode symlink\|copy` | Link or copy packs (default: `symlink`) |
| `--packs <list>` | Pack sets from `manifest.yaml`, or `all`. Default: YAML `packs:` |
| `--init` | Copy `templates/harness.project.yaml` if the target has none |
| `--check` | Validate `harness.project.yaml` and exit |
| `--no-check` | Skip the interface check |
| `--force` | Replace existing non-symlink harness destinations |
| `--with-agents` | Copy `templates/AGENTS.md` if project root has none |
| `--dry-run` | Print actions only |

## Night shift CLI

```bash
./vendor/cursor-harness/runtime/night-shift check
./vendor/cursor-harness/runtime/night-shift discover
./vendor/cursor-harness/runtime/night-shift fire
./vendor/cursor-harness/runtime/night-shift status
```

Discovers **existing** git worktrees only. Never `git worktree add`. Optional
`launchd` unit: [templates/launchd](../templates/launchd/com.cursor-harness.night-shift.plist.example).

## CI notes

- Prefer `--mode copy` when runners or packaging steps do not preserve symlinks.
- Re-run install after vendor checkout if `.cursor/` harness paths are gitignored.
- Hook scripts need `python3` on `PATH` in developer environments (hooks run locally in Cursor, not necessarily in CI).
- Smoke: copy `templates/harness.project.yaml` into the target before install.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `harness.project.yaml check failed` | Copy the template; set `issue_source` and `packs: [core]` |
| `refusing to overwrite non-symlink path` | Move/rename the overlay, or pass `--force`. Copy mode refreshes pack files on reinstall. |
| Hooks not firing | Confirm `.cursor/hooks.json` paths; check Cursor Hooks output; ensure scripts are executable |
| Skill not discovered | Ensure `.cursor/skills/<name>/SKILL.md` exists with `name` + `description` (symlink or real file) |
| Workflow skill missing | Nested packs install under `.cursor/skills/workflows/<name>/` |
| Optional pack skills missing | Reinstall with those names in `packs:` or `--packs` |
| HARNESS map missing | Re-run install |
| Vendor empty / dangling symlinks | Clone or pull `vendor/cursor-harness`, then reinstall |
| `night-shift fire` skips trees | Need `.cursor/night-shift/contract.md` with `status: approved` **for this item** in that worktree (foreign leftovers must be reset, not executed) |
| New worktree inherits an approved contract | Gitignore working `contract.md` / `HANDOFF.md` / `BLOCKED.md`; keep a tracked stub. Create-time setup should reset them to draft. |
| `agent` not on PATH | Install Cursor CLI; or set `executor.command` in `harness.project.yaml` |
