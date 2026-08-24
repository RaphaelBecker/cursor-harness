---
name: extract-deep-module
disable-model-invocation: true
description: >-
  Extract or collapse one module so a small interface hides rich behavior.
  Use after /architecture-improve approval when the contract names one
  extract. One extract or collapse per run.
---

# Extract a deep module

One extract or collapse. No drive-by refactors.

1. Confirm the approved contract names **this** extract and an allowlist.
2. Keep the public interface small. Move behavior behind it. Delete the
   shallow wrapper if the deletion test said it only moved complexity.
3. Callers go through the new owner. Do not leave a parallel path (Gate A).
4. Prove with the `testing` ladder. Then `@review-code` (blast-radius if
   the seam is shared). Phase 5 handoff as usual.

If the contract is missing or names a dependency-direction fix instead,
stop and use that skill or `/architecture-improve`.
