---
name: batch-issue-ingest
description: >-
  Pull 5–10 GitHub Project issues from the Ready column, attach dogfooding notes,
  and triage each as BUG FIX or NEW FEATURE. Use from /batch-issue-refine or when
  the developer asks to ingest a Ready-column batch. Does not edit issues.
---

# Batch ingest & triage

## Config

From `.cursor/batch-issue-refine.local.md` or the current chat: `owner`,
`project` (number), `ready` (column name, default `Ready`), `notes_path`
(optional).

## Pull

1. Confirm `gh` is authenticated (`gh auth status`). If not, **STOP** and ask
   the human to log in.
2. Run the skill script (prefer installed path):

```bash
python3 .cursor/skills/batch-issue-ingest/scripts/list-ready-issues.py \
  --owner OWNER --project N --ready Ready --min 5 --limit 10
```

Harness checkout fallback: `skills/batch-issue-ingest/scripts/list-ready-issues.py`.

3. If the script fails, show the error; do not guess project numbers.
4. If fewer than 5 Ready items, take all and say so. If more than `--limit`, take
   that many (script order) and note how many remain on the board.
5. For each selected **Issue**, load body + labels:

```bash
gh issue view NUMBER --repo OWNER/REPO --json number,title,body,labels,url,state
```

Skip non-issue project drafts unless the human asks to include them.

## Dogfooding notes

If `notes_path` exists, read it. If unset, ask once to paste notes or skip.
Attach a short “notes that apply” bullet per issue; do not dump the whole file
into every issue.

## Triage

Tag each item **exactly** `BUG FIX` or `NEW FEATURE`:

| `BUG FIX` | Something already shipped behaves wrong |
| `NEW FEATURE` | New behavior, UX, or capability |

If unsure, pick the closer tag and state the doubt in one line — do not leave
untagged.

## Output

Write `00-ingest.md` under the run dir (see local config `artifact_dir`, default
`.cursor/runs/batch-issue-refine/<stamp>/`):

- Batch size, project, Ready column
- Table: `#` · title · tag · notes hit · url
- Routing: bugs → skip strategy/value; features → continue

Do **not** call `gh issue edit`. Return control to `@batch-issue-refine`.
