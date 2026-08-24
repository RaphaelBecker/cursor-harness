# Hooks

Scripts that run around agent events. Source: `hooks/scripts/` + `hooks/hooks.json`.
Installed to `.cursor/hooks/` and merged into `.cursor/hooks.json` (harness entries
keyed by `command` path; project hooks are kept). Merge policy:
[architecture](architecture.md#hooks-merge-policy).

| Hook | Event | Job | File |
| --- | --- | --- | --- |
| `session-bootstrap` | `sessionStart` | Lifecycle / skills reminder | [session-bootstrap.sh](../hooks/scripts/session-bootstrap.sh) |
| `protect-secrets-prompt` | `beforeSubmitPrompt` | Secret-pattern guard | [protect-secrets-prompt.sh](../hooks/scripts/protect-secrets-prompt.sh) |
| `guard-destructive-shell` | `beforeShellExecution` | Confirm destructive DB, force-push to main/master, `gh issue edit` / close / delete | [guard-destructive-shell.sh](../hooks/scripts/guard-destructive-shell.sh) |

`guard-destructive-shell` is `failClosed: true`. Scripts need `python3` on `PATH` in
the developer environment.

Consumer-owned `afterFileEdit` autofix is **not** installed by the harness. Copy
[templates/hooks/autofix.example.sh](../templates/hooks/autofix.example.sh) and add
an `afterFileEdit` entry in project `hooks.json`. Install merges by `command` path
and leaves that entry alone.

How to add one: [CONTRIBUTING.md](../CONTRIBUTING.md#add-a-hook).
