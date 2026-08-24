---
name: verify-rls-policies
paths: supabase/**
description: >-
  Verify that every table created in Supabase migrations has Row Level Security
  enabled and at least one policy. Use in Phase 4 when a change touches a migration.
---

# Verify RLS policies

No table ships without RLS. Every `CREATE TABLE` in `supabase/migrations/**` must
have a matching `ENABLE ROW LEVEL SECURITY` and at least one `CREATE POLICY`.

## Run the scanner

```bash
node .cursor/skills/verify-rls-policies/scripts/check-rls.mjs
```

Run from the **consumer** repo root. The script finds `supabase/migrations` from
cwd (or walks up). Exit 0 = coverage OK. Exit 1 = gaps; add the missing
`ALTER TABLE ... ENABLE ROW LEVEL SECURITY` and `CREATE POLICY` in the owning
migration, then re-run.

## Notes

- Aggregates across ALL migrations (RLS can land in a later file than CREATE TABLE).
- Intentionally public-readable tables still need RLS + an explicit read policy;
  document the rationale in the migration.
- Heuristic over SQL text; confirm ambiguous cases with `@inspect-db-schema`.
