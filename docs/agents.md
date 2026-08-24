# Agents

## Portable (this pack)

| Agent | Job | File |
| --- | --- | --- |
| `verifier` | Discover and run worktree proof (types + listed suites); **report only** | [verifier.md](../agents/verifier.md) |
| `architecture-health-auditor` | Hotspots + boundary leaks; **report only** (`quality-audit`) | [architecture-health-auditor.md](../agents/architecture-health-auditor.md) |
| `supabase-architect` | SQL/RLS/view design; **report only** (`supabase`) | [supabase-architect.md](../agents/supabase-architect.md) |
| `db-schema-auditor` | Dead/orphan DB objects; **report only** (`supabase`) | [db-schema-auditor.md](../agents/db-schema-auditor.md) |

Installed to `.cursor/agents/` when listed in `manifest.yaml`. Readonly. Does not edit code.

Stack- or domain-specific agents belong in the **consumer** project (non-colliding names).

## Built-in Cursor helpers (not in this repo)

| Helper | Job |
| --- | --- |
| Bugbot (`/review-bugbot`) | Phase 4c bug pass — **report only**, do not auto-fix |
| Security Review (`/review-security`) | Phase 4c when auth, access, billing, admin, or secrets |
| `ci-investigator` | Short root-cause summary of one failed CI check |
| `explore` | Fast codebase map (used during grill / architecture audit) |

Consumer pointer file: copy [templates/AGENTS.md](../templates/AGENTS.md) with
`install.sh --with-agents` if the project has no root `AGENTS.md`.
