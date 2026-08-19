---
name: architecture-audit
description: >-
  Report-only scan for shallow modules, cycles, and layer leaks. Starts from
  recent git hot spots. Use from /architecture-improve or when the developer
  asks for an architecture audit. No edits.
---

# Architecture audit

Report only. Do not edit code or docs.

## Scope first

Deepening pays off where the code already changes. Decide where to look:

1. If the human named a module or pain, take it.
2. Else walk recent `git log` (paths that keep coming up). Scattered history
   → widen once, still prefer hot spots.

Load domain-relevant `@project-memory` and one routed product story. Read
`deep-modules-clean-architecture` for the words **module**, **deep**,
**seam**. Do not invent a second vocabulary.

## Look for

- Understanding one concept requires bouncing across many small files
- **Shallow** modules: interface almost as big as the body
- **Deletion test:** would deleting this file *concentrate* complexity, or
  just move it? "Concentrates" is the smell
- Cycles or wrong-way dependencies
- Tight coupling across a seam; tests that cannot hit the real call site

## Hand back

A short report (chat is enough; no HTML file):

- **Hot spots** — paths from recent history
- **Candidates** — each: files, smell, deletion-test result, one-line
  deepening, strength (`Strong` / `Worth exploring` / `Speculative`)
- **Top pick** — which one smell to take this run, and why

Ask which slice to take. Do not start `@grill-me` until they pick.
