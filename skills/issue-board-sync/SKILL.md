---
name: issue-board-sync
description: >-
  Build a unified preview of refined GitHub issue bodies and a gh issue edit
  script. Run the script only after explicit human HIL 2 approval. Use from
  /batch-issue-refine or when the developer asks to sync refined issue texts
  to the board.
---

# Alignment preview & board sync

## Preview (always)

1. Write `02-preview.md` in the run dir: every issue’s `#`, title, tag, then
   the full refined body.
2. Write `03-sync.sh` that updates **body only** (title only if the human
   already approved a title change):

```bash
#!/usr/bin/env bash
set -euo pipefail
# repo defaults from gh; override with --repo when ingest recorded one
gh issue edit NUMBER --repo OWNER/REPO --body-file bodies/NUMBER.md
```

3. Make the script executable. Show the human where both files live.
4. **STOP** for HIL 2. Do not execute.

## Execute (only after the human says to overwrite / execute / sync)

1. Re-read HIL 2 confirmation in this chat. If missing, **STOP**.
2. Run `03-sync.sh` from the run dir.
3. Report each issue URL and a one-line ok/fail.
4. Do not change Project columns, labels, or close `DISCARD` items unless the
   human explicitly asked in the same confirmation.

Discarded issues stay on the board as-is unless the human asked to close them.
