# Contributing to cursor-harness

Keep packs small, actionable, Cursor-native, and **portable**. This harness must stay
applicable to any software project — no product names, private paths, or one-repo scripts.
Stack- or domain-specific guidance belongs in consumer local overrides and
`harness.project.yaml`, not in shared packs.

Register every new pack in `manifest.yaml` `pack_sets` so `install.sh` can distribute it, and update
root [`HARNESS.md`](HARNESS.md) in the same change. Add a **one-line catalog row** in the
matching file under [`docs/`](docs/) (`rules.md`, `skills.md`, `agents.md`, `hooks.md`,
`automations.md`). If you add a **workflow**, also add a short section to
[`README.md`](README.md#workflows) — do not paste skill steps into the README.

## README flowcharts

Workflow diagrams in [`README.md`](README.md) use a locked mermaid theme so GitHub
light/dark and screenshots stay consistent. Copy this block.

Dark slate canvas. **One hue per role** — do not rainbow every node. Unused palette
colors (pink, lime, neon purple) stay off the charts.

Every node uses the same cool-grey border. Role is the **fill** only. Keep fills
mid-tone so `#E8EEF7` text stays readable — no gradients.

| Role | Fill / token | Meaning |
| --- | --- | --- |
| Canvas | `#2B313C` | Chart background |
| Lines / secondary text | `#9AA6B8` | Arrows, edge labels |
| Primary text | `#E8EEF7` | Node titles and body |
| Border (all nodes) | `#A8B4C4` | Shared stroke on every shape |
| Skill | `#3A5F9A` | Playbook / work |
| HIL / decision | `#A34D16` | You decide (diamond) — orange |
| Done | `#2A6B5C` | Arrival / ship |
| Drop | `#7A3D4A` | Stop |
| Proposed | `#4A4578` dashed | Not installed |
| You / system | `#3D4554` | Neutral machine step |
| Mark · skill | `#4C8DFF` | Legend / icon accent |
| Mark · HIL | `#F5A524` | Legend / icon accent |
| Mark · subagent | `#22C7E0` | Legend / icon accent |
| Mark · rule | `#A8B4C4` | Legend / icon accent |

Overview rows: `fontSize` 17px. Zoom-ins: `fontSize` 15px. Bold the node title; do
not underline. Done / start nodes use stadium `([])`. HIL decisions use diamond
`{}`. Do **not** wrap a chart in a mermaid subgraph — GitHub draws a box around it.
Keep the key **out** of the mermaid block. Put this key under the closing fence
(bottom-left of the chart). GitHub strips inline CSS — color lives in the chips
(`docs/assets/legend-*.svg`):

```
![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)
```

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  example["<b>Title</b><br/>✦ skill-name"]
  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef drop fill:#7A3D4A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef you fill:#3D4554,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef proposed fill:#4A4578,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7,stroke-dasharray:6 4
  class example skill
```

Canvas `#2B313C`. Icons: skill `#4C8DFF`, HIL `#F5A524`, rule `#A8B4C4`,
subagent `#22C7E0`.

## Add a rule

1. Create `rules/<name>.mdc` with YAML frontmatter:

```markdown
---
description: Short description shown in the rule picker
alwaysApply: true   # only for core-principles / developer-communication; else globs + false
---

# Title

- Concrete guidance
```

For file-scoped rules, use `globs` and set `alwaysApply: false`.

2. Add the filename under the right `pack_sets.<name>.rules` list in `manifest.yaml`.
3. Add a one-line entry under Rules in `HARNESS.md`.
4. Keep the body focused (prefer under ~80 lines).

## Sync from a live project lab

When harness process is developed inside a real project’s `.cursor/`, run **`/sync`**
(skill: `skills/sync/`) in this repo. It diffs the lab, ports generalizable packs,
strips product leaks, updates `manifest.yaml` + `HARNESS.md`, and smoke-installs.
Pass the lab path: `/sync /path/to/project` or `/sync /path/to/project/.cursor`.

## Add a skill

1. Create `skills/<skill-name>/SKILL.md` (workflows under `skills/workflows/<name>/`):

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
3. Add `<skill-name>` (or `workflows/<name>`) under the right `pack_sets.<name>.skills` list in `manifest.yaml`.
4. Add a one-line entry in `HARNESS.md`.
5. Keep `SKILL.md` under 500 lines; put deep detail in linked files one level deep.
6. Write for agents (see `create-workflow`): sharp `description` pointer,
   completion criteria on steps, prompt the positive, one meaning in one
   place, prune no-ops. Do not restate always-on rules.

## Add an agent

1. Create `agents/<name>.md` with YAML frontmatter (`name`, `description`, `model`, optional
   `readonly`).
2. Keep the agent portable: discover project commands; no product paths or one-repo scripts.
3. Register under `packs.agents` in `manifest.yaml` and list it in `HARNESS.md`.

## Add an automation stub

1. Edit `automations/README.md` with trigger, output, and prompt idea.
2. Keep draft-PR allowlist / hard deny generic.
3. Ensure `packs.automations: true` in `manifest.yaml` and update `HARNESS.md`.

## Add a hook

1. Add an executable script under `hooks/scripts/<name>.sh` (shebang + `chmod +x`).
2. Register it in `hooks/hooks.json` under the correct event (`sessionStart`, `beforeSubmitPrompt`, etc.).
3. Scripts run from the **consumer project root**; installed paths are `.cursor/hooks/<name>.sh`.
4. Read JSON from stdin; write JSON to stdout. Fail open unless the policy requires otherwise.
5. Ensure dependencies exist in the hook environment (`python3`, etc.).
6. Update the Hooks section in `HARNESS.md`.

`install.sh` merges harness hook entries by `command` path and preserves unrelated project hooks.

## Local overrides in consumer projects

Do **not** edit harness-managed filenames in the consumer repo if they are symlinks. Instead:

- Seed `harness.project.yaml` from `templates/harness.project.yaml` (required)
- Add a project-owned rule such as `.cursor/rules/my-app-local.mdc`
- Or copy from `templates/local-override.example.mdc`
- Extend doc maps via `templates/doc-routing.local.example.mdc`
- Seed memory via `templates/project_memory.example.md` → root `project_memory.md`
- Copy `templates/batch-issue-refine.local.example.md` → `.cursor/batch-issue-refine.local.md` for Ready-column project number, column name, and notes path
- Add domain agents/MCP/autofix under the consumer `.cursor/` (non-colliding names)
- Optionally append local rows to a project-owned harness note; do not rewrite portable `HARNESS.md` content in place if it is a symlink — prefer a local companion doc or override

## Checklist before opening a PR

- [ ] Pack registered in `manifest.yaml` `pack_sets`
- [ ] `HARNESS.md` updated
- [ ] Matching `docs/` catalog row (and README workflow section if it is a workflow; mermaid uses the README flowchart theme)
- [ ] Rule/skill/agent frontmatter valid
- [ ] No product names, private paths, or one-repo scripts in shared packs
- [ ] Hook scripts executable and paths match `hooks.json`
- [ ] Docs updated if install or layout behavior changed
- [ ] `mkdir -p /tmp/harness-smoke && cp templates/harness.project.yaml /tmp/harness-smoke/ && ./install.sh --target /tmp/harness-smoke --mode symlink --with-agents` succeeds
