# Automations

Scheduled **quality** jobs **without a feature plan**. The **night engine** for
features is [`runtime/night-shift`](../runtime/night-shift) (local `agent -p` in
existing worktrees). These stubs are hygiene only.

Runtime rules: [runtime policy](runtime-policy.md). Do not invent MCP server
names.

**Overflow only:** `/automate` in the Agents Window starts a **Cursor cloud
agent** (always max context; individual plans cannot target My Machines). Use
that when the laptop is off — not as install-default.

## Safety (short)

- **Draft PR allowlist:** tests, proven unused exports, autofix-safe lint, flake
  hardening with evidence.
- **Hard deny (report only):** migrations, auth, billing, secrets, broad refactors,
  high-risk domain cores the project marks locally.

Memories may improve recurring runs; they must not override the deny list.
Prefer `project_memory.md` over cloud Automations `MEMORIES.md`.

## Stubs

| Stub | Trigger | Output |
| --- | --- | --- |
| Daily test health | Weekday nightly | Draft PR if allowlisted |
| Lint hygiene | Weekday nightly | Draft PR autofix-safe |
| CI failure triage | CI failed | Diagnose; draft PR only for tests/flakes |
| Dead code hygiene | 2–3×/week | Draft PR if proven |
| Security scan | Weekly | Report only |
| Spec acceptance drift | Weekly | Report only |
| Harness + doc-routing integrity | Weekly | Report only |
| Codebase / architecture health | Weekly | Report only (`quality-audit` pack) |

Activate first: daily test health → lint hygiene → CI failure triage.

Not an automation: `/prep` (HIL workpack) and `/batch-issue-refine`
(optional github-board pack, two human gates).
