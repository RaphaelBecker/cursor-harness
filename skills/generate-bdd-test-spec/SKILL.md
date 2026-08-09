---
name: generate-bdd-test-spec
description: >-
  Generates structured BDD test scenarios (Gherkin Given/When/Then) from
  implementation plans, split into unit and E2E (or integration) tests.
  Auto-invoke in Phase 2 for every approved feature plan, immediately after
  Phase 1 approval.
---

# Test Specification Workflow

Act as a senior QA engineer. Analyze the attached implementation plan.
Produce a structured list of test scenarios in Gherkin format (Given/When/Then) for the
planned features. Split them into:

1. Unit / focused tests (pure functions, domain logic, state, edge cases)
2. E2E or integration tests (complete user flows and observable UI/API behavior)

Explicitly cover error handling and boundary conditions. Do not write code yet.
Discover the project's test layout and runners from README, package scripts, or CI — do not
assume a specific framework.

## Workflow

1. **Read the plan** — Extract features, acceptance criteria, API/data changes, and UI flows.
2. **Assign scope** — Per feature, decide: pure logic → unit; end-to-end flow → E2E/integration.
3. **Write scenarios** — Happy path, error handling, and boundary conditions per feature.
4. **Check for gaps** — Authorization, empty states, invalid inputs, network/DB failures.
5. **Deliver** — Specifications only; no test code, no implementation.

## Output structure

```markdown
# Test specification: [Feature / plan title]

## Overview
- [Brief: what is being tested, key risks]

## Unit tests

### [Module / function]
| ID | Scenario | Given | When | Then |
|----|----------|-------|------|------|
| U-01 | Happy path | … | … | … |
| U-02 | Edge case | … | … | … |
| U-03 | Error case | … | … | … |

## E2E / integration tests

### [User flow]
| ID | Scenario | Given | When | Then |
|----|----------|-------|------|------|
| E-01 | Happy path | … | … | … |
| E-02 | Error handling | … | … | … |
| E-03 | Boundary condition | … | … | … |

## Open questions / assumptions
- [Unclear requirements from the plan]
```

Alternatively, per scenario as a Gherkin block:

```gherkin
Scenario: U-01 — [Short title]
  Given …
  When …
  Then …
```

## Quality criteria

- Every planned feature has at least one happy path and one error/edge case.
- Unit scenarios test isolated logic without UI; E2E scenarios describe observable behavior.
- No implementation details (selectors, function names) — focus on observable behavior.
- No test code in this phase.
