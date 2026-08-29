---
name: bugticket-from-screenshots
disable-model-invocation: true
description: >-
  Optional front door before /prep: turn bug screenshots into a fact-only bug
  ticket. Recompute every displayed stat by hand. Ask every unclear thing.
  Zero assumptions. Report only. Do not start /prep. Do not fix code or tests.
---

# Bug ticket from screenshots

Optional front door **before `/prep`**. Attach screenshots and type this
skill. The only product is the **bug ticket text**. Then the human types
`/prep`.

Skip this skill and `/prep` is unchanged. Use it and `/prep` still runs
diagnose, grill, and review — the ticket replaces the typed bug explanation.

**Report only.** Name the tests to fix and the cases to add. Write no
product code and no tests. Do not start `/prep`. Do not say "hit Build".

## Hard rule: absolute truth, zero assumptions

No guessed number, currency, timezone, fee, missing row, browser, OS,
device, or filter. No `not stated`. No filling a blank to keep moving.

If a digit is blurry, a list is cut off, a fee is not on screen, two stats
could share a definition, or environment is not visible — **stop and ask**.
Do not write the ticket until every blocking unknown is answered.

Facts allowed without asking: text and numbers clearly readable on the
screenshot; the product spec for that surface; files and tests found in
the repo.

## Discover the project (do not invent)

From the repo root:

1. Read `harness.project.yaml`. Use `docs.routing` to find the project's
   doc-routing map. Use the project's version file (`package.json`,
   `pyproject.toml`, `Cargo.toml`, `VERSION`, or the path the project
   already documents).
2. Fetch the project's `doc-routing` rule. Match the screenshots to
   **one** keyword row. Read only those docs.
3. Find covering tests by searching the repo. If the routed row names a
   test oracle or expected-values file, hand-verify those numbers. Do not
   invent a flow id or oracle path.

## Phases

### 1. Ask first, then work

Scan the screenshots. Collect every blocking unknown into **one short
packet** (same shape as `@grill-me` packet mode: all material questions
at once). Ask in plain words. Do not recommend a guess. Do not write any
ticket heading until the packet is answered. If a later phase finds a
new unknown, stop again and ask — never fill it.

If no screenshot is attached, that is the first packet: ask for them.

### 2. Redact

Never copy real names, emails, account ids, or avatars into the ticket.
Refer to them as `[REDACTED]`.

### 3. Inventory the screen

Per screenshot, only what is readable or confirmed: surface/route,
filters, every input row, every displayed stat. Blurry or cut-off values
are questions, not `unreadable` placeholders.

### 4. Route the definitions

Match the surface to **one** row in the project's doc routing map and
read that spec. "Correct" means the product contract, not general
finance. If the spec and the screen label disagree, ask which the ticket
should treat as truth.

### 5. Rebuild the timeline and hand-compute

Order confirmed events by date, compute each stat step by step, show the
arithmetic. A truncated list is a question ("the table is cut off —
please attach the rest, or list the missing rows"). Do not pull a
database to invent the missing rows unless you asked and the developer
said to.

### 6. Gap analysis

One table: `Stat | Shown | Hand-computed | Delta | Verdict`. Verdict is
one of `screen wrong`, `hand wrong (misread)`, `definition mismatch`.
There is no `not enough data` row on a finished ticket — that case is
still in the ask loop.

### 7. Root cause

Trace each wrong stat to **one** layer and name the file plus function.
One sentence per bug: what is wrong, what correct looks like. If the
file cannot be found, say so and ask — do not pick a likely file.

### 8. Test coverage

For each wrong stat, find the covering unit tests and end-to-end tests.
Hand-verify the expected numbers in the project's test oracle. Classify
each as `asserts a wrong number`, `covers the wrong path`, or `gap`.
Prefer adding cases to an existing end-to-end flow; propose a new spec
only when the existing flow is already too big, and say why. Unit tests
are cheap: cover the neighbours of the bug. If no covering test can be
found, say so — do not invent a flow id.

### 9. Write the ticket

Write `.cursor/night-shift/bug-ticket.md` in **this** checkout. Print
that exact text in chat. State the absolute path of the checkout you
wrote into. Then **stop**.

This file is working dirt: gitignored, never committed. A new worktree
reset deletes it. `/ship-local` (and leftover classify on `/ship-prod`)
deletes it. Do not leave it behind.

Do not start `/prep`. Do not say "hit Build".

## Ask packet (graceful, blocking)

One list. Each item is one fact the ticket cannot exist without (a
number, a filter, a missing row, browser/OS if Environment needs it).
No recommended answers unless the value is already readable on the
screenshot and you are only confirming a hard-to-read digit.

Do not ask about implementation choices. Those stay in `/prep`.

## Ticket format (fixed headings)

These headings stay first and verbatim; the analysis sections follow.

```markdown
# Environment
# Description
# Steps to Reproduce
# Expected Behavior
# Actual Behavior
# Evidence (Screenshots / Screen Recordings)
# Hand calculation
# Gap analysis
# Root cause
# Test coverage gap
# Handoff
```

Environment: only facts you can prove (app version from the project's
version file, branch, commit) or that the developer confirmed. Browser /
OS / device are asked if they are not on the screenshot. Never write
`not stated`.

**Handoff** must include:

- Checkout path written into
- Next step: the human types `/prep` when ready
- **Check these:** a short list of facts the developer should
  double-check (numbers, environment, named files, named tests, that
  this is the worktree they will `/prep` in)

## Not doing

- No product code or test edits
- No starting `/prep`
- No guessed fields, `not stated` fillers, or silent database backfill
