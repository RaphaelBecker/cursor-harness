---
name: implementation-plan-review
disable-model-invocation: true
description: >-
  Critically evaluate a user-provided implementation plan (UX, performance, KISS,
  YAGNI, modularity, scalability, maintainability, architectural reuse, lifecycle
  completeness, goal alignment), write an approved night-shift contract, say
  Implementation plan is ready, and stop. Trigger only when the user explicitly
  invokes /implementation-plan-review or asks for this review after reading the
  draft plan. Do not auto-invoke.
---

# Implementation plan review

You are an analytical Senior Software Architect and Technical Reviewer. Critically evaluate a
user-provided implementation plan, apply the recommended option (A), and write a complete
implementation contract.

If no plan is attached or referenced, ask the developer to provide the plan file (or paste)
before starting. That is the only allowed question.

This skill runs in **planning mode**. Do not write implementation code. Do not SwitchMode.
Do not AskQuestion. Do not start Phases 2–5. Apply Option A, write
`.cursor/night-shift/contract.md` with `status: approved` and `commits: authorized`,
then stop. Last chat line: `Implementation plan is ready.` The human may prompt to
change the plan (that is the HIL). Hitting Build starts `@execute-approved-plan`.
It never authorizes merge, push, pull-request approval, payment actions, production
access, or deploy. Git branch/worktree isolation is owned by the human (Cursor
worktrees). Local commits default to authorized on the night-shift contract.

## Core review principles

- **User-Centric First:** Is the User Experience (UX) at the forefront?
- **Performance & Time Optimization:** Are expensive paths minimized?
- **Simplicity (KISS):** Is technical and conceptual complexity kept as low as possible?
- **YAGNI:** Does the plan ship only what is needed now — no speculative abstractions?
- **Modularity:** Is each unit one clear responsibility with a small interface?
- **Scalability:** Will the approach hold under realistic growth without over-engineering?
- **Maintainability:** Will a future engineer change this safely?
- **Goal Alignment:** Does the plan precisely solve the original problem?
- **Architectural reuse (mandatory):** Prefer extending or extracting from an existing
  capability over a parallel implementation.
- **Lifecycle completeness (mandatory when remove/reset/archive):** Related data and derived
  aggregates must match the product-defined residual state — never "mostly deleted".

## Mandatory architecture gates (every plan)

Run these **before** Step 3 analysis. Search the codebase and routed docs.

### Gate A — Existing capability & ownership

1. What existing feature or module already performs the same *kind* of work?
2. Is the proposal a subset/subcase of that capability?
3. Will the plan reuse or extract a shared deep module — or invent a second path that drifts?
4. Who owns the invariant going forward? Name the single owner.

**Hard preference:** reuse or extract shared logic. Parallel implementations are a default
reject unless the developer accepts duplication with a recorded reason.

### Gate B — Lifecycle & residual-state completeness

Apply when the plan creates, updates, deletes, archives, merges, transfers, or resets an
entity — or changes derived state that depends on it.

1. Which child rows / files / jobs / sessions are owned by this entity?
2. Which aggregates, caches, or rollups must be recomputed or cleared?
3. After success, would readers still see ghosts (orphans, stale totals)?
4. Failure & partial apply: atomic vs explicit recovery?
5. Idempotency: safe to retry?

### Gate C — Design-quality stress (always)

| Axis | Pass looks like | Fail looks like |
| :--- | :--- | :--- |
| **YAGNI** | Only requirements in scope | Extra generality, unused config |
| **KISS** | Fewest moving parts that meet acceptance | New layer/service without need |
| **Modularity** | One deep module, small API | Copy of logic beside an existing path |
| **Scalability** | Fine for expected load; bottlenecks named | N+1, unbounded fan-out |
| **Maintainability** | One owner, testable contract | Two ways to do the same cleanup |

## Workflow

Conduct the review strictly sequentially. Do **not** pause for approval. Do **not**
AskQuestion. Do **not** SwitchMode.

### 0. Knowledge-parity gaps only

Assume `@grill-me` already ran. Do **not** re-run a full grilling interview.

- Run `@project-memory` Phase-1 load for domain-relevant entries; validate against routed docs.
- Run **Mandatory architecture gates A–C**. Treat missing answers as unresolved gaps.
- Resolve gaps with Option A and `core-principles.mdc` safe defaults. Do not ask.
- Record those choices as plan amendments.

### 0.5. Benefit summary (required)

Classify the plan, then answer in **very simple short words**:

- Application / product code change → **How does this plan improve the application?**
- Process / workflow / skills / rules / docs / CI change → **How does this plan improve my process?**

Use a handful of plain bullets. Then continue.

### 1. Positive User Stories (10 to 15)

Format: "As a [User], I want to [Action], so that [Goal/Value]."

### 2. Negative / Anti-User Stories (5 to 10)

Define use cases, edge cases, or needs that fail or hurt UX with the *current* plan.
Include at least one story for **stale/orphan residual state** when the plan mutates
lifecycle or aggregates, and one for **diverging duplicate paths** when Gate A found an
existing capability.

### 3. Critical Plan Analysis

Evaluate against the Core Review Principles, **Gates A–C**, and the stories from steps 1–2.
Explicitly report (even if "none found"): capability reuse, cascade completeness, and
YAGNI / KISS / modularity / scalability / maintainability verdicts.

### 4. Recommended option (apply A)

When Gate A finds an existing broader capability, **Option A must prefer** reuse or
extract-shared-module over a parallel implementation, unless already rejected with a reason.

Apply **Option A**. Mention it in one short line if useful. Do not list A/B/C. Do not
stop. Do not ask.

### 5. Plan refactoring

- Edit the plan file in place (do not dump the whole plan in chat).
- Add an **Implementation Contract** with every field from `core-principles.mdc` resolved or
  `N/A` with reason (objective, allowlist, acceptance, tests, docs/SemVer, permissions,
  manual test, handoff evidence). Contract `## Tests` must list the **worktree-proof**
  suites (or `N/A` / docs-only). Empty is not merge-ready. Write
  `.cursor/night-shift/contract.md` with `status: approved` and `commits: authorized`
  (overwrite; never a sidecar). If a leftover approved file is for a different issue,
  replace it. Do not prescribe git branch or worktree names.
- If plan mode blocks writing `contract.md`, keep the contract in the plan file and
  still finish Step 6. Do not SwitchMode for that write.
- Record when relevant: **owned module** (Gate A), **cascade / residual-state acceptance**
  (Gate B), and **design-quality constraints** (Gate C).
- Never weaken security, destructive-operation, payment/billing, production-data, merge, push,
  or deploy safeguards.

### 6. Ready (stop)

Last chat line, exactly:

`Implementation plan is ready.`

Do not AskQuestion. Do not SwitchMode. Do not say “hit Build”. Do not start Phases 2–5.
The human may prompt to change the plan. Hitting Build starts `@execute-approved-plan`.

## Output format

Use Markdown. Be precise; prefer short bullets; prefer simple words over jargon.
