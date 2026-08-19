---
name: help
description: >-
  Compact developer cheat sheet for the portable Cursor harness. Use when the
  developer runs /help, asks what they can do with skills/rules/workflows, or
  needs a quick “how do I start” map.
disable-model-invocation: true
---

# /help — harness cheat sheet

When invoked, reply with **only** the cheat sheet below (plain words). Do not
expand into a tutorial unless the developer asks a follow-up.

Paste this content (keep it compact):

---

## Cursor harness — cheat sheet

**Harness** = skills + rules + subagents + hooks + automations + workflows + plans.  
**Map:** [`.cursor/HARNESS.md`](../../HARNESS.md) · **Terms:** `/glossary`  
**Project file:** `harness.project.yaml`

**Context tax:** Always-on = `core-principles` + `developer-communication`. Prep
loads `prep` → memory slice → packet `grill-me` → **one** routed doc.

### Stages (not a clock)

| You want | You do |
| --- | --- |
| Prep (anytime, ~2h max) | You create Cursor worktrees. `/prep` → read packets → `/implementation-plan-review` → **approve** |
| Fire Nightshift | `./vendor/cursor-harness/runtime/night-shift fire` (or `/night-shift`) |
| After Nightshift | `night-shift status` (skim `decisions.tsv`) → manual tests → `/ship-local` → `/ship-prod` |
| One feature in an existing tree | `/feature-delivery` (during prep) |
| Bug in an existing tree | `/bugfix` (during prep) |
| One module smell | `/architecture-improve` |
| Refine Ready issues | `/batch-issue-refine` if `github-board` pack is installed. No code. |

### Everyday helpers

| You want | You do |
| --- | --- |
| See everything that exists | Open `.cursor/HARNESS.md` or `/help` |
| Shared word meaning | `/glossary` |
| Invent a new workflow | `/create-workflow` (updates HARNESS) |
| Pull lab harness into this pack | `/sync <path-to-project-or-.cursor>` |
| Flaky / slow tests | `/test-harness-optimize` |
| Doc drift | `/review-docs` (report first) |
| Hygiene jobs | Stubs in `.cursor/automations/README.md` — not Nightshift |
| Verify a change | Ask for `verifier` (report only) |
| Last message unclear | `/wait-what` |
| What else could this break | `/blast-radius` |

### Rules of the road (short)

- **Prep** = short HIL sitting, anytime. **Nightshift** = unattended build in those trees.
- Humans create worktrees. Agents and `night-shift` never run `git worktree add`.
- Product story first → then code → thin contracts only for high-risk seams.
- Unattended hard stop = `.cursor/night-shift/BLOCKED.md`, not a ping.
- Change a skill/rule/agent/workflow/automation → update `.cursor/HARNESS.md` same change.

---

If they ask “what next for the workpack?”, point them at `/prep` only.
If they ask to refine Ready-column GitHub texts, point them at `/batch-issue-refine` only
when that pack is installed.
