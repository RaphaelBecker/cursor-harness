# Rules

Always-on (or glob-scoped) guardrails. Installed to `.cursor/rules/`.
Normative text lives in each `.mdc` file — this page is a catalog only.

| Rule | Job | File |
| --- | --- | --- |
| `core-principles` | Lifecycle, day/night, hard stops, SemVer | [core-principles.mdc](../rules/core-principles.mdc) |
| `deep-modules-clean-architecture` | Deep modules, clean boundaries | [deep-modules-clean-architecture.mdc](../rules/deep-modules-clean-architecture.mdc) |
| `doc-routing` | Keyword → which doc to read; product story first | [doc-routing.mdc](../rules/doc-routing.mdc) |
| `developer-communication` | Plain, short talk with the human | [developer-communication.mdc](../rules/developer-communication.mdc) |
| `code-quality` | Architecture + craft defaults | [code-quality.mdc](../rules/code-quality.mdc) |
| `testing` | Verification ladder SSOT, gates, bug regression | [testing.mdc](../rules/testing.mdc) |
| `security-basics` | Secrets, boundaries, least privilege | [security-basics.mdc](../rules/security-basics.mdc) |

All of these are `alwaysApply: true`. File-scoped rules belong in the **consumer** project (new filenames — see [local-override.example.mdc](../templates/local-override.example.mdc)).

Product keyword maps: copy [doc-routing.local.example.mdc](../templates/doc-routing.local.example.mdc) → `.cursor/rules/doc-routing.local.mdc`.
