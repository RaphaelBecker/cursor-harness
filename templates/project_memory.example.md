# Project memory

This is the project **summary** file agents read and update. Bounded learning overlay —
not a source of truth. Current code, canonical docs, and Cursor rules take precedence.
Keep entries short; rewrite in place (never append forever).

**Candidates** come from human **lessons learned**. Later sessions load matching rows and
bump `help_count` when a lesson actually helped.

## Architecture & Best Practices

<!-- Soft tips only. Phase 7 may rewrite. Format:
* **[Domain/Module]** Actionable rule. (Target file/folder)
-->

## Candidates (scored)

<!-- Ladder toward harness solidification. Phase 1 loads active rows only.
Columns: id | domain | lesson | added_at | help_count | last_helped_at | status
status = active | staged | retired
-->

| id | domain | lesson | added_at | help_count | last_helped_at | status |
| --- | --- | --- | --- | --- | --- | --- |

## Cycle status

<!-- Overwritten each Phase 5 / Phase 7 promote. Example:
## Cycle status (YYYY-MM-DD · <feature-label>)
- New: 0 · Helped this cycle: 0 · Active: 0/30 · Staged for harness: 0
- Staged: none
- Top helped: —
-->
