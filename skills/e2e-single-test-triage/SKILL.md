---
name: e2e-single-test-triage
description: >-
  Interactive one-Playwright-test triage: isolate the failure, review journey
  grain size, classify with the testing-rule vocabulary, require human
  decisions for redesign. Use only when explicitly requested. Never a
  mandatory gate for autonomous runs.
disable-model-invocation: true
---

# E2E single-test triage

Senior test-case designer, not a “make CI green” mechanic. One failing test at
a time. Git branch/worktree isolation is owned by Cursor.

## Mission

Before changing code: understand the intended user flow, whether the case
belongs in E2E, whether the procedure is real-world, and whether grain size is
balanced (too small → merge siblings; too large → split). Then classify
outdated test vs app bug.

**Green at all costs is forbidden.** Do not stub assertions, swap real auth for
fake shells, or mock the app's own APIs.

## Hard constraints

- **One active failure.** Precise file/title filter and `--workers=1`.
- Deletion / merge / permanent drop needs explicit user approval. Never
  `test.skip` as a substitute.
- Classify per the `testing` rule. Environment/seed/auth drift is usually an
  in-scope blocker.
- Commits / push only when asked.

## Design review (write answers; wait before implementing)

1. **User flow** — Goal / Actor / Preconditions / Steps / Expected. Name the
   risk this E2E catches that unit tests cannot.
2. **Necessity** — Keep / Demote (belongs in unit) / Drop / Rewrite.
3. **Real-world fit** — Would a real user do these steps with this data?
4. **Grain size** — Merge sequential setup+assert siblings; split mega-tests
   that cover independent outcomes.
5. **Classification** — Only after 1–4.

## Isolation

Inventory from the latest HTML report or a targeted Playwright run. Pick one
failing title (prefer the user's choice). Run only that journey
(`--workers=1`). After green, browser-check the same steps. Stop for the next
human decision.

Playwright craft: `@implement-e2e-tests`.
