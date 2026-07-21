---
name: project-memory
description: >-
  Loads domain-relevant entries from project_memory.md during Phase 1 planning
  and consolidates post-CI lessons into that file during Phase 7. Auto-activate
  when entering Phase 1 Understand & Plan, when reviewing an implementation plan,
  or after the developer confirms a test-relevant CI/main cycle is green. Never
  treat memory as authoritative over code, canonical docs, or Cursor rules.
---

# Project memory

Custodian of root `project_memory.md` (see harness
`templates/project_memory.example.md`). Preserve actionable lessons while
preventing context bloat and logic drift.

## Authority

- Memory is a compact learning overlay, not a source of truth.
- Precedence: current code → canonical docs (via `doc-routing`) → Cursor rules →
  `project_memory.md`.
- If a memory entry contradicts a canonical doc or rule, ignore it for planning
  and prune it during the next consolidation.

## Phase 1 — load (before plan generation)

1. Identify the request domain(s) from the user prompt and routed docs.
2. Read only matching bullets from `Architecture & Best Practices` and
   `Bug Fixes & Gotchas`. Do not load unrelated domains.
3. If the file is missing or both sections are empty, continue planning with no
   hard stop.
4. Cross-check loaded entries against the routed canonical docs. Drop stale or
   contradictory items from the working set; do not let them steer the plan.
5. Proceed to plan generation / `@implementation-plan-review`. Memory load is not
   plan approval.

## Phase 7 — consolidate (after confirmed-green CI)

Trigger only when a **test-relevant** CI/main (or equivalent merge) cycle reaches
green and the developer confirms that state (or the agent has direct evidence of
a watched-green run). Do **not** run after:

- local Phase 5 handoff,
- docs/rules-only changes with no test pipeline,
- a failed CI run that has not yet been repaired to green.

At activation, output this exact message first:

`CI Pipeline passed. Initiating Lessons Learned phase to consolidate session knowledge into project_memory.md...`

Then:

1. Retrospect the cycle: architectural shifts, friction, recurring bugs, CI fixes.
2. For each durable lesson, draft at most one entry in this exact format:
   `* **[Domain/Module]** Actionable rule or root-cause solution. (Target file/folder)`
   Maximum two sentences. No stack traces, raw code, or narrative history.
3. Read the target section. Integrate by rewriting for extreme brevity — never
   append to the bottom. Merge duplicates; delete obsolete or contradictory logic.
4. Place new bug entries at the **top** of `Bug Fixes & Gotchas` (newest-first).
5. Capacity for `Bug Fixes & Gotchas` is **20**:
   - Before adding a 21st item, prefer **Promotion Protocol**: if multiple bugs
     share a root cause, synthesize ONE overarching rule under
     `Architecture & Best Practices` and delete the covered bug entries.
   - Otherwise apply FIFO: delete the oldest entry (last list item), then insert
     the new bug at the top.
6. **Architecture safety gate:** if the new lesson contradicts an existing rule
   in `Architecture & Best Practices`, stop and ask the user for explicit
   confirmation before overwriting that rule.
7. Leave `project_memory.md` **local and unstaged**. Do not commit or push.
   Disclose the unstaged state in the handoff. An uneventful retrospective may
   leave the file unchanged.

## Manual capture (cross-session learning)

When the user asks to persist a lesson outside Phase 7:

1. Filter for durable, actionable guidance (not one-off chat noise).
2. Choose storage: promote recurring themes into `Architecture & Best Practices`;
   put concrete bug gotchas into `Bug Fixes & Gotchas`.
3. Apply the same rewrite/capacity rules as Phase 7.
4. Confirm with the user what was written; leave unstaged unless they ask to commit.

## Non-goals

- Do not duplicate canonical policy already owned by rules or docs.
- Do not weaken merge/push/deploy safeguards.
- Do not invent executable tests for this declarative policy.
