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

**Context tax:** Planning loads `feature-delivery` → domain memory slice → `grill-me` →
**one** routed doc row — do not bulk-read `docs/`.

### Day → Night (features & bugs)

| You want | You do |
| --- | --- |
| New feature | New agent → `/feature-delivery` → read plan → `/implementation-plan-review` → **approve** |
| Bug fix | New agent → `/bugfix` → (same review/approve if non-trivial) |
| Refine Ready issues | New agent → `/batch-issue-refine` → you approve twice (value, then board overwrite). No code. |
| After approve | Agent runs night shift (`execute-approved-plan`): ladder → `@review-code` → `/review-bugbot` (+ `/review-security` if sensitive) → docs → **Lessons learned** + scored Candidates |
| Local ship | `/ship-local` (merge workflow → clean up-to-date local default → remove current worktree) |
| Prod ship | `/ship-prod` (local green → project ship → watch CI → fix red + Bugbot → Phase 7) |
| You ship remote | `/ship-prod`, or the project's documented push/deploy scripts if you drive it yourself |

### Everyday helpers

| You want | You do |
| --- | --- |
| See everything that exists | Open `.cursor/HARNESS.md` or `/help` |
| Shared word meaning | `/glossary` |
| Invent a new workflow | `/create-workflow` (updates HARNESS) |
| Pull lab harness into this pack | `/sync <path-to-project-or-.cursor>` |
| Flaky / slow tests | `/test-harness-optimize` |
| Doc drift | `/review-docs` (report first) |
| Nightly hygiene | Stubs in `.cursor/automations/README.md` → local `agent -p` / SDK ([runtime policy](../../docs/runtime-policy.md)) |
| Verify a change | Ask for `verifier` (report only) |

### Built-in Cursor skills we use

| When | Use |
| --- | --- |
| Day | `/feature-delivery`, `/implementation-plan-review`, `/batch-issue-refine` |
| Night quality | `@review-code` then `/review-bugbot` (+ `/review-security` when sensitive) |
| Local ship | `/ship-local` |
| Prod ship | `/ship-prod` |
| Ship / PR | `/autopilot`, `/split-to-prs`, `/loop` to watch CI/deploy |
| Night hygiene | Local `agent -p` ← stubs in automations README. `/automate` only if the laptop is off |
| Meta | `/create-skill`, `/create-rule`, `/create-hook`, `/create-subagent` |

### Rules of the road (short)

- **Day** = plan with you. **Night** = build after you approve.
- Product story first → then code → thin contracts only for high-risk seams.
- Agents do **not** remote push / deploy unless you ask. Local merge = `/ship-local` when you ask.
- Change a skill/rule/agent/workflow/automation → update `.cursor/HARNESS.md` same change.

---

If they ask “what next for my feature?”, point them at `/feature-delivery` only.
If they ask to refine Ready-column GitHub texts, point them at `/batch-issue-refine` only.
