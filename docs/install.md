# Install guide

Workflows: [README.md](../README.md#workflows). Pack catalogs: [docs/](.).
Interface: [templates/harness.project.yaml](../templates/harness.project.yaml).

## Requirements

- `bash`
- `python3` (stdlib only)
- `git` (submodule workflow)
- Cursor CLI `agent` on PATH for `night-shift fire` (not required merely to install)

## Submodule install

```bash
# from the consumer project root
git submodule add git@github.com:RaphaelBecker/cursor-harness.git vendor/cursor-harness
cp vendor/cursor-harness/templates/harness.project.yaml harness.project.yaml
# edit issue_source / packs as needed
./vendor/cursor-harness/install.sh --target . --mode symlink --with-agents
git add .gitmodules vendor/cursor-harness .cursor AGENTS.md harness.project.yaml
git commit -m "Add cursor-harness"
```

`--init` copies the YAML if missing. Install **fails closed** without a valid
`harness.project.yaml` (unless `--no-check`).

HTTPS remote alternative:

```bash
git submodule add https://github.com/RaphaelBecker/cursor-harness.git vendor/cursor-harness
```

## What gets installed

| Source | Destination |
|--------|-------------|
| `HARNESS.md` | `.cursor/HARNESS.md` |
| selected `rules/*.mdc` | `.cursor/rules/` |
| selected `skills/**` | `.cursor/skills/` (including `workflows/`) |
| `agents/*.md` | `.cursor/agents/` |
| `automations/` | `.cursor/automations/` |
| `hooks/scripts/*` + merge `hooks.json` | `.cursor/hooks/` + `.cursor/hooks.json` |
| `templates/AGENTS.md` (optional) | project root `AGENTS.md` |

Not installed (run from the submodule): `runtime/night-shift`,
`runtime/log-decision`.

Default pack set is **`core`**. Optional: `github-board`, `market-ux`, `bdd`.

## install.sh flags

| Flag | Description |
|------|-------------|
| `--target <path>` | Project root (default: parent of `vendor/cursor-harness`, else cwd) |
| `--mode symlink\|copy` | Link or copy packs (default: `symlink`) |
| `--packs <list>` | `core`, `github-board`, `market-ux`, `bdd`, or `all`. Default: YAML `packs:` |
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

## Update flow

```bash
git submodule update --remote vendor/cursor-harness
./vendor/cursor-harness/install.sh --target .
git add vendor/cursor-harness .cursor
git commit -m "Update cursor-harness"
```

## Clone a project that already vendors the harness

```bash
git clone --recurse-submodules <your-project-url>
# or after a normal clone:
git submodule update --init --recursive
./vendor/cursor-harness/install.sh --target .
```

If the project committed symlinks, reinstall is only needed after harness updates or when switching to `--mode copy`.

## CI notes

- Prefer `--mode copy` when runners or packaging steps do not preserve symlinks.
- Re-run install after submodule checkout in CI if `.cursor/` is not committed.
- Hook scripts need `python3` on `PATH` in developer environments (hooks run locally in Cursor, not necessarily in CI).
- Smoke: copy `templates/harness.project.yaml` into the target before install.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `harness.project.yaml check failed` | Copy the template; set `issue_source` and `packs: [core]` |
| `refusing to overwrite non-symlink path` | Happens in symlink mode when a real file replaced a harness link — move/rename it, or pass `--force`. Copy mode refreshes pack files on reinstall. |
| Hooks not firing | Confirm `.cursor/hooks.json` paths; check Cursor Hooks output; ensure scripts are executable |
| Skill not discovered | Ensure `.cursor/skills/<name>/SKILL.md` exists with `name` + `description` |
| Workflow skill missing | Nested packs install under `.cursor/skills/workflows/<name>/` |
| Optional GitHub skills missing | Reinstall with `--packs core,github-board` (and `market-ux` if you want value gates) |
| Batch issue refine asks for config | Copy `templates/batch-issue-refine.local.example.md` to `.cursor/batch-issue-refine.local.md` |
| HARNESS map missing | Re-run install |
| Submodule empty | `git submodule update --init --recursive` |
| `night-shift fire` skips trees | Need `.cursor/night-shift/contract.md` with `status: approved` in that worktree |
| `agent` not on PATH | Install Cursor CLI; or set `executor.command` in `harness.project.yaml` |
