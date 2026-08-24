---
name: implement-e2e-tests
paths: tests/**,test/**,spec/**,e2e/**,**/__tests__/**
description: >-
  Playwright + TypeScript E2E expert: user-flow design, deterministic data,
  stable selectors, auth models, anti-flakiness, idempotent cleanup. Use when
  an approved plan creates or rewrites browser tests.
---

# E2E test implementation

Senior QA automation. E2E verifies **complete user journeys** against the
running product — scarce top of the pyramid, critical paths only. Never
green-wash: no weakened assertions, no mocking the app's own APIs.

Discover wiring from `playwright.config.*`, `tests/e2e/README.md`, and package
scripts. Do not invent another repo's catalog ids or seed helpers.

## Test design (before code)

1. **One coherent journey per spec** — clear start state, one primary outcome.
2. **Trace the flow** — routes, UI states, data deps. E2E asserts the UI
   *displays* backend truth; it does not recompute it.
3. **Deterministic data** — project's seed / fixture SSOT. Expected values from
   that SSOT, not invented in the spec.
4. Case card when the project has one (goal, actor, preconditions, steps, expected).

## Structure

- Serial `test.describe` with a few `test()` blocks; `test.step()` for sub-steps.
- Naming: follow this repo (`tests/e2e/<feature>.spec.ts` is typical).
- Cleanup in `afterAll`; prefer tenant-scoped fixtures over shared mutable accounts.

## Authentication (one model per file)

Discover the project's storage-state / seeded-user helpers. Never mix auth
models in one file. Never hand-roll login when a storage state exists.

## Selector priority

1. `data-testid` for dynamic metrics
2. `getByRole` with `{ name, exact }` for nav, buttons, headings, dialogs
3. `getByLabel` / `getByText` for forms and stable copy
4. Avoid CSS chains, `nth-child`, marketing-copy text, layout order

## Anti-flakiness

- Never `waitUntil: 'networkidle'`. Navigate, then `toBeVisible()`.
- Never fixed `waitForTimeout`. Wait on UI or `page.waitForResponse`.
- Strict-mode-safe locators — 2+ matches is a test bug.
- `--workers=1` when suites share seeded tenants or storage state.
- Numeric assertions: exact expected display strings, not loosened regex.

## Network

Mock **third-party** boundaries via `page.route()` when they are flaky or
rate-limited. Never mock the app's own APIs, views, or RPCs.

## Failures

Classify per the `testing` rule (introduced / in-scope blocker / outdated spec /
out-of-scope). No class permits deleting, skipping, or broadening an assertion.

## Run

Local tests are agent-allowed. Targeted Playwright file with `--workers=1`,
then the verification ladder. Check the project's test-pool/lease status when
the project documents one.

Related: `e2e-single-test-triage`, `generate-bdd-test-spec`, `fix-flaky-test`.
