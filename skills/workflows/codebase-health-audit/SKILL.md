---
name: codebase-health-audit
disable-model-invocation: true
description: >-
  Whole-repo architecture and codebase health scorecard. Report-only by
  default. Delegates to existing CI/agent gates; computes git hotspots and
  new layer/cycle leaks. Use when the developer asks for codebase health,
  hotspots, circular deps, or module-boundary leaks.
---

# Codebase health audit

Thin orchestrator. Whole-repo pass. Diff-scoped Phase 4b stays `@review-code`.

**Default: report only.** Same hard deny as automations README (migrations,
auth, billing, secrets, high-risk domain cores). Fix only under an approved
allowlist.

## Prep

1. Read [references/pillar-map.md](references/pillar-map.md).
2. Read **one** routed architecture/layering doc — do not bulk-read `docs/`.
3. Cite recent worktree-proof / idle-main-complete evidence if present. Else
   cheap signals only (lint count; dead-code tool only if asked; `npm audit`
   only when SCA is in scope). Never invent new CI blockers.
4. Delegate `architecture-health-auditor` for `@audit-hotspots` +
   `@audit-module-boundaries`. If that subagent is unavailable, run those two
   skills in-process. Also run core `@architecture-audit` when installed.
5. Emit a short scorecard: pillar | existing gate | gap finding | severity.

## Nightshift

Only after an approved contract with an allowlist. Do not auto-fix from a
weekly stub.
