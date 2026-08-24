---
name: review-github-actions
paths: .github/workflows/**
description: >-
  Audit GitHub Actions workflows for runtime, safe parallelism, caching,
  action pinning, security, and flake diagnosis. Use when editing workflow
  YAML, reducing CI time, or investigating CI failures.
---

# Review GitHub Actions

Read the project's CI/deploy docs first (`doc-routing` / README). Follow
`github-actions` rule when that pack rule is installed.

## Boundaries (portable)

- Pin every external `uses:` to a full immutable commit SHA (version comment OK).
- Least-privilege `permissions`. Non-cancelling production concurrency.
- Never cache `node_modules`, secrets, env files, database state, or reports.
- Prefer package-manager / browser / compiler input caches with keys that change
  only with those inputs. Never put `github.run_id` in a reusable cache key.
- Never parallelize tests that share mutable golden data or one test database.
- Fail-closed path classification: docs/rules-only should not deploy.
- Do not add staging, a second workflow SSOT, or topology changes without a
  contract. Increase retries/timeouts only after a bounded transient cause.
- Hand real E2E product failures to the project's E2E process — do not hide
  them with retries.

## Procedure

1. `gh run view --json jobs` timings for a recent run.
2. Map jobs and nested scripts. Name the wall-clock critical path.
3. Prefer isolated jobs, fail-closed paths, and bounded waits.
4. Confirm pins, permissions, concurrency, timeouts, artifact retention.
5. Targeted tests for path classification / pin validation when the project has them.
6. Confirm no gate was weakened and no deployment occurred.

Evidence: parse-check YAML, per-slice timings, estimated parallel critical path.
