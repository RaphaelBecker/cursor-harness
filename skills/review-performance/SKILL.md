---
name: review-performance
description: >-
  Diagnose frontend/app runtime bottlenecks (load time, waterfalls, bundle
  size, re-renders) without changing UI or behavior. Use when the app feels
  slow. Not a test-suite skill.
disable-model-invocation: true
---

# App performance review

Read the project's performance notes if `doc-routing` maps one.

## Diagnose

Audit page-load. Name the top 3 bottlenecks: N+1, oversized client bundles,
sequential fetch waterfalls, unrestrained re-renders, missing indexes. Use
existing profiler / APM / perf-log paths from README — do not invent endpoints.

## Fix

Compress latency incrementally. Keep UI/UX and feature parity unless current
behavior demonstrably causes the latency. Prefer page/feature-level fetching
and RSC over client waterfalls (see `typescript-react` when the `nextjs` pack
is installed).

## Validate

Targeted suites, then worktree proof per the `testing` rule. Record measured
impact in the project's perf ledger if one exists.
