---
name: audit-module-boundaries
disable-model-invocation: true
description: >-
  Scan the import graph against the project's layering doc for new skip-layer
  leaks, cycles, and god or shallow files. Use during health audit or
  circular-dep reviews. Report only. Complements core architecture-audit.
---

# Audit module boundaries

Report only. No patches. No new npm deps for the scan.

## SSOT

The consumer's architecture / layering doc (discover via `doc-routing`). Do not
invent a layer map. If none exists, say so and only flag cycles + oversized files.

## Method

1. Read the layering doc. Treat documented leaks as **known**.
2. Shallow import graph from the project's source globs (grep import/from lines).
   Flag:
   - **New** skip-layer imports not named in the layering doc
   - Import cycles
   - God/shallow: new wide barrels, pass-through façades, files far over sizes
     already named
3. Classify each finding: **known** vs **new**.

If core `architecture-audit` is installed, reuse its cycle/shallow findings
instead of duplicating that scan.

## Output

| path | issue | known-or-new | severity |

No refactor mandate.
