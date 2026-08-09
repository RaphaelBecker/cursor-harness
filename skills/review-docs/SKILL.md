---
name: review-docs
description: >-
  Audit documentation for accuracy, dead links, and codebase alignment. Default
  report-only; fix only under an allowlist (dead links, acceptance bullets in the
  routed canonical doc). Use when docs may have drifted from the code, or before
  a release.
disable-model-invocation: true
---

# Documentation review

## Default mode: report only

1. Audit READMEs, `docs/`, diagrams, and inline comments against the verifiable state of
   the codebase.
2. Flag deprecated instructions, obsolete architecture references, and dead links.
   Use `.cursor/rules/doc-routing.mdc` as the keyword router.
3. Flag acceptance / gating drift vs product stories — prefer product stories / user
   acceptance over technical inventories (same ideology as `@sync-spec-docs`).
4. Emit a findings summary: path, issue, severity, suggested canonical doc. **Do not**
   auto-edit unless Fix mode applies.

## Fix mode (allowlist only)

Apply edits only when the human approved an allowlist, limited to:

- Dead or wrong hyperlinks you are fixing in place
- Acceptance / gating bullets in the **one** routed canonical product story or thin
  system contract for the topic

Do **not** grow file-tree encyclopedias or duplicate component maps.
One source of truth per topic; edit the canonical doc rather than creating a new file.

## Interface sync (report or allowlisted fix)

- Note when documented API payloads, schemas, or data models disagree with handlers
  or generated types.
- Fix JSDoc/TSDoc only when those files are on the allowlist.

## Output

- Report: findings table or bullets.
- If Fix mode ran: short summary of doc changes + which canonical docs were touched.
