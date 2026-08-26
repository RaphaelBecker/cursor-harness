---
name: fix-flaky-test
description: >-
  Diagnose and fix one flaky test with isolation vs full-suite comparison.
  Use when the developer runs /fix-flaky-test or names one flaky spec/title.
  Standalone — never part of a workflow. Never weaken assertions.
disable-model-invocation: true
---

# /fix-flaky-test

Standalone. Do **not** invoke from prep, ship-prod, execute-approved-plan,
or automations. The isolation + full-suite proof is too long for those spines.

## Invocation

`/fix-flaky-test <target>` — one spec path or test title. If none or more than
one, ask once and stop.

## Protocol (sequential)

1. **Isolation vs suite** — Run `<target>` ~20 times alone (`--workers=1` for
   Playwright). Then once inside the project's idle-main complete / full gate
   (`test.full` or discovered equivalent). If it fails only in the suite, hunt
   state leak / missing teardown.
   **Early-stop:** first 5/5 isolation runs fail with the **same** assertion →
   deterministic fail, skip remaining repeats; still run one full-suite compare.
2. **Timing** — Races, hardcoded timeouts, bad async/await, networkidle waits.
3. **Seed / schema** — Deterministic fixtures; sanitize before init. Read-only
   schema inspect if unclear (`inspect-db-schema` when the `supabase` pack is on).
4. **Assertions** — Recheck expected values against the spec SSOT. Do not
   loosen numbers.
5. **Logic drift** — Only if 1–4 have written evidence and no root cause.

Do not edit product/test code before step 1 evidence exists. Isolation batches
must not fan out 20 parallel browser workers (pool contention). If the project
has a test-pool status command, check it; live foreign lease → **STOP**.

## Fix rules

- Smallest change that removes the race / leak / seed / wait bug.
- **Never** weaken, skip, or broaden assertions.
- After the fix: re-run isolation (N=20, or N=8 if deterministic) → then **one**
  idle-main complete / `test.full` on idle default. Isolation green is not done.
- Schema / auth / billing contract changes → stop and report. Do not silently
  rewrite domain engines.

## Bugbot

After isolation GREEN, one report-only `/review-bugbot` (or skip if the diff is
empty). Hunt races, stale fetches, shared mutable state, missing teardown.
Fix only in-scope items from that review.

## Done

- [ ] Target parsed; steps 1–5 evidence in order
- [ ] Root cause named
- [ ] Smallest fix — or hard-stop reported
- [ ] Isolation re-prove + one full-suite green
- [ ] Bugbot pass (or skipped: empty diff)
- [ ] `## Lessons learned` on the handoff

Related: `implement-e2e-tests`, `test-harness-optimize`, `testing` rule.
