---
name: inspect-db-schema
description: >-
  Read-only Postgres schema inspect for sync checks, drift, and debugging.
  During approved-plan execution, use the isolated test database. Personal-local
  or production only as a separate explicit human-authorized task.
disable-model-invocation: true
---

# Inspect DB schema

## Test target (agent-executable)

1. Run the project's test-DB bootstrap when needed (check lease/status if documented).
2. Load the test DB URL from the project's documented env file.
3. Run read-only catalog queries: tables, columns, views, functions, policies.

Never switch to personal-local or production because the test schema is missing.
A failed test bootstrap is verification evidence.

## Explicit extra targets

Project MCP servers (if present) are observe-only when the human authorizes that
inspection. Neither target authorizes schema or data mutation. Never paste secrets;
connection details come from env vars.

## Typical checks

- List tables/columns vs generated types and `supabase/migrations/`.
- Confirm an RLS policy or view definition before proposing a migration.

Schema changes go through `@add-supabase-migration`, validated on the test DB.
