---
name: review-sql-performance
description: >-
  Optimize PostgreSQL query latency and payload size without changing results.
  Use when a query, RPC, or view is slow, times out, or over-fetches.
disable-model-invocation: true
---

# SQL query performance review

Read the project's SQL performance notes if `doc-routing` maps one.

## Invariant: zero logical mutation

Only change query structure to speed execution or shrink payload. Never alter
the mathematical result, filtering, or row count. Cache a baseline result set
before refactoring.

## Optimize

Highest-latency queries first: missing indexes, inefficient JOINs, unbounded
CTEs, N+1, scalar-subquery overhead. If indexing fixes it, emit exact
`CREATE INDEX` SQL. `SELECT *` compression: drop columns only after verifying
mappers/consumers.

## Validate

Re-run and diff against the baseline — must be identical. Run typecheck if
narrowed `.select()` types. Record pre/post latency in the project's perf
ledger if one exists.
