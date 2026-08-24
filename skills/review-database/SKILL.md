---
name: review-database
description: >-
  Review schema, migrations, and thin-backend integrity. Use when auditing
  schema sync, migration safety, or whether heavy logic belongs in SQL views
  vs app code.
disable-model-invocation: true
---

# Database architecture review

Read the project's database docs first (discover via `doc-routing` / README).

## Schema sync & migration audit

- Validate the migration ledger on the isolated test DB (project bootstrap).
  Never mutate personal-local or hosted DBs during the review.
- Remote-ledger comparison is a separate, explicit human-authorized read-only task.
- Prove every new migration applies cleanly from the test stack baseline.

## Thin backend

- Heavy aggregations belong in PostgreSQL views/RPCs, not application loops over
  raw rows. Missing columns → exact `ALTER VIEW` SQL, never an app-layer workaround.
- New tables: `@verify-rls-policies`.

## Output

Concise report: migration audits, view adjustments, structural deltas. Confirm
routed database docs still match. No silent prod edits.
