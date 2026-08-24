---
name: implement-unit-tests
paths: tests/**,test/**,spec/**,**/__tests__/**
description: >-
  Implement Vitest unit/UI scenarios from an approved BDD spec or bug
  regression contract. Use during approved-plan execution when a TypeScript
  module, hook, component, or function needs coverage.
---

# Unit test implementation

Implement unit scenarios from the spec for the selected file.

- Mock external dependencies (DB clients, APIs, `fetch`, network).
- Assert inputs/outputs (return values, thrown errors, rendered text) — not internals.
- Typed TypeScript for Vitest.
- Framework mocks (router, search params, pathname, providers) only when the
  unit needs them — discover from existing `tests/setup/`.

## Workflow

1. **Read the spec** — Map each unit scenario ID (e.g. U-01) to a `describe`/`it`.
2. **Read the source** — Public surface + boundaries to mock.
3. **Pick the test path** — Must match this project's Vitest include globs.
4. **Implement** — One scenario per test; name after intent. `// SPEC_REF: U-01` when IDs exist.
5. **Run** — Targeted file, then the `testing` rule ladder. All new tests must pass.

## Placement

| Under test | Typical tree |
| --- | --- |
| Pure logic / functions / hooks | unit |
| Isolated components | UI |
| API/DB boundaries | integration — only if the spec says so |

## Mocking

Mock at the **module** boundary, not internal helpers of the unit under test.
Reuse existing setup mocks; override per file only when a scenario needs
specific router/provider behavior. Wrap with the minimal provider stub — do
not mock the component under test.

## Quality checklist

- [ ] Every unit scenario has a test
- [ ] Assertions describe observable outcomes
- [ ] External I/O mocked; no live network/DB
- [ ] Tests independent — no shared mutable state
- [ ] Targeted run green, then worktree proof per `testing` rule

Related: `generate-bdd-test-spec` (if `bdd` pack), `generate-vitest-test`.
