---
name: grill-me
description: >-
  Grill the developer about a plan, decision, or idea until every material
  product, architecture, scope, safety, and acceptance decision is resolved.
  Use during day-shift planning when the user asks to stress-test or grill a
  proposal.
---

# Grilling

Use this skill only during planning. Its purpose is to produce a zero-open-question
implementation contract that can run unattended; it must not reintroduce approval prompts
during approved-plan execution.

## Process

1. Explore the repository and tools for discoverable facts instead of asking the developer.
2. Identify decisions that materially affect user behavior, architecture, data contracts,
   security, scope, destructive actions, or acceptance criteria.
3. Ask one consequential decision at a time and include a recommended answer with concrete
   trade-offs. When `implementation-plan-review` invokes this skill, follow that skill's
   related-question batching instead.
4. Record every answer in the plan artifact, not only in chat.
5. Continue until the implementation contract has no material open decisions and all required
   fields in `core-principles.mdc` are resolved or explicitly `N/A`.
6. Do not implement until the final contract approval gate passes.

Immaterial implementation choices belong to the safe defaults in `core-principles.mdc`; do
not spend developer attention on them.
