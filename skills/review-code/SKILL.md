---
name: review-code
description: >-
  Diff-scoped self code review against expert engineering principles (SOLID,
  DRY, KISS, YAGNI, cohesion/coupling, fail-fast, performance and security
  hygiene). Runs as Phase 4b of the lifecycle after the verification ladder is
  green and before Phase 5 documentation. Applies behavior-preserving fixes plus
  red-first corrections expressly covered by an approved implementation contract;
  out-of-scope behavior findings are reported. Independent bug/security pass is
  Phase 4c via /review-bugbot and /review-security (report only).
---

# Code review (Phase 4b — post-green, pre-docs)

Act as a principal engineer reviewing a colleague's change set. When used inside
the lifecycle, the verification ladder is already green — it is the safety net. The goal
is expert-level code quality: maintainable, modular, performant, scalable. Never
a whole-codebase audit.

Independent bug/security pass is **Phase 4c** via Cursor `/review-bugbot` /
`/review-security` (report only — do not auto-fix). This skill stays the fix-capable
maintainability review.

## Scope

- Review only the current change set (`git diff` against the base branch/commit),
  plus the code it directly touches (callers, callees, sibling helpers the diff
  duplicates or bypasses).
- Apply behavior-preserving fixes directly. A behavior-changing correction is
  permitted only when it fixes an introduced regression or behavior expressly
  covered by the approved contract, and only after adding or confirming
  red-first coverage.
- For standalone PR reviews (no approved contract), report findings and do not
  apply behavior-changing fixes unless the user asks.

## Principles rubric

Check the diff against each item; skip commentary on items that pass.

- **SOLID:** single responsibility, open/closed, Liskov substitution, interface
  segregation, dependency inversion.
- **DRY:** new code must not duplicate logic that already exists elsewhere in
  the codebase.
- **KISS / YAGNI:** simplest readable solution; no speculative abstraction,
  config, or flexibility for requirements that do not exist yet.
- **Architectural reuse (late safety net):** if the diff adds a capability that is a
  subset of an existing broader feature, flag parallel implementation as a **Blocker**
  when a shared module should own both. (Primary catch is `implementation-plan-review`
  Gate A — still verify the shipped diff.)
- **Lifecycle / residual state:** for create/update/delete/archive/reset diffs, confirm
  related rows and derived aggregates match the contract. Orphans and stale rollups are
  Blockers when in contract scope.
- **Structure:** high cohesion / low coupling, separation of concerns, Law of
  Demeter, composition over inheritance, small functions, guard clauses over
  deep nesting.
- **Readability:** self-documenting names that state exact purpose; comments
  explain WHY only; no dead code, no commented-out code.
- **Robustness:** fail fast with explicit errors; no silent swallowing;
  principle of least astonishment.
- **Performance hygiene:** no N+1 queries, no sequential fetch waterfalls, no
  unnecessary client bundles or re-renders.
- **Security hygiene:** input validation at system boundaries, least privilege,
  no secrets in code.
- **Boy scout rule:** leave touched files cleaner than found — including
  adjacent doc drift spotted in passing (fix the canonical doc per
  `doc-routing`).

## Process

1. Collect the diff and classify each finding:
   - **Critical / Blocker** — must fix before merge (bugs, security, data loss).
   - **Suggestion / Polish** — worth improving; fix now if behavior-preserving
     and cheap during Phase 4b.
   - **Nice to have / Backlog** — worthwhile but out of scope; note for later
     (prefer an existing backlog doc if the project has one).
2. For each finding include: location (file + symbol or line range), why it
   matters, and a concrete fix direction.
3. Apply behavior-preserving Blocker/Polish fixes directly when inside an
   approved-plan Phase 4b. Apply a behavior-changing correction only when the
   approved contract and red-first evidence authorize it.
4. Report behavior changes outside the approved contract as a hard stop or
   backlog follow-up; do not broaden scope during review.
5. Re-run the **worktree proof** after runtime-affecting fixes — not idle-main
   complete.
6. **Blast radius** (sensitive diffs only): if the allowlist or diff touches
   shared modules, lifecycle, money, auth, or wire formats, follow
   `@blast-radius`. Write the `## Blast radius` block for `HANDOFF.md`. Skip
   copy-only and docs-only changes. Do not invent a third always-on rule.
7. Output a short review summary — findings, fixes applied, backlog entries,
   blast-radius fact (or skipped) — which feeds the Phase 5 readiness
   checklist ("code review clean").
8. Remind that Phase 4c (`/review-bugbot`, optional `/review-security`) is report-only
   and runs after this skill in night shift.

## Tone

Be direct and specific. Prefer actionable comments over vague style nits. Praise
only when it clarifies a non-obvious good pattern worth repeating.
