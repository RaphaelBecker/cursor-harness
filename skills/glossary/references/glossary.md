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
| **Contract** | Approved plan for what to build: allowlist, acceptance, tests, hard stops. |
| **Day shift** | Planning with the human: grill → plan → plan review → approve. No big coding yet. |
| **Night shift** | After approval: implement, test, docs, handoff. No merge/push/deploy unless asked. |
| **Phase 4b** | Fix-capable maintainability review (`@review-code`) after a green ladder. |
| **Phase 4c** | Report-only second opinion (`/review-bugbot`, optional `/review-security`). |
| **Autonomous quality** | Scheduled cloud agents that improve tests/lint/security reports without a feature plan. |
| **Allowlist** | Files/actions the agent may change or open as draft PRs. |
| **Deny list** | Areas auto agents must not change (auth, billing, secrets, migrations, …). |
| **Harness** (Cursor Harness) | The whole agent framework: **skills**, **rules**, **subagents/agents**, **hooks**, **automations**, **workflows**, and **plans**. |
| **HARNESS.md** | `.cursor/HARNESS.md` — short inventory map of what exists in the harness. |
| **Workflow** | Named sequence of skills/agents for a job (feature, bug, audit, ship). |
| **HIL checkpoint** | Hard stop: the agent waits for an explicit human yes before the next step. |
| **Batch issue refine** | Day workflow (`/batch-issue-refine`): validate and rewrite a Ready-column GitHub batch. No implementation. |
| **Skill** | Instructions the agent follows for a task (`SKILL.md`); often run with `/name`. |
| **Rule** | Always-on or file-scoped guardrail (`.mdc`). |
| **Subagent** / **Agent** | Focused helper (often report-only) under `.cursor/agents/`. |
| **Hook** | Script that runs around agent actions (e.g. block destructive shell commands). |
| **Automation** | Cloud agent run on a schedule or git/CI event. |
| **Plan** | Draft or approved implementation plan (often under `.cursor/plans/`). |
| **Verification ladder** | Targeted tests → fast/local gate → full/CI-parity gate (then rerun failing only, then confirm) — SSOT in the `testing` rule; discovered project commands. |
| **Lessons learned** | Short session summary at Phase 5 handoff. Feeds Candidates; durable Architecture tips wait for Phase 7. |
| **Candidates** | Scored rows in `project_memory.md` (the project summary) that may later promote into harness packs. |
| **Help count** | How often a Candidate lesson actually helped a later session. Bumped at most +1 per cycle. |
| **Staged** | Candidate that hit help/age thresholds and is ready for a human harness-promote ask. |
| **Cycle status** | Compact Phase 5 block summarizing new/helped/staged candidate counts. |
| **Ship local** | `/ship-local` — human-triggered reliable merge onto clean local default branch + current worktree cleanup (no remote push). |
| **Ship prod** | `/ship-prod` — human-triggered watched remote ship + CI fix + Phase 7. |
| **Project memory** | Root `project_memory.md` summary: Architecture tips + scored Candidates (`help_count`). Not stronger than code or docs. |
