---
name: blast-radius
description: >-
  Find what a change could break beyond the diff, name the one fact it is
  safe because of, and prove that fact by running code. Use when the
  developer runs /blast-radius, asks what this could break, or when
  review-code / ship-local need a proven safety fact on a sensitive diff.
  Skip copy-only and docs-only changes.
disable-model-invocation: true
---

# Blast radius

Name the **one fact** the change is safe because of. Prove it by running
code. Listing callers is not the job.

Do not write a long list of maybes. Unproven stays labeled **unproven**.

## When to run

Run when the allowlist or diff touches **shared modules**, **lifecycle**
(create/update/delete/archive/reset), **money**, **auth**, or **wire
formats** (API JSON, DB columns, another language reading the same bytes).

Skip for copy-only or docs-only work. Do not add a new always-on rule.

## Trust ladder

For the safety fact, get as far down this list as is cheap, and say where
it stopped:

1. You said so — worthless alone.
2. You pointed at a real `file:line`.
3. You walked the bad case; it cannot reach.
4. You **ran** a script or test that calls the real code and fails loud if
   you are wrong.
5. You reproduced it in the running app.

Any load-bearing claim that does not reach step 4 is **unproven**. Do not
round up.

## Steps

1. Read the change — what it adds, changes, deletes, and the part the diff
   does not spell out.
2. State the one safety fact. If it holds, most scary cases die at once.
3. Look where grep stops: library source and pinned version, teardown
   timing, serialized boundaries, feature flags, code three hops downstream.
4. Keep only confirmed risks. Each names how it breaks, a `file:line`,
   chance, cost, and how to check. List cleared checks separately. A search
   that finds nothing is still an answer. Never invent a caller or API.
5. Prove the fact. Write or reuse a small test/script, run it, paste what
   happened. If you cannot prove it cheaply, write **unproven**.

## What to hand back

Write this block into `.cursor/night-shift/HANDOFF.md` (and the review
summary) under `## Blast radius`:

- **What it does** — including the non-obvious part.
- **The one fact it is safe because of** — the fact, the ladder step you
  reached, and the proof command + output. Or **unproven**.
- **Risks** — confirmed only.
- **Cleared** — what you checked and why it is fine.
- **Before you merge** — the cheapest command that would catch the real bug.

Cite real code. No puffery. No private values in the writeup.
