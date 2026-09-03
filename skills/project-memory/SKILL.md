---
name: project-memory
description: >-
  Bounded `project_memory.md` overlay: Phase 1 load, Phase 5 Candidates +
  cycle status, Phase 7 promote after green remote ship. Auto-activate on
  planning, plan review, Phase 5, or Phase 7. Never overrides code or docs.
---

# Project memory

Custodian of root `project_memory.md` (see harness
`templates/project_memory.example.md`). Preserve actionable lessons while
preventing context bloat and logic drift.

## Authority

- Memory is a compact learning overlay, not a source of truth.
- Precedence: current code → canonical docs (via `doc-routing`) → harness rules →
  `project_memory.md`.
- If a memory entry contradicts a canonical doc or rule, ignore it for planning
  and prune it during the next consolidation.

## File sections

1. **Architecture & Best Practices** — soft tips (not scored). Phase 7 may rewrite.
2. **Candidates (scored)** — markdown table ladder toward harness solidification.
3. **Cycle status** — compact end-of-cycle block (overwritten each Phase 5 / promote).

### Candidates table columns

`id` | `domain` | `lesson` | `added_at` | `help_count` | `last_helped_at` | `status`

- **id:** stable short slug (`e2e-auth-storage-key`)
- **domain:** one filter tag (`e2e`, `ci`, `billing`, `harness`, …)
- **lesson:** max ~2 sentences; actionable; no stack traces
- **added_at / last_helped_at:** `YYYY-MM-DD` (use `-` for never-helped)
- **status:** `active` | `staged` | `retired`

### Caps and staging

- Max **30 `active`**. Before adding a 31st: drop lowest `help_count` (tie → oldest
  `added_at`); never drop `staged`.
- Max **10 `retired`** audit rows; FIFO-delete oldest retired.
- **Stage** when `help_count >= 8` **and** age since `added_at` **>= 14 days**.
- Phase 1 never loads `staged` or `retired` rows.

## When agents may write this file

| Section | Who may write | When |
| --- | --- | --- |
| Architecture | Phase 7 only | After watched-green test-relevant remote ship |
| Candidates + Cycle status | Phase 5 (via this skill) and Phase 7 (stage/promote/retire) | After durable handoff lessons; after CI green for promote path |

- Do **not** edit Architecture during Phases 1–5.
- Phase 5 Candidates + cycle status is **ship-scoped**. When `commits: authorized`,
  commit `project_memory.md` with the feature. Do not leave it dirty for a later slash.
- Phase 7 commit/push of Architecture (and docs-only follow-up) runs when `/ship-prod`
  invoked it. Do **not** wait for staged-harness approve/reject in that sitting.

## Phase 1 — load (before plan generation)

1. Identify the request domain(s) from the user prompt and routed docs.
2. Prefer product stories / acceptance docs and `@glossary` for intent/language; use memory
   only for durable process gotchas.
3. Read matching bullets from **Architecture & Best Practices**.
4. Read up to **8** domain-matched **`active`** Candidates rows. Ignore `staged`/`retired`.
5. Record which candidate **ids** were loaded (for honest Phase 5 help bumps).
6. If the file is missing or both sections are empty, continue planning with no hard stop.
7. Cross-check loaded entries against routed canonical docs (and current code). Drop
   stale or contradictory items from the working set; do not let them steer the plan.
8. Proceed to `@grill-me` (auto at Phase 1 for non-trivial ideas), then draft the plan.
   Do **not** auto-run `@implementation-plan-review`. Memory load is not plan approval.

## Phase 5 — candidates write (before `/ship-local`)

Called from `@execute-approved-plan` after handoff `## Lessons learned` exists and before
ship. Do not merge, push, or manage worktrees here.

1. Write `## Lessons learned` in `.cursor/night-shift/HANDOFF.md` (required). Chat
   stays short; do not dump the lessons table in chat.
2. For each durable lesson: **upsert** a Candidates row (`active`, `help_count=0` if new,
   `added_at=today`). Same domain+intent → rewrite in place; do not clone rows.
   Do **not** upsert a candidate that only restates the `testing` rule, `/ship-prod`,
   `/ship-local`, or `@execute-approved-plan`. Do not stage product-domain ids as
   harness. Prefer retiring a process lesson after a script owns it.
3. For each loaded candidate **cited as used** this cycle: `help_count += 1`, set
   `last_helped_at=today`. Max **+1 per id per cycle**. Cite those ids in the handoff.
4. Run stage check → set qualifying rows to `status=staged`.
5. Refresh **Cycle status** (overwrite the block):

```markdown
## Cycle status (YYYY-MM-DD · <feature-label>)
- New: N · Helped this cycle: N · Active: N/30 · Staged for harness: N
- Staged: `id1`, `id2` (or none)
- Top helped: `id` (count) · …
```

6. Echo cycle status in `HANDOFF.md`, not as a long chat block.
7. Do **not** edit Architecture here.
8. Commit `project_memory.md` with the feature when `commits: authorized`.

## Phase 7 — consolidate + staged promote ask (after watched green CI)

Trigger only when a **test-relevant** remote ship (project deploy/push path, including via
`/ship-prod`) reaches a watched green terminal state. Do **not** run after:

- local Phase 5 handoff,
- docs/rules-only ship with no test pipeline,
- a failed CI run that has not yet been repaired to green.

At activation, output this exact message first:

`CI Pipeline passed. Initiating Lessons Learned phase to consolidate session knowledge into project_memory.md...`

Then:

1. Retrospect the cycle: architectural shifts, friction, recurring bugs, CI fixes.
2. For soft Architecture tips: draft at most one bullet per durable lesson.
   Purge Architecture process bullets that a leftover classifier or idle-main
   gate now owns. Product tips stay. For each remaining tip:
   `* **[Domain/Module]** Actionable rule or root-cause solution. (Target file/folder)`
   Maximum two sentences. Integrate by rewriting for extreme brevity — never append-only.
   Merge duplicates; delete obsolete or contradictory logic.
3. **Architecture safety gate:** if a new tip contradicts an existing Architecture rule,
   stop and ask the user before overwriting.
4. Prefer putting new scored process tips into **Candidates** (upsert) rather than growing
   Architecture when the tip is still provisional.
5. List every `status=staged` id in the **short** ship handoff (id + one-line proposed
   edit). Do **not** wait for approve/reject in this sitting. Do **not** auto-apply.
6. On explicit human **approve** in a later sitting: apply the smallest harness edit;
   update HARNESS if inventory changes; set candidate `retired`; **purge** any Architecture
   bullet that restates the same tip; refresh cycle status. Do not retire until the
   harness edit landed in the same change set.
7. On explicit human **reject** in a later sitting: set candidate `retired` (brief reject
   note allowed in lesson text); refresh cycle status.
8. If `/ship-prod` invoked this Phase 7 and `project_memory.md` changed: commit and run
   the project's docs-only ship path. Do **not** re-enter Phase 7 after that push.
9. If nothing durable and no staged ids, leave the file unchanged and do not commit/push.

## Non-goals

- Do not duplicate canonical policy already owned by rules or docs.
- Do not store long technical inventories or component trees in memory.
- Do not auto-edit harness on SCORE threshold alone (stage only).
- Do not weaken merge/push/deploy safeguards beyond human `/ship-local` / `/ship-prod`.
- Do not remove Phase 5 `## Lessons learned` handoffs — they feed Candidates.
