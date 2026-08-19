# Runtime policy

**As of 18 Aug 2026.** Cursor keeps shipping hosted surfaces (cloud VMs,
Automations, Origin). This pack stays **local-first**: inference is billed by
Cursor; **tools, tests, and git checkouts run on the developer machine**.

Normative day/night contract: [core-principles](../rules/core-principles.mdc).
Night checklist: [`execute-approved-plan`](../skills/execute-approved-plan/SKILL.md).
Hygiene prompts: [automations](automations.md).

## The split

| Layer | Who owns it |
| --- | --- |
| Model / agent loop | Cursor (usage pools: Cursor Models vs Other Models) |
| Files, shell, tests, local DBs, worktrees | This machine |
| Merge, remote push, production | Human (`/ship-local`, `/ship-prod`) |

You cannot host the model. You **can** refuse Cursor VMs as the default executor
so a night shift uses idle CPU instead of cloud minutes.

Prefer **Composer 2.5** or **Grok 4.6** (first-party pool) for long unattended
runs. Parallelism is the number of **human-created** worktrees with an approved
contract — bound by this machine, not a harness cap. About **3** has been
comfortable on a laptop (reference only). If the project sets `slots` in
`harness.project.yaml`, wait for a lease; do not skip tests. Do not spawn a
cloud fleet “because Cursor can.”

## Allowed (local)

| Surface | How to use it |
| --- | --- |
| IDE agent in a human-created worktree | Prep plan + Nightshift execute after contract approval |
| Cursor CLI `agent -p` (no `&` cloud handoff) | `runtime/night-shift fire`; loads `.cursor/` skills, hooks, subagents |
| SDK **local** runtime (`local: { cwd }`) | Same harness from a script; `Agent.resume` across process boundaries |
| `/loop` | Recurring ticks **inside an existing local session** (CI watch, hygiene) |
| `/review-bugbot` / `/review-security` | Phase 4c at handoff, **report-only** — not on every PR event |
| `.cursor/worktrees.json` | Optional setup commands when Cursor creates a worktree. Agents still must not create/switch worktrees except `/ship-local` |

Example night kick (approved contract already in the worktree):

```bash
./vendor/cursor-harness/runtime/night-shift fire
# equivalent one tree:
agent -p "@execute-approved-plan" --model composer-2.5
```

Schedule with the shipped [launchd example](../templates/launchd/com.cursor-harness.night-shift.plist.example)
or cron on **this machine**. Do not prepend `&` to `agent` (that hands the job to a
Cloud Agent). The CLI still starts **local** child processes without passing `&`.

## Leash (overflow only)

| Surface | When |
| --- | --- |
| Cloud Agents + Builds | Laptop is **off** (travel). Spend cap on. Not the nightly default. |
| My Machines (`agent worker start`) | Mac is already on and you want Slack/GitHub `@cursor worker=<name>` to hit local tests. Individual Automations **cannot** target this worker. |
| Mobile Inbox / iPad | Review artifacts. Do not spawn fleets from the couch. |
| Marketplace plugins | Install a named tool you need. Do not replace this submodule with Marketplace packs. |

## Forbidden (this pack’s goals)

| Surface | Why |
| --- | --- |
| Cursor Automations as the night engine | Always a Cursor VM; always max context; billed as cloud agents. Individual plans cannot bind them to My Machines. |
| Origin as git host (or a second SSOT next to GitHub) | New forge (17 Aug 2026, early beta). CI apps (Vercel, Depot, Buildkite) are another runner ecosystem. Keep GitHub for issues/PRs. |
| Self-hosted Cloud Agent pool | Enterprise fleet. Not a personal night-shift product. |
| Bugbot Automation on every PR | Usage-based (~$1–$1.50/run). Keep it gated at Phase 4c. |

Prompt stubs in [`automations/`](../automations/README.md) stay **prompt text**
for a local CLI/SDK job. Creating a live job in the Agents Window with
`/automate` is an explicit overflow opt-in, not install-default.

## Sources (dated)

- [Origin changelog](https://cursor.com/changelog/origin-code-hosting) — 17 Aug 2026
- [Cloud Agent Builds](https://cursor.com/changelog/08-13-26) — 13 Aug 2026
- [Automations 3.8](https://cursor.com/changelog/06-18-26) — 18 Jun 2026
- [SDK public beta](https://cursor.com/changelog/sdk-release) — 29 Apr 2026
- [Usage limits](https://cursor.com/help/models-and-usage/usage-limits.md)
- [My Machines](https://cursor.com/docs/cloud-agent/self-hosted-guides/my-machines)
- [Automations billing](https://cursor.com/docs/cloud-agent/automations.md)
