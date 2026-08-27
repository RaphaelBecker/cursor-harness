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
**Map:** [`.cursor/HARNESS.md`](../../HARNESS.md) · **Domain overlay:** `.cursor/HARNESS.local.md` when present  
**Terms:** `/glossary` · **Project file:** `harness.project.yaml`

**Context tax:** Always-on = `core-principles` + `developer-communication`. Prep
loads `prep` → memory slice → packet `grill-me` → **one** routed doc.

### Delivery (one path)

| You want | You type |
| --- | --- |
| Build anything | `/prep` → `/implementation-plan-review` → Cursor Build (or `/night-shift`) → `/ship-local` (worktree) or `/ship-prod` (already on default) |
| Fire / status | `/night-shift` (optional; Build in the prep chat is enough for one tree) |
| Cheat sheet | `/help` |

Flavor is contract `kind` (`feature` / `bug` / `architecture`), not a second slash.
Agents that hear “new feature” point at `/prep` only.

### Side paths (not delivery)

| You want | You type |
| --- | --- |
| See everything that exists | Open `.cursor/HARNESS.md` or `/help` |
| Shared word meaning | `/glossary` |
| Invent a new workflow | `/create-workflow` (updates HARNESS) |
| Pull lab harness into this pack | `/sync <path-to-project-or-.cursor>` |
| Flaky / slow tests | `/test-harness-optimize` |
| Architecture report | `/architecture-audit` (no edits) |
| Whole-repo scorecard | `/codebase-health-audit` (`quality-audit` pack) |
| Doc drift | `/review-docs` (report first) |
| Hygiene jobs | Stubs in `.cursor/automations/README.md` — not Nightshift |
| Verify a change | Ask for `verifier` (report only) |
| Last message unclear | `/wait-what` |
| What else could this break | `/blast-radius` |

### Rules of the road (short)

- **Prep** = short HIL sitting, anytime. **Nightshift** = unattended build in those trees
  (`/night-shift` fire) **or** Cursor Build in the prep chat — same skill.
- Humans create worktrees. Agents and `night-shift` never run `git worktree add`.
- New trees start with a draft `contract.md` (gitignore + create-time reset). Never sidecar.
- Chat after implement/ship ends with `DONE` or `PARTIAL: <exact leftover>`.
- Product story first → then code → thin contracts only for high-risk seams.
- Feature tree: **worktree proof**. Idle local main after lands: **idle-main complete**.
- Complete red + isolate red → `@diagnose-bug` + `/review-bugbot`, then re-prove. Not a flake STOP.
- Unattended hard stop = `.cursor/night-shift/BLOCKED.md`, not a ping.
- Change a skill/rule/agent/workflow/automation → update `.cursor/HARNESS.md` same change (domain extras → `.cursor/HARNESS.local.md`).

---

If they ask “what next for the workpack?”, point them at `/prep` only.
