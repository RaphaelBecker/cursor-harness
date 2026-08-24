# Local harness overlay (example)

Copy to `.cursor/HARNESS.local.md` in the consumer project. Do **not** edit the
portable `.cursor/HARNESS.md` (it is harness-managed). Domain inventory lives here.

Agents: if this file exists, read it after `.cursor/HARNESS.md` for project-only
skills, rules, agents, and workflows.

## Domain workflows

| Name | When |
| --- | --- |
| Example | `/your-local-skill` |

## Domain skills / agents

| Name | Job |
| --- | --- |
| Example local skill | Stays in this repo; never copied into cursor-harness |

## Notes

- Use new filenames that do not collide with harness-managed packs
- MCP, plans, and product docs stay in this project
