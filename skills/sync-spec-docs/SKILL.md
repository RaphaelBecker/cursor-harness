---
name: sync-spec-docs
description: >-
  Update the matching canonical specification or architecture document after a
  code change. Auto-invoke as the mandatory Phase 5 step of every approved
  feature and bug-fix execution.
---

# Sync spec docs

Update docs in the same area you changed before considering the task done. Use
`.cursor/rules/doc-routing.mdc` (and any project-local doc-routing override) to
find the canonical doc by keyword.

## Mapping

Resolve the canonical file from `doc-routing` defaults or the consumer's local
keyword table. Typical destinations:

- Feature / API / UX contracts → `docs/specs/` or equivalent
- System structure / data flow → `docs/architecture/` or equivalent
- Backend / frontend / database → matching docs roots when present
- Release-facing behavior → `CHANGELOG.md` (or project changelog) when used

If no row matches, search under `docs/` and `README.md` for the closest SSOT.

## Rules

- Edit the existing canonical doc; do not create a new file unless the topic is
  genuinely new (see doc-routing ideology).
- One source of truth per topic. Remove obsolete instructions instead of
  duplicating.
- Fix dead links you touch; keep counts/inventories accurate when present.
- Do not invent a new top-level docs tree for a project that already has one.
