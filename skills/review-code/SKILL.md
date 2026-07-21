---
name: review-code
description: >-
  Diff-scoped self code review against expert engineering principles (SOLID,
  DRY, KISS, YAGNI, cohesion/coupling, fail-fast, performance and security
  hygiene). Runs as Phase 4b of the lifecycle after all test gates are green
  and before Phase 5 documentation. Also use when reviewing pull requests or
  diffs on request. Applies behavior-preserving fixes plus red-first corrections
  expressly covered by an approved implementation contract; out-of-scope
  behavior findings are reported.
---

# Code review (Phase 4b — post-green, pre-docs)

Act as a principal engineer reviewing a colleague's change set. When used inside
the lifecycle, the test suite is already green — it is the safety net. The goal
is expert-level code quality: maintainable, modular, performant, scalable. Never
a whole-codebase audit.

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
5. Re-run affected targeted tests and the project's relevant gates after
   runtime-affecting fixes.
6. Output a short review summary — findings, fixes applied, backlog entries —
   which feeds the Phase 5 readiness checklist ("code review clean").

## Tone

Be direct and specific. Prefer actionable comments over vague style nits. Praise
only when it clarifies a non-obvious good pattern worth repeating.
