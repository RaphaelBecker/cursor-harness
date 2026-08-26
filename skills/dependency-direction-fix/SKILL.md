---
name: dependency-direction-fix
disable-model-invocation: true
description: >-
  Reverse or break one dependency cycle or wrong-way import. Use after
  /prep approval (kind: architecture) when the contract names one cycle. One
  cycle per run.
---

# Fix one dependency direction

One cycle or wrong-way dependency. No extra cleanup.

1. Confirm the approved contract names **this** cycle and an allowlist.
2. Point the arrow the right way (policy/domain inward; connectors at the
   edge). Extract a seam if two modules both need the same fact.
3. Do not add a new framework or a second copy of the logic.
4. Prove with the `testing` ladder. Then `@review-code` (blast-radius if
   the seam is shared). Phase 5 handoff as usual.

If the contract names an extract instead, use `@extract-deep-module`.
