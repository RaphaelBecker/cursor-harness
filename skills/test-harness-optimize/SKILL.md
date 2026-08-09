---
name: test-harness-optimize
description: >-
  Improve test speed, flake resistance, or coverage without weakening assertions.
  Use for suite tuning, flake hardening, or coverage gaps. Never “fix” tests by
  deleting meaningful checks.
---

# Test harness optimize

## Rules

- Never weaken or delete assertions just to go green.
- Prefer deterministic waits, better fixtures, and narrower tests over sleeps.
- Keep tests inside the project's fast/local and full/CI-parity layers as appropriate
  (discover from README / package scripts / CI — see `testing` rule).
- Draft-PR / autonomous runs may touch **test files only** unless a human contract expands scope.

## Process

1. Measure: which suite is slow or flaky? Capture command + failure evidence.
2. Hypothesize root cause (timing, shared state, over-broad mock, coverage hole).
3. Change the smallest test/harness surface.
4. Prove with targeted rerun of the failing/slow tests, then ladder per the `testing` rule.
5. Handoff: before/after command times or flake rate notes + `## Lessons learned` if night-shift.

## Related

- `.cursor/automations/README.md` for scheduled test-health prompts
