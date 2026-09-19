---
name: grill-me
disable-model-invocation: true
description: >-
  Produce a zero-open-question foundation for the one Cursor plan.
  Default is packet mode (all material questions at once with recommended
  answers) during /prep. Conversational one-at-a-time only when the human
  explicitly asks to grill interactively. Do not auto-start outside prep.
---

# Grilling

Use this skill during **`/prep`** (or when the human explicitly asks).
Do not implement code. Do not start Nightshift. Plan approval still
requires `/implementation-plan-review` plus an explicit yes.

Do **not** auto-start a long grill outside a prep sitting. If an idea arrives
then, point them at `/prep` (anytime) or note it — do not pair all day.

## One plan (SSOT)

The SSOT is the existing Cursor `*.plan.md` for this item. Rewrite that file.
Never create a second plan (no extra CreatePlan, no `.cursor/plans/<slug>.md`,
no `contract.md`). Sidecars start with `SSOT: <exact-path-of-that-plan.md>`.

## Packet mode (default)

1. Explore the repository and tools for discoverable facts instead of asking.
2. Identify decisions that materially affect user behavior, architecture, data
   contracts, security, scope, destructive actions, or acceptance criteria.
3. Emit **one packet**: every material question in a single list. Each item has
   a **recommended answer** and a one-line trade-off. The human edits leftovers
   in one sitting (keep prep to about **2h max**).
4. Record answers in this item’s existing Cursor `*.plan.md`, not only in chat.
5. Continue until material open decisions are resolved or explicitly `N/A` per
   `core-principles.mdc` plan fields, including **Manual test**.
6. Update that same plan file. Do **not** auto-run `@implementation-plan-review`.

Each packet item must be founder-readable (same bar as
`implementation-plan-review` Step 4):

- **Issue:** what is wrong or at stake — what the user notices
- **Recommended:** what to do, in one sentence, plus why it helps
- **Trade-off:** what you give up, in product terms

Do not ask how to wire a function. If the human cannot see the difference
without reading code, pick the safer default and do not list it.

Immaterial implementation choices belong to the safe defaults in
`core-principles.mdc`; do not spend developer attention on them.

## Conversational mode (escape hatch)

Use only when the human asks to grill interactively (one consequential decision
at a time, with a recommended answer). Same recording rules as packet mode.
