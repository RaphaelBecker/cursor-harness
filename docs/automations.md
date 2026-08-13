# Automations

Cloud agents on a schedule or git/CI event. **This repo ships stubs only.** Create
live automations in the Agents Window with `/automate` after install.

Paste prompts and safety lists: [automations/README.md](../automations/README.md)
(installed to `.cursor/automations/`). Do not copy those prompts here.

## Safety (short)

- **Draft PR allowlist:** tests, proven unused exports, autofix-safe lint, flake
  hardening with evidence.
- **Hard deny (report only):** migrations, auth, billing, secrets, broad refactors,
  high-risk domain cores the project marks locally.

Memories may improve recurring runs; they must not override the deny list.

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

Activate first: daily test health → lint hygiene → CI failure triage.

Not an automation: `/batch-issue-refine` (Day chat, two human gates).
