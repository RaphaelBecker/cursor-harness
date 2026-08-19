---
name: diagnose-bug
description: >-
  Build a tight red-capable loop before hypothesising. Use during non-trivial
  /bugfix prep, when the developer says diagnose or debug this, or when a
  night contract is missing the named red command. Do not implement the fix
  here.
---

# Diagnose a bug

No hypothesis until a **tight red-capable loop** exists. This skill finds
the cause and names the command. `/bugfix` + `@execute-approved-plan` apply
the fix.

Do not invent product commands. Discover them from the project.

## Redact

Show commands and outputs. Replace secrets with `[REDACTED]`. Prefer env
vars over pasted credentials.

## Phase 1 — Tight red loop (this is the skill)

Spend the time here. Done when you can name **one command you have already
run** that:

- goes **red** on the user's exact symptom (not "did not crash")
- is deterministic (or a pinned high flake rate)
- finishes in seconds when possible
- the agent can run unattended

Prefer, in this order: failing test at the real seam → curl/script against
dev → CLI + fixture → headless browser assert → replay a captured payload
→ throwaway harness → bisect/differential loop.

Tighten after you have *a* loop: faster, sharper assert, more deterministic.
If you cannot build a loop, stop. List what you tried. Do **not** proceed
to hypotheses.

## Phase 2 — Reproduce and minimise

Run the loop. Confirm it is the user's bug. Cut inputs until every remaining
piece is load-bearing.

## Phase 3 — Hypotheses

Write **3–5 ranked, falsifiable** hypotheses before testing any:

> If *cause*, then *probe* makes the bug disappear / worse.

Show the list. If the human is away, keep your ranking and continue.

## Phase 4 — Instrument

One variable per probe. Debugger or tagged logs (`[DEBUG-xxxx]`) at the
boundaries that distinguish hypotheses. Measure first on perf bugs.

## Phase 5 — Hand back (do not fix here)

Return:

- the **one red command** (invocation + redacted output)
- the minimised repro
- the ranked hypotheses
- the correct test seam for the later RED regression (or "no seam — architecture
  finding")

`/bugfix` records the red command in the contract **Tests** field, then
grills and plans. Night writes the regression at that seam first.

## Cleanup if you instrumented

Remove `[DEBUG-…]` logs and throwaway harnesses before you leave, or list
them in BLOCKED.md if unattended and you must stop mid-loop.
