# Batch issue refine — local config

Copy to `.cursor/batch-issue-refine.local.md` in the **consumer** project.
Do not commit product secrets. Add `.cursor/runs/` to the project gitignore
if you do not want run artifacts in git.

```markdown
# Batch issue refine

- **owner:** my-org-or-user
- **project:** 1
- **ready:** Ready
- **min:** 5
- **limit:** 10
- **notes_path:** docs/dogfooding-notes.md
- **artifact_dir:** .cursor/runs/batch-issue-refine
- **competitors:** (optional names the strategy skill should always check)
```

`project` is the GitHub **Project number** (`gh project list --owner …`), not
the repo name. `ready` must match the Status column option exactly.
