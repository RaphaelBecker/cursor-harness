---
name: grill-me
description: >-
  Grill the developer about a feature, bug, or idea until every material product,
  architecture, scope, safety, and acceptance decision is resolved. Auto-activate
  at Phase 1 start when the user proposes a non-trivial feature, bug fix, or
  implementation idea (before drafting the plan). Also use when the user asks to
  stress-test or grill a proposal.
---

# Grilling

Use this skill only during planning. Produce a zero-open-question foundation for
the draft implementation plan. Do not implement code. Do not start night-shift;
contract approval still requires a later manual `@implementation-plan-review`.

## Process

1. Explore the repository and tools for discoverable facts instead of asking the developer.
2. Identify decisions that materially affect user behavior, architecture, data contracts,
   security, scope, destructive actions, or acceptance criteria.
3. Ask one consequential decision at a time (or a small related batch) and include a
   recommended answer with concrete trade-offs in plain language.
4. Record every answer in the plan artifact, not only in chat.
5. Continue until material open decisions are resolved or explicitly `N/A` per
   `core-principles.mdc` contract fields.
6. After grilling, draft or update the implementation plan for the developer to read.
   Do **not** auto-run `@implementation-plan-review` — wait for the human to trigger it.

Immaterial implementation choices belong to the safe defaults in `core-principles.mdc`; do
not spend developer attention on them.
