---
name: add-supabase-migration
paths: supabase/**
description: >-
  Create and validate a Supabase migration against the project's isolated test
  database, then regenerate types. Use when an approved plan adds or changes
  tables, views, RPCs, or RLS policies.
---

# Add a Supabase migration

Discover commands from README / package scripts / `harness.project.yaml`. Typical
CLI: `npx supabase migration new <short_snake_case>`. Never edit an already-applied
historical migration.

## Steps

1. Create a timestamped migration under `supabase/migrations/`.
2. Write the SQL:
   - New user-data table → `ENABLE ROW LEVEL SECURITY` + at least one `CREATE POLICY`
     (then `@verify-rls-policies`).
   - Heavy aggregations belong in views/RPCs, not app loops. Missing field →
     `ALTER VIEW` / migration, not a client workaround.
   - Views should declare `security_invoker = true` unless there is a documented reason.
3. Apply/validate on the **isolated test** DB (project bootstrap/lease scripts).
   Do not mutate personal-local or hosted DBs without an explicit ask.
4. Regenerate TypeScript types from the test DB URL (`@regen-db-types`).

## Hard rules

- NEVER `supabase db reset` / project reset scripts that wipe developer data
  unless the human explicitly asks.
- NEVER push to remote unless the user explicitly asks.
- After: targeted tests, then worktree proof per the `testing` rule.
