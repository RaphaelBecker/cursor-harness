# Health audit pillars

Discover local gates from README / CI / `harness.project.yaml`. Do not hardcode
another project's script names.

| Pillar | Typical existing gate | This workflow adds |
| --- | --- | --- |
| Modularity | Layering doc + core `architecture-audit` | `audit-module-boundaries` new leaks |
| Hotspots | None by default | `audit-hotspots` churn × size |
| Tests | Worktree proof / idle-main complete | Cite recent evidence; do not re-run full CI |
| Security | `npm audit` / SAST in CI | Report only; no new scanners |
| Dead code | Project dead-code tool when present | Only if asked |
| Process | HARNESS map + doc-routing | Flag packs not in HARNESS / HARNESS.local |

Suggested next contracts: one smell → `/prep` with `kind: architecture`, or one
hotspot extract — never a whole-repo rewrite.
