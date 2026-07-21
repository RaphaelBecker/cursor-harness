# Install guide

## Requirements

- `bash`
- `python3` (stdlib only)
- `git` (submodule workflow)

## Submodule install

```bash
# from the consumer project root
git submodule add git@github.com:RaphaelBecker/cursor-harness.git vendor/cursor-harness
./vendor/cursor-harness/install.sh --target . --mode symlink --with-agents
git add .gitmodules vendor/cursor-harness .cursor AGENTS.md
git commit -m "Add cursor-harness"
```

HTTPS remote alternative:

```bash
git submodule add https://github.com/RaphaelBecker/cursor-harness.git vendor/cursor-harness
```

## install.sh flags

| Flag | Description |
|------|-------------|
| `--target <path>` | Project root (default: parent of `vendor/cursor-harness`, else cwd) |
| `--mode symlink\|copy` | Link or copy packs (default: `symlink`) |
| `--force` | Replace existing non-symlink harness destinations |
| `--with-agents` | Copy `templates/AGENTS.md` if project root has none |
| `--dry-run` | Print actions only |

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

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `refusing to overwrite non-symlink path` | Happens in symlink mode when a real file replaced a harness link — move/rename it, or pass `--force`. Copy mode refreshes pack files on reinstall. |
| Hooks not firing | Confirm `.cursor/hooks.json` paths; check Cursor Hooks output; ensure scripts are executable |
| Skill not discovered | Ensure `.cursor/skills/<name>/SKILL.md` exists with `name` + `description` |
| Submodule empty | `git submodule update --init --recursive` |
