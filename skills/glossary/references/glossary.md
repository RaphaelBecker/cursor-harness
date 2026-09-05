# Cursor harness glossary

Short shared meanings. Everyday words first. Process terms only — product vocabulary
lives in the consumer project.

## Process & software

| Term | Meaning |
| --- | --- |
| **Module** | One unit of code with a clear job and a small public surface. Hides complexity inside. |
| **Deep module** | Simple interface, rich behavior inside. Prefer this over thin pass-through wrappers. |
| **Connector** | Thin adapter that talks to an outside system (API, DB client). Not business rules. |
| **SSOT** | Single source of truth — one place that owns a fact; others read or point to it. |
| **Plan** | The one implementation SSOT for an item (worktree `.cursor/plans/<slug>.md` only). Fields live on that file. Never write `contract.md`. Never call CreatePlan (`~/.cursor/plans` is not the SSOT). |
| **kind** | Plan field: `feature` (default), `bug`, or `architecture`. Flavor of `/prep`, not a second slash. |
| **Prep** | Short HIL sitting (about 2h max, anytime): human creates Cursor worktrees; packet grill; approve the one Cursor plan. |
| **Nightshift** | Unattended execute in those trees (`night-shift fire`). Park BLOCKED.md; never wait. |
| **Packet** | All material questions at once, each with a recommended answer. |
| **Phase 4b** | Fix-capable maintainability review (`@review-code`) after a green ladder. |
| **Phase 4c** | Report-only second opinion (`/review-bugbot`, optional `/review-security`). |
| **Autonomous quality** | Scheduled **local** CLI/SDK jobs that improve tests/lint/security reports without a feature plan. Cloud `/automate` is overflow when the machine is off. |
| **Allowlist** | Files/actions the agent may change or open as draft PRs. |
| **Deny list** | Areas auto agents must not change (auth, billing, secrets, migrations, …). |
| **Harness** (Cursor Harness) | The whole agent framework: **skills**, **rules**, **subagents/agents**, **hooks**, **automations**, **workflows**, and **plans**. |
| **HARNESS.md** | `.cursor/HARNESS.md` — short inventory map of what exists in the harness. |
| **HARNESS.local.md** | Consumer-only domain inventory. Read after portable `HARNESS.md` when present. |
| **Workflow** | Named sequence of skills/agents for a job (the delivery spine, audit, ship). |
| **HIL checkpoint** | Hard stop during **prep**: the human must say yes. Nightshift does not wait. |
| **Skill** | Instructions the agent follows for a task (`SKILL.md`); often run with `/name`. |
| **Rule** | Always-on (`core-principles`, `developer-communication`) or glob-scoped guardrail (`.mdc`). |
| **Subagent** / **Agent** | Focused helper (often report-only) under `.cursor/agents/`. |
| **Hook** | Script that runs around agent actions (e.g. block destructive shell commands). |
| **Automation** | Cloud agent run on a schedule or git/CI event. |
| **Worktree proof** | Types + plan-listed suites on the feature worktree. Feature merge-ready. Empty list fails; docs/harness-only may be N/A. |
| **Idle-main complete** | One full/CI-parity gate on clean local default after lands, host idle (wait live test-pool lease, bounded). Then `/ship-prod`. |
| **Fast/local coverage slice** | Full lint/types/coverage ratchet (`test.fast` when declared). CI and part of idle-main complete. Not run on feature worktrees. |
| **Verification ladder** | Targeted RED/GREEN → one worktree proof; idle-main complete after `/ship-local` — SSOT in the `testing` rule; discovered project commands. |
| **Honest leftover** | Three targeted E2E/int runs can still fill a 3-slot pool. This split shrinks hold time; it does not make parallel E2E free. Same-machine CI still competes if someone pushes while agents test. |
| **Lessons learned** | Short session summary at Phase 5 in `HANDOFF.md`. Feeds Candidates; durable Architecture tips wait for Phase 7. Chat last line is `DONE` or `PARTIAL`. |
| **Candidates** | Scored rows in `project_memory.md` (the project summary) that may later promote into harness packs. |
| **Help count** | How often a Candidate lesson actually helped a later session. Bumped at most +1 per cycle. |
| **Staged** | Candidate that hit help/age thresholds and is ready for a human harness-promote ask. |
| **Cycle status** | Compact Phase 5 block summarizing new/helped/staged candidate counts. |
| **Night-shift CLI** | `runtime/night-shift` — discover, fire, status. Never creates worktrees. |
| **BLOCKED.md** | `.cursor/night-shift/BLOCKED.md` — unattended hard stop. Night does not ping. Gitignored working artifact. |
| **decisions.tsv** | Append-only night log (what, why, evidence pointer, result). Working artifact; do not commit. |
| **Ship local** | `/ship-local` — land a feature tree onto local default, or leftover-commit when already on default. |
| **Blast radius** | The one fact a change is safe because of, proven by running code. Unproven stays labeled unproven. |
| **Tight red loop** | One named command already run that goes red on this bug. Required before hypothesising. |
| **harness.project.yaml** | Required consumer interface (issue source, tests, optional slots, packs). |
| **Ship prod** | `/ship-prod` — classify leftovers, wait live lease, watched remote ship + CI fix + Phase 7. Chat last line `DONE`/`PARTIAL`. |
| **Exclusive lock** | One `/ship-local` at a time. `ship.lock` in YAML, or `.cursor/ship-local.lock`. |
| **Project memory** | Root `project_memory.md` summary: Architecture tips + scored Candidates (`help_count`). Not stronger than code or docs. |
