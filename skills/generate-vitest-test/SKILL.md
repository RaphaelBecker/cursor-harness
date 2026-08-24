---
name: generate-vitest-test
paths: tests/**,test/**,spec/**,**/__tests__/**
description: >-
  Scaffold a Vitest unit, UI, or integration test that matches the project's
  configured globs. Use when an approved plan or request needs tests for a
  function, hook, component, or module consumer.
---

# Generate a Vitest test

Discover include globs from `vitest.config.ts` / `vitest.config.*` (or README).
Do not invent another repo's suffixes. Typical pattern: `*.unit.test.ts`,
`*.ui.test.tsx`, `*.int.test.ts` — but follow **this** project's config.

## Pick the layer

- Pure logic / functions / hooks → unit tree
- Isolated components → UI tree
- Multi-module / DB-relational → integration tree (only when the spec needs it)

Files that miss the configured suffix are silently skipped by Vitest.

## Conventions

- Import the unit under test the way this repo does (`@/` or relative).
- Mock external boundaries (DB client, `fetch`, network). Never hit live services.
- Reuse `tests/fixtures/` and `tests/setup/` when they exist.
- UI: Testing Library; assert rendered output, not internals.
- Cover the changed behavior plus at least one edge case. Exact expected values
  for math / mapper / validator tests.

## Template (unit)

```ts
import { describe, it, expect, vi } from 'vitest';
import { subjectUnderTest } from '../path/to/module';

describe('subjectUnderTest', () => {
  it('handles the happy path', () => {
    expect(subjectUnderTest(/* input */)).toEqual(/* expected */);
  });

  it('handles the edge case', () => {
    expect(() => subjectUnderTest(/* bad input */)).toThrow();
  });
});
```

## Run

Local tests are agent-allowed. Narrowest targeted command first, then the
`testing` rule ladder (`harness.project.yaml` `test.*` / discovered scripts).
Never invent `test:fast` / `test:complete` as required names.
