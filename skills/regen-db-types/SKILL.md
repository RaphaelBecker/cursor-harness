---
name: regen-db-types
paths: supabase/**
description: >-
  Regenerate TypeScript database types from the isolated test Supabase schema.
  Use after an approved migration or when generated DB types are stale.
---

# Regenerate Supabase types

Requires the project's isolated test database. Discover bootstrap + gen-types
commands from README / package scripts. Typical:

```bash
npx supabase gen types typescript --db-url "$DATABASE_URL" > types/database.ts
```

Load `DATABASE_URL` from the project's documented test env file — never invent
hostnames. After regenerating, run the project's typecheck. Commit generated
types with the migration that changed the schema. Then the `testing` rule ladder.
