# Contributing to cursor-harness

Keep packs small, actionable, Cursor-native, and **portable**. This harness must stay
applicable to any software project — no product names, private paths, or one-repo scripts.
Stack- or domain-specific guidance belongs in consumer local overrides, not in shared packs.

Register every new pack in `manifest.yaml` so `install.sh` can distribute it.

## Add a rule

1. Create `rules/<name>.mdc` with YAML frontmatter:

```markdown
---
description: Short description shown in the rule picker
alwaysApply: true
---

# Title

- Concrete guidance
```

For file-scoped rules, use `globs` and set `alwaysApply: false`.

2. Add the filename under `packs.rules` in `manifest.yaml`.
3. Keep the body focused (prefer under ~80 lines).

## Add a skill

1. Create `skills/<skill-name>/SKILL.md`:

```markdown
---
name: skill-name
description: Third-person description of WHAT it does and WHEN to use it.
---

# Skill Name

## Instructions
...
```

2. Optional: add `reference.md`, `examples.md`, or `scripts/` next to `SKILL.md`.
3. Add `<skill-name>` under `packs.skills` in `manifest.yaml`.
4. Keep `SKILL.md` under 500 lines; put deep detail in linked files one level deep.

## Add a hook

1. Add an executable script under `hooks/scripts/<name>.sh` (shebang + `chmod +x`).
2. Register it in `hooks/hooks.json` under the correct event (`sessionStart`, `beforeSubmitPrompt`, etc.).
3. Scripts run from the **consumer project root**; installed paths are `.cursor/hooks/<name>.sh`.
4. Read JSON from stdin; write JSON to stdout. Fail open unless the policy requires otherwise.
5. Ensure dependencies exist in the hook environment (`python3`, etc.).

`install.sh` merges harness hook entries by `command` path and preserves unrelated project hooks.

## Local overrides in consumer projects

Do **not** edit harness-managed filenames in the consumer repo if they are symlinks. Instead:

- Add a project-owned rule such as `.cursor/rules/my-app-local.mdc`
- Or copy from `templates/local-override.example.mdc`
- Extend doc maps via `templates/doc-routing.local.example.mdc`
- Seed memory via `templates/project_memory.example.md` → root `project_memory.md`

## Checklist before opening a PR

- [ ] Pack registered in `manifest.yaml`
- [ ] Rule/skill frontmatter valid
- [ ] Hook scripts executable and paths match `hooks.json`
- [ ] Docs updated if install or layout behavior changed
- [ ] `./install.sh --target /tmp/harness-smoke --mode symlink` succeeds
