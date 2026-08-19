# Rules

Always-on or glob-scoped guardrails. Installed to `.cursor/rules/`.
Normative text lives in each `.mdc` file — this page is a catalog only.

| Rule | When | Job | File |
| --- | --- | --- | --- |
| `core-principles` | Always | Lifecycle, prep then nightshift, hard stops, SemVer | [core-principles.mdc](../rules/core-principles.mdc) |
| `developer-communication` | Always | Plain, short talk with the human | [developer-communication.mdc](../rules/developer-communication.mdc) |
| `deep-modules-clean-architecture` | Code globs | Deep modules, clean boundaries | [deep-modules-clean-architecture.mdc](../rules/deep-modules-clean-architecture.mdc) |
| `doc-routing` | On demand | Keyword → which doc to read; product story first | [doc-routing.mdc](../rules/doc-routing.mdc) |
| `code-quality` | Code globs | Architecture + craft defaults | [code-quality.mdc](../rules/code-quality.mdc) |
| `testing` | Code/test globs | Ladder SSOT: worktree proof vs idle-main complete | [testing.mdc](../rules/testing.mdc) |
| `security-basics` | Code globs | Secrets, boundaries, least privilege | [security-basics.mdc](../rules/security-basics.mdc) |

Only `core-principles` and `developer-communication` are `alwaysApply: true`.
File-scoped rules belong in the **consumer** project (new filenames — see
[local-override.example.mdc](../templates/local-override.example.mdc)).

Product keyword maps: copy [doc-routing.local.example.mdc](../templates/doc-routing.local.example.mdc) → `.cursor/rules/doc-routing.local.mdc`.
Project interface: [harness.project.yaml](../templates/harness.project.yaml).
