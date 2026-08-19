<p align="center">
  <img src="docs/assets/mark.svg" width="64" height="64" alt="cursor-harness">
</p>

# cursor-harness

<p align="center"><strong>A developer’s time is precious. Automate my Workflows. 
Days are for Devs, Nights for the agents.</strong></p>

A **portable**, project-agnostic pack of Cursor **rules**, **skills**, **agents**,
**hooks**, a **night-shift CLI**, and **automation stubs**. Cursor is the current
coding platform. Your **app** stack stays yours. A short **prep** (about 2h max,
anytime) assembles the workpack. **Nightshift** then runs fully autonomously in
the human-created worktrees. You test and ship when you are back.

Required consumer file: [`harness.project.yaml`](templates/harness.project.yaml).

Agents share a root **summary** file, [`project_memory.md`](templates/project_memory.example.md).
After a cycle, human **lessons learned** become scored **Candidates**. Later sessions
load matching rows and bump `help_count` when a lesson actually helped — so the pack
learns what was useful, not only what was written down.

Inspired by:

- [Matt Pocock](https://github.com/mattpocock)
- [Learn Harness Engineering](https://walkinglabs.github.io/learn-harness-engineering/en/)
- [Dexter Horthy — 12-Factor Agents](https://github.com/humanlayer/12-factor-agents)

```bash
git submodule add git@github.com:RaphaelBecker/cursor-harness.git vendor/cursor-harness
cp vendor/cursor-harness/templates/harness.project.yaml harness.project.yaml
./vendor/cursor-harness/install.sh --target . --mode symlink --with-agents
```

Flags and troubleshooting: [docs/install.md](docs/install.md). Product policy stays in
consumer local overrides.

## The big picture

Three stages, **stacked**. Each stage is its own full-width row (left to right).
Zoom-ins: [Workflows](#workflows). Proposed next: [Workflow ideas](#workflow-ideas).
Marks: [legend](#legend).

### 1 · Prep — `/prep`

Anytime. Keep it short (about **2h max**). You create Cursor worktrees. Packet of
questions. **No code.**

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"17px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":35,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  e1["<b>You open worktrees</b><br/>one tree · one feature"]
  e2["<b>Packet grill</b><br/>✦ grill-me<br/>✦ prep"]
  e3["<b>Draft contract</b><br/>.cursor/night-shift/"]
  e4{"<b>Plan OK?</b><br/>◉ HIL<br/>✦ implementation-plan-review"}
  e5(["<b>Approved</b><br/>commits authorized"])
  e1 --> e2 --> e3 --> e4
  e4 -->|Yes| e5
  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef you fill:#3D4554,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class e2,e3 skill
  class e4 hil
  class e5 done
  class e1 you
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

 `[prep](skills/workflows/prep/SKILL.md)`
·  `[grill-me](skills/grill-me/SKILL.md)`
·  `[implementation-plan-review](skills/implementation-plan-review/SKILL.md)`

 you open worktrees
·  plan OK?

**↓ One approved contract per existing worktree**

### 2 · Night fire — `/night-shift`

One local `agent -p` per approved tree. Agents do not create worktrees. Count is
however many trees you prepared (machine-bound; about **3** has been comfortable).

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"17px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":35,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  n0["<b>night-shift fire</b>"]
  n1["<b>Tests, then code</b><br/>✦ execute-approved-plan<br/>◇ verifier"]
  n2["<b>Worktree proof</b><br/>▣ testing"]
  n3["<b>Keep tree clean</b><br/>✦ review-code<br/>✦ blast-radius<br/>✦ sync-spec-docs<br/>◇ Bugbot"]
  n4(["<b>Handoff</b><br/>ready for manual test<br/>decisions.tsv"])
  n0 --> n1 --> n2 --> n3 --> n4
  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef you fill:#3D4554,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class n1,n2,n3 skill
  class n0 you
  class n4 done
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

 `[night-shift](skills/workflows/night-shift/SKILL.md)`
·  `[execute-approved-plan](skills/execute-approved-plan/SKILL.md)`
·  `[review-code](skills/review-code/SKILL.md)`
·  `[blast-radius](skills/blast-radius/SKILL.md)`
·  `[sync-spec-docs](skills/sync-spec-docs/SKILL.md)`
·  `[verifier](agents/verifier.md)`
·  Bugbot

**↓ You test when you are back, then you ship**

### 3 · Review and ship

You trigger ship. Nightshift never merges.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"17px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":35,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  s1["<b>Merge to local main</b><br/>◉ HIL<br/>✦ ship-local<br/>✦ blast-radius"]
  s2["<b>Push, CI, prod</b><br/>◉ HIL<br/>✦ ship-prod<br/>◇ ci-investigator<br/>◇ Bugbot"]
  s3(["<b>Remember</b><br/>✦ project-memory"])
  s1 --> s2 --> s3
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class s1,s2 hil
  class s3 done
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

 `[ship-local](skills/ship-local/SKILL.md)`
·  `[blast-radius](skills/blast-radius/SKILL.md)`
·  `[ship-prod](skills/workflows/ship-prod/SKILL.md)`
·  `[project-memory](skills/project-memory/SKILL.md)`
·  ci-investigator
·  Bugbot
·  merge local
·  ship prod

<p id="legend" align="center">
<img src="docs/assets/legend-skill.svg" height="22" alt="✦ skill"> playbook
&nbsp;·&nbsp;
<img src="docs/assets/legend-hil.svg" height="22" alt="◉ HIL"> you decide
&nbsp;·&nbsp;
<img src="docs/assets/legend-rule.svg" height="22" alt="▣ rule"> always-on
&nbsp;·&nbsp;
<img src="docs/assets/legend-subagent.svg" height="22" alt="◇ subagent"> helper
</p>

Screenshots: full width. Crop (1) the mark + three overview rows + this legend, or (2) any single zoom-in (each chart has a tiny ✦ ◉ ◇ key). Charts are dark-slate cards — they read on GitHub light or dark.

**How parallel work runs**

- **You** create each Cursor **worktree + branch** (one tree, one agent, one feature).
  Agents do not create, switch, or delete worktrees. The night-shift CLI does not
  either. The only exception is `/ship-local`, which you trigger — it may merge this
  feature and remove **this** worktree only.
- **Prep (anytime, about 2h max):** `/prep` packets → you `/implementation-plan-review` →
  you approve. That yes does **not** authorize merge, push, or production. It does
  authorize local commits in that tree.
- **Nightshift:** `night-shift fire` — tests first, smallest code, `testing` ladder
  (**worktree proof** on the feature tree), review, docs, lessons. Fully autonomous
  in those worktrees. Agent **stops** at ready-for-manual-test (or parks
  `BLOCKED.md`). Hard stop never waits for you. Merge-ready = green worktree proof
  (or docs N/A), not idle-main complete.
- **Parallelism:** number of night agents = number of approved worktrees. Bound by
  this machine. About **3** has been comfortable on a laptop — a reference, not a
  cap. If the project declares `slots` in `harness.project.yaml` (scarce test DB),
  **worktree proof** waits for a pool lease only when a listed suite needs it.
  Pure unit/UI must not take a slot. Do not skip tests.
- **After:** `night-shift status` (skim `decisions.tsv`) → you manual-test →
  `/ship-local` (repeat) → one **idle-main complete** on idle local default →
  `/ship-prod`. No force-push. No skipped gates. Do not start complete if another
  worktree still holds a test-pool lease.
- **Summary file:** every handoff writes `## Lessons learned`.
`@project-memory` upserts those into `project_memory.md` and counts `help_count`
when a later cycle actually used the row.

## Contents

| Doc                                             | What it is                                             |
| ----------------------------------------------- | ------------------------------------------------------ |
| [The big picture](#the-big-picture) (this file) | Whole cycle at a glance                                |
| [Legend](#legend) (this file)                   | Skill, HIL, rule, subagent marks                       |
| [Workflows](#workflows) (this file)             | Each named sequence, zoomed in                         |
| [Workflow ideas](#workflow-ideas) (this file)   | Proposed sequences (not installed)                     |
| [docs/architecture.md](docs/architecture.md)    | Portable vs local, layout, install model               |
| [docs/runtime-policy.md](docs/runtime-policy.md)| Local CLI/SDK vs Cursor VMs, Origin, Automations       |
| [docs/install.md](docs/install.md)              | Submodule install, flags, troubleshooting              |
| [docs/rules.md](docs/rules.md)                  | Rule catalog                                           |
| [docs/skills.md](docs/skills.md)                | Skill catalog                                          |
| [docs/agents.md](docs/agents.md)                | Subagents + built-in reviewers                         |
| [docs/hooks.md](docs/hooks.md)                  | Hook catalog                                           |
| [docs/automations.md](docs/automations.md)      | Nightly hygiene stubs (local CLI/SDK)                  |
| [HARNESS.md](HARNESS.md)                        | Agent inventory (one line each) → `.cursor/HARNESS.md` |
| [CONTRIBUTING.md](CONTRIBUTING.md)              | Add a pack                                             |
| [LICENSE](LICENSE)                              | MIT                                                    |

**Templates** (copy into the consumer project, do not edit harness filenames in place):
[`harness.project.yaml`](templates/harness.project.yaml) (required) ·
[AGENTS.md](templates/AGENTS.md) ·
[project_memory.example.md](templates/project_memory.example.md) ·
[doc-routing.local.example.mdc](templates/doc-routing.local.example.mdc) ·
[local-override.example.mdc](templates/local-override.example.mdc) ·
[batch-issue-refine.local.example.md](templates/batch-issue-refine.local.example.md) ·
[night-shift contract](templates/night-shift-contract.example.md) ·
[night decision log](templates/night-shift-decisions.example.tsv) ·
[launchd unit](templates/launchd/com.cursor-harness.night-shift.plist.example)

**Night CLI** (not installed into `.cursor/`): [runtime/night-shift](runtime/night-shift).

**Prompt pack** (installed, not a catalog): [automations/README.md](automations/README.md).

## Workflows

Zoom-ins of [the big picture](#the-big-picture). Start each one in a new agent chat
(`/name` after install). Marks: [legend](#legend). Boxes list **skills** then
**subagents**. Each skill should do **one** job well — orchestrators only sequence.

| Stage   | You want                                    | You type                               |
| ------- | ------------------------------------------- | -------------------------------------- |
| Prep    | Assemble the workpack (packets + approve)   | `/prep`                                |
| Nightshift | Fire / status board                      | `/night-shift` or `runtime/night-shift` |
| 2a      | A new feature in an existing worktree       | `/feature-delivery`                    |
| 2b      | Something already shipped is wrong          | `/bugfix`                              |
| 2c      | One module smell                            | `/architecture-improve`                |
| Optional | Clear GitHub issue texts, no code yet      | `/batch-issue-refine` (`github-board`) |
| 3       | Merge locally, then go to production        | `/ship-local` then `/ship-prod`        |
| 4a      | Faster, less flaky tests                    | `/test-harness-optimize`               |
| 4b      | Hygiene without a feature plan              | Local CLI/SDK (`docs/runtime-policy.md`) |
| Anytime | Cheat sheet, new workflow, pull lab process | `/help` · `/create-workflow` · `/sync` |

---

### 0. Prep — `/prep`

Anytime. About **2h max**. You already opened Cursor worktrees. Packet of
questions (recommended answers filled). You approve contracts. **No code.** CLI
never creates trees.

Fire when the workpack is ready: `./vendor/cursor-harness/runtime/night-shift fire`

Orchestrator: [prep](skills/workflows/prep/SKILL.md)

### 0b. Nightshift — `/night-shift`

Unattended `agent -p` in each approved tree. When you are back: `night-shift status`
then manual tests.

Orchestrator: [night-shift](skills/workflows/night-shift/SKILL.md) ·
CLI: [runtime/night-shift](runtime/night-shift)

---

### 1. Refine issues — `/batch-issue-refine` (optional `github-board` pack)

Take 5–10 GitHub **Ready** issues and make the text unambiguous. **No code.**
You approve twice. One-time [local config](templates/batch-issue-refine.local.example.md).

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  A["<b>Pull Ready issues</b><br/>✦ batch-issue-ingest"]
  B{"<b>Bug or feature?</b><br/>✦ batch-issue-ingest"}
  C["<b>Value and simplest UX</b><br/>✦ market-ux-strategy<br/>✦ value-validator"]
  D{"<b>Keep, cut, or drop?</b><br/>◉ HIL"}
  E["<b>Rewrite the issue</b><br/>✦ issue-text-refiner"]
  F{"<b>Texts look right?</b><br/>◉ HIL"}
  G(["<b>Write to GitHub</b><br/>✦ issue-board-sync"])
  X["<b>Leave the board</b>"]

  A --> B
  B -->|Bug| E
  B -->|Feature| C
  C --> D
  D -->|Drop| X
  D -->|Keep or cut| E
  E --> F
  F -->|Yes| G
  F -->|Not yet| E

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef drop fill:#7A3D4A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class A,B,C,E skill
  class D,F hil
  class G done
  class X drop
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

 `[batch-issue-ingest](skills/batch-issue-ingest/SKILL.md)`
·  `[market-ux-strategy](skills/market-ux-strategy/SKILL.md)`
·  `[value-validator](skills/value-validator/SKILL.md)`
·  `[issue-text-refiner](skills/issue-text-refiner/SKILL.md)`
·  `[issue-board-sync](skills/issue-board-sync/SKILL.md)`

 keep / cut / drop
·  texts look right?

No subagents in this path today (ingest is a script, not an agent).

Orchestrator: [batch-issue-refine](skills/workflows/batch-issue-refine/SKILL.md)

**Improvements**

| Suggestion                                                              | Reuse                           | Add                                                                             |
| ----------------------------------------------------------------------- | ------------------------------- | ------------------------------------------------------------------------------- |
| Split competitor bench from UX mapping — `market-ux-strategy` does both | `doc-routing`, `project-memory` | `competitor-benchmark` (public comps only) · `ux-flow-map` (shortest path only) |
| Fan-out after the list script: one helper per issue body                | `batch-issue-ingest` script     | Cursor `explore` / `generalPurpose`                                             |
| Catch overlapping Ready cards before rewrite                            | issue bodies + labels           | `issue-duplicate-detect` (report only)                                          |
| Ask when bug vs feature is unclear                                      | ingest triage                   | extra HIL, not a new skill                                                      |

---

### 2a. Build a feature — `/feature-delivery`

Plan with you in **prep**, in a worktree **you** created. The agent builds
**only after you approve** (usually after `night-shift fire`).

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  A(["<b>Start</b><br/>◉ HIL<br/>✦ feature-delivery"])
  B["<b>Hard questions</b><br/>✦ project-memory<br/>✦ grill-me<br/>◇ explore"]
  C["<b>Write the plan</b><br/>✦ grill-me"]
  D{"<b>Plan look right?</b><br/>◉ HIL<br/>✦ implementation-plan-review"}
  E["<b>Tests, then the feature</b><br/>✦ execute-approved-plan<br/>✦ generate-bdd-test-spec<br/>◇ verifier"]
  F["<b>Check, review, docs</b><br/>✦ review-code<br/>✦ blast-radius<br/>✦ sync-spec-docs<br/>✦ project-memory<br/>◇ Bugbot<br/>◇ Security Review"]
  G["<b>Merge local</b><br/>◉ HIL<br/>✦ ship-local"]
  H["<b>Ship prod</b><br/>◉ HIL<br/>✦ ship-prod<br/>◇ ci-investigator<br/>◇ Bugbot"]

  A --> B --> C --> D
  D -->|No| C
  D -->|Yes| E --> F --> G --> H

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class A,D,G,H hil
  class B,C,E,F skill
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

 `[feature-delivery](skills/workflows/feature-delivery/SKILL.md)`
·  `[project-memory](skills/project-memory/SKILL.md)`
·  `[grill-me](skills/grill-me/SKILL.md)`
·  `[implementation-plan-review](skills/implementation-plan-review/SKILL.md)`
·  `[execute-approved-plan](skills/execute-approved-plan/SKILL.md)`
·  `[generate-bdd-test-spec](skills/generate-bdd-test-spec/SKILL.md)`
·  `[review-code](skills/review-code/SKILL.md)`
·  `[blast-radius](skills/blast-radius/SKILL.md)`
·  `[sync-spec-docs](skills/sync-spec-docs/SKILL.md)`
·  `[ship-local](skills/ship-local/SKILL.md)`
·  `[ship-prod](skills/workflows/ship-prod/SKILL.md)`

 explore
·  `[verifier](agents/verifier.md)`
·  Bugbot
·  Security Review
·  ci-investigator

 start
·  plan OK?
·  merge local
·  ship prod

**Improvements**

| Suggestion                                                                          | Reuse                                         | Add                                                      |
| ----------------------------------------------------------------------------------- | --------------------------------------------- | -------------------------------------------------------- |
| Keep night execute thin — it already calls other skills; do not grow it             | `execute-approved-plan`, `testing`            | —                                                        |
| Map module smells before a large feature plan                                       | `deep-modules-clean-architecture`, `grill-me` | `/architecture-improve`                                  |
| Default grill to an `explore` subagent instead of the parent walking the whole tree | `grill-me`                                    | Cursor `explore` (already on the chart)                  |
| Show `verifier` in the handoff every time, not only when something fails            | `testing`, `verifier`                         | handoff field, not a skill                               |
| Security Review only when the allowlist is sensitive (already the rule)             | `security-basics`                             | keep off the default path                                |
| New UI must use corporate tokens, not one-off colors or chart palettes              | `code-quality`                                | [Frontend refactor](#frontend-refactor)                  |
| Prefer user-story / acceptance docs over file-tree markdown                         | `doc-routing`, `sync-spec-docs`               | [Docs to user stories](#docs-to-user-stories)            |

---

### 2b. Fix a bug — `/bugfix`

Same shape as a feature. Non-trivial bugs start with a **tight red command**
(`@diagnose-bug`), then the plan. A tiny one-file fix can skip diagnose and
the long plan — only if **you** ask.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  A(["<b>Describe the bug</b><br/>◉ HIL<br/>✦ bugfix"])
  B{"<b>Big or risky?</b><br/>✦ bugfix"}
  R["<b>Tight red command</b><br/>✦ diagnose-bug"]
  C["<b>Questions and plan</b><br/>✦ grill-me<br/>◇ explore"]
  D{"<b>Plan look right?</b><br/>◉ HIL<br/>✦ implementation-plan-review"}
  T{"<b>Skip the long plan?</b><br/>◉ HIL"}
  E["<b>Failing test first</b><br/>✦ execute-approved-plan<br/>◇ verifier"]
  F["<b>Smallest fix</b><br/>✦ execute-approved-plan<br/>◇ verifier"]
  G["<b>Check, review, docs</b><br/>✦ review-code<br/>✦ blast-radius<br/>✦ sync-spec-docs<br/>✦ project-memory<br/>◇ Bugbot<br/>◇ Security Review"]
  H["<b>Ship</b><br/>◉ HIL<br/>✦ ship-local<br/>✦ ship-prod<br/>◇ ci-investigator"]

  A --> B
  B -->|Yes| R --> C --> D
  D -->|No| C
  D -->|Yes| E
  B -->|You ask tiny| T --> E
  E --> F --> G --> H

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class A,D,T,H hil
  class B,C,R,E,F,G skill
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

 `[bugfix](skills/workflows/bugfix/SKILL.md)`
·  `[diagnose-bug](skills/diagnose-bug/SKILL.md)`
·  `[grill-me](skills/grill-me/SKILL.md)`
·  `[implementation-plan-review](skills/implementation-plan-review/SKILL.md)`
·  `[execute-approved-plan](skills/execute-approved-plan/SKILL.md)`
·  `[review-code](skills/review-code/SKILL.md)`
·  `[sync-spec-docs](skills/sync-spec-docs/SKILL.md)`
·  `[project-memory](skills/project-memory/SKILL.md)`
·  `[ship-local](skills/ship-local/SKILL.md)`
·  `[ship-prod](skills/workflows/ship-prod/SKILL.md)`

 explore
·  `[verifier](agents/verifier.md)`
·  Bugbot
·  Security Review
·  ci-investigator

 describe the bug
·  skip the long plan?
·  plan OK?
·  ship

**Improvements**

| Suggestion                                                      | Reuse               | Add                                                                  |
| --------------------------------------------------------------- | ------------------- | -------------------------------------------------------------------- |
| Isolate reproduce from fix — do not hunt and patch in one skill | `bugfix`, `testing` | `@diagnose-bug` (installed)                                          |
| Tell a flake from a product bug before changing code            | `testing`           | `flake-vs-bug` (classify only) → then `flake-hunter` or the fix path |
| CI-only failures start with a log summary                       | `ship-prod`         | `ci-investigator` on the first red box                               |
| Auth/billing/admin bugs always run Security Review              | `security-basics`   | — (already Phase 4c)                                                 |

---

### 2c. One module smell — `/architecture-improve`

Incremental structure work — not a rewrite. You pick **one** smell per run.
Audit first (recent git hot spots, deletion test). Then packet grill and a
contract. Night does one extract or one dependency-direction fix.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  a1["<b>Load context</b><br/>✦ project-memory<br/>▣ doc-routing"]
  a2["<b>Map smells</b><br/>✦ architecture-audit<br/>◇ explore"]
  a3{"<b>Which slice?</b><br/>◉ HIL"}
  a4["<b>Grill and plan</b><br/>✦ grill-me"]
  a5{"<b>Plan OK?</b><br/>◉ HIL<br/>✦ implementation-plan-review"}
  a6["<b>One refactor</b><br/>✦ extract-deep-module<br/>or ✦ dependency-direction-fix"]
  a7["<b>Prove</b><br/>▣ testing<br/>◇ verifier"]
  a8["<b>Review</b><br/>✦ review-code<br/>✦ blast-radius<br/>✦ sync-spec-docs<br/>◇ Bugbot<br/>◇ Security Review"]
  a9(["<b>Remember</b><br/>✦ project-memory"])

  a1 --> a2 --> a3 --> a4 --> a5 --> a6 --> a7 --> a8 --> a9

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class a1,a2,a4,a6,a7,a8 skill
  class a3,a5 hil
  class a9 done
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

 `[architecture-improve](skills/workflows/architecture-improve/SKILL.md)`
·  `[architecture-audit](skills/architecture-audit/SKILL.md)`
·  `[grill-me](skills/grill-me/SKILL.md)`
·  `[implementation-plan-review](skills/implementation-plan-review/SKILL.md)`
·  `[extract-deep-module](skills/extract-deep-module/SKILL.md)`
·  `[dependency-direction-fix](skills/dependency-direction-fix/SKILL.md)`
·  `[review-code](skills/review-code/SKILL.md)`
·  `[blast-radius](skills/blast-radius/SKILL.md)`

 explore
·  `[verifier](agents/verifier.md)`
·  Bugbot
·  Security Review

 which slice?
·  plan OK?

Do **not** add a skill that “improves architecture” in general. Ship stays
`/ship-local` then `/ship-prod`. Sensitive boundary moves wait for Security
Review; do not auto-fix.

---

### 3. Ship — `/ship-local` then `/ship-prod`

Shipping is always **your** call. The agent never pushes or deploys on its own.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  A(["<b>Work is done locally</b>"])
  B["<b>Merge local</b><br/>◉ HIL<br/>✦ ship-local<br/>✦ blast-radius"]
  C["<b>Push and watch CI</b><br/>◉ HIL<br/>✦ ship-prod<br/>◇ ci-investigator"]
  D{"<b>CI red?</b>"}
  E["<b>Fix, then watch again</b><br/>✦ diagnose-bug<br/>✦ bugfix<br/>✦ review-code<br/>◇ Bugbot<br/>◇ verifier"]
  F(["<b>Green — remember</b><br/>✦ project-memory"])

  A --> B --> C --> D
  D -->|Yes| E --> C
  D -->|Green| F

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef you fill:#3D4554,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class A you
  class B,C hil
  class D you
  class E skill
  class F done
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

 `[ship-local](skills/ship-local/SKILL.md)`
·  `[blast-radius](skills/blast-radius/SKILL.md)`
·  `[ship-prod](skills/workflows/ship-prod/SKILL.md)`
·  `[diagnose-bug](skills/diagnose-bug/SKILL.md)`
·  `[bugfix](skills/workflows/bugfix/SKILL.md)`
·  `[review-code](skills/review-code/SKILL.md)`
·  `[project-memory](skills/project-memory/SKILL.md)`

 ci-investigator
·  Bugbot
·  `[verifier](agents/verifier.md)`

 merge local
·  push and watch CI

**Improvements**

| Suggestion                                                              | Reuse            | Add                                                              |
| ----------------------------------------------------------------------- | ---------------- | ---------------------------------------------------------------- |
| Split “watch CI” from “run the deploy command” from Phase 7 memory      | `ship-prod`      | `ci-watch` (report until terminal) — deploy stays in `ship-prod` |
| Name `ci-investigator` on every red run (already optional in the skill) | `ship-prod`      | chart + default, not a new pack agent                            |
| Do not auto-apply Bugbot fixes on default branch                        | Phase 4c policy  | keep HIL                                                         |
| Bump `help_count` only for lessons that helped the CI fix               | `project-memory` | —                                                                |

---

### 4a. Keep tests healthy — `/test-harness-optimize`

Flaky, slow, or thin tests. Never make asserts weaker to go green.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  A(["<b>Tests hurt</b><br/>◉ HIL"])
  B["<b>Find flakes and slowness</b><br/>✦ test-harness-optimize<br/>◇ verifier"]
  C["<b>Harden, keep asserts</b><br/>✦ test-harness-optimize<br/>◇ verifier"]
  D(["<b>Green and honest</b>"])

  A --> B --> C --> D

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class A hil
  class B,C skill
  class D done
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

 `[test-harness-optimize](skills/test-harness-optimize/SKILL.md)`
·  `[verifier](agents/verifier.md)`
·  you start it

**Improvements**

This skill currently does flakes, speed, **and** coverage. Split it — full design:
[Optimize test suite](#optimize-test-suite).

| Suggestion                                                              | Reuse                             | Add                                                                                                       |
| ----------------------------------------------------------------------- | --------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Collect leftover lint / vulns / flake signals on a **green** run        | `testing`, `verifier`             | `green-run-hygiene` (report only)                                                                         |
| One skill per track after that report                                   | `security-basics`, `code-quality` | `lint-debt-fix` · `test-security-findings` · `flake-hunter` · `coverage-gap-fill` · `e2e-merge-redundant` |
| Cut full E2E time by merging overlapping journeys, not by sleeping less | `testing`                         | `e2e-merge-redundant`                                                                                     |
| Never weaken asserts to go green                                        | `testing`                         | keep as a rule                                                                                            |

---

### 4b. Nightly hygiene — local CLI / SDK

Scheduled quality jobs on **this machine** (`launchd` / cron + Cursor CLI or
SDK). Prompt stubs: [automations/README.md](automations/README.md). May open a
**draft PR** for safe test/lint cleanup. Never auth, billing, secrets, or
migrations. Cloud `/automate` is overflow when the laptop is off —
[runtime policy](docs/runtime-policy.md).

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  A(["<b>Create the job</b><br/>◉ HIL"])
  B["<b>Clock or CI fires</b>"]
  C["<b>Local CLI or SDK</b><br/>✦ test-harness-optimize<br/>◇ verifier"]
  D{"<b>Safe to patch?</b>"}
  E(["<b>Draft PR</b>"])
  F(["<b>Report only</b>"])

  A --> B --> C --> D
  D -->|Tests / lint allowlist| E
  D -->|Anything else| F

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef you fill:#3D4554,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class A hil
  class B,D you
  class C skill
  class E,F done
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

 `[test-harness-optimize](skills/test-harness-optimize/SKILL.md)`
·  `[verifier](agents/verifier.md)`
·  you schedule the local job

Catalog: [docs/automations.md](docs/automations.md)

**Improvements**

| Suggestion                                                             | Reuse                                            | Add                                       |
| ---------------------------------------------------------------------- | ------------------------------------------------ | ----------------------------------------- |
| One stub per job — do not let one nightly run lint + flakes + security | existing stubs                                   | map each stub to one new test-suite skill |
| Architecture drift has no scheduled job                                | `architecture-audit`, `review-docs`              | weekly report stub only                   |
| Security scan stays report-only                                        | `security-basics`, Security scan stub            | `test-security-findings` only after HIL   |
| CI failure triage should start with `ci-investigator`                  | CI failure stub                                  | built-in subagent, not a new pack agent   |
| Do not default the stub to `/automate` (Cursor VM)                     | [runtime policy](docs/runtime-policy.md)         | local `agent -p` / SDK; `/automate` overflow only |

---

### Anytime

| You want                                               | You type                                                     |
| ------------------------------------------------------ | ------------------------------------------------------------ |
| What can I run?                                        | `/help` — map: [HARNESS.md](HARNESS.md) · words: `/glossary` |
| Add a new named sequence                               | `/create-workflow`                                           |
| Pull proven process from a live project into this pack | `/sync`                                                      |

---

## Workflow ideas

Not installed. Author with `/create-workflow` when you want them live.
**One job per skill.** Orchestrators only sequence. Subagents fan out report work;
they do not become mega-skills.

| Idea                                                  | You would type          | Point                                                |
| ----------------------------------------------------- | ----------------------- | ---------------------------------------------------- |
| [Optimize test suite](#optimize-test-suite)           | `/optimize-test-suite`  | Honest green runs                                    |
| [Frontend refactor](#frontend-refactor)               | `/frontend-refactor`    | Corporate tokens, one UI family per run              |
| [Docs to user stories](#docs-to-user-stories)         | `/docs-to-user-stories` | Stories + tests; retire tech dupes only when covered |
| [App performance](#app-performance)                   | `/performance-optimize` | Measure, then one hotspot                            |

---

### Optimize test suite

Proposed `/optimize-test-suite`. Successor to `/test-harness-optimize`.
Goal: a **green** run that is also honest — leftover lint, vulns, flakes, thin
coverage, and redundant E2E journeys are treated as debt, not as success.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  u1["<b>Green snapshot</b><br/>✦ green-run-hygiene (new)<br/>◇ verifier"]
  u2["<b>Split the report</b><br/>one skill each · parallel OK<br/>✦ lint-debt-fix (new)<br/>✦ test-security-findings (new)<br/>✦ flake-hunter (new)<br/>✦ coverage-gap-fill (new)<br/>✦ e2e-merge-redundant (new)<br/>◇ Security Review"]
  u3{"<b>Which tracks?</b><br/>◉ HIL"}
  u4["<b>Apply one job</b><br/>only the skills you approved"]
  u5["<b>Prove</b><br/>▣ testing<br/>asserts stay strict<br/>◇ verifier"]
  u6(["<b>Remember</b><br/>✦ project-memory"])

  u1 --> u2 --> u3 --> u4 --> u5 --> u6

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef proposed fill:#4A4578,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7,stroke-dasharray:6 4
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class u4,u5 skill
  class u1,u2 proposed
  class u3 hil
  class u6 done
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

**Reuse**

| Kind        | What                                                                                                                           |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------ |
| Rules       | `testing` (ladder + never weaker asserts) · `security-basics` · `code-quality`                                                 |
| Skills      | `generate-bdd-test-spec` (new coverage cases) · `review-code` · `project-memory` · current `test-harness-optimize` until split |
| Subagents   | `verifier` on snapshot and prove · Security Review on vuln track · Bugbot if a “fix” looks like a product bug                  |
| Automations | Daily test health · lint hygiene · security scan stubs — one stub per new skill later                                          |

**Add** (one job each)

| Skill                    | One job                                                                                                |
| ------------------------ | ------------------------------------------------------------------------------------------------------ |
| `optimize-test-suite`    | Thin orchestrator only                                                                                 |
| `green-run-hygiene`      | On a green run, collect leftover lint, vulns, flake signals, coverage holes, E2E timings — report only |
| `lint-debt-fix`          | Fix lint / static noise from that report                                                               |
| `test-security-findings` | Triage scanner or test vulns; **stop** before product-code fixes                                       |
| `flake-hunter`           | Isolate and harden flakes; never weaker asserts                                                        |
| `coverage-gap-fill`      | Add tests for critical uncovered paths                                                                 |
| `e2e-merge-redundant`    | Merge overlapping E2E cases so the full suite does not repeat the same journey                         |

HIL after the snapshot, before any track writes. Parallel subagents may **fill** the
report; they must not apply five tracks in one pass. `test-harness-optimize` retires
once the orchestrator exists.

---

### Frontend refactor

Proposed `/frontend-refactor`. Catch one-off UI that crept in during feature work
(buttons, charts, spacing, radius, ad-hoc colors) and fold it back into **one**
corporate token set — light and dark, every app frontend.

Tokens (consumer SSOT, not this pack): **background / midground / foreground**
layers; **primary / secondary / tertiary** colors; spacing scale; corner radius.
Charts use those colors only. Components consume shared classes/tokens; they do
not redefine the look locally.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  f1["<b>Load tokens</b><br/>✦ project-memory<br/>▣ consumer design-tokens"]
  f2["<b>Map outliers</b><br/>✦ design-token-audit (new)<br/>◇ explore"]
  f3{"<b>Tokens complete?</b><br/>◉ HIL"}
  f4["<b>Centralize CSS</b><br/>✦ design-token-ssot (new)<br/>light + dark"]
  f5{"<b>Which family?</b><br/>◉ HIL<br/>buttons · charts · one screen"}
  f6["<b>Align one family</b><br/>✦ ui-outlier-align (new)<br/>or ✦ chart-theme-align (new)"]
  f7["<b>Prove</b><br/>▣ testing<br/>◇ verifier"]
  f8(["<b>Remember</b><br/>✦ project-memory"])

  f1 --> f2 --> f3
  f3 -->|No| f4 --> f5
  f3 -->|Yes| f5 --> f6 --> f7 --> f8

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef proposed fill:#4A4578,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7,stroke-dasharray:6 4
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class f1,f7 skill
  class f2,f4,f6 proposed
  class f3,f5 hil
  class f8 done
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

**Reuse**

| Kind      | What                                                                                            |
| --------- | ----------------------------------------------------------------------------------------------- |
| Rules     | `code-quality` · `testing` · `deep-modules-clean-architecture` · `doc-routing`                  |
| Skills    | `project-memory` · `grill-me` · `implementation-plan-review` · `review-code` · `sync-spec-docs` |
| Subagents | `explore` (find one-off CSS/components) · `verifier` (visual/unit if the project has them)      |
| Consumer  | Design-token CSS + a local rule pointing at it (brand does **not** belong in this pack)         |

**Add** (one job each)

| Skill                | One job                                                                                        |
| -------------------- | ---------------------------------------------------------------------------------------------- |
| `frontend-refactor`  | Thin orchestrator only                                                                         |
| `design-token-audit` | Report outliers vs tokens (hard-coded colors, extra radius, one-off buttons/charts) — no edits |
| `design-token-ssot`  | One shared token file: light/dark, layers, primary/secondary/tertiary, spacing, radius         |
| `ui-outlier-align`   | Restyle **one** component family to those tokens (e.g. buttons, not the whole app)             |
| `chart-theme-align`  | Point charts at the same color tokens — no private palettes                                    |

Do **not** add a skill that “fixes the frontend.” One family per run. New features
must consume tokens (call this out in `/feature-delivery` plans). No new hex values
in component files after the SSOT exists.

---

### Docs to user stories

Proposed `/docs-to-user-stories`. Shrink technical markdown. Prefer **user stories
and acceptance** (closer to product design and improvement). **Code** is the
implementation map. **Unit, integration, and E2E tests** are the technical
contract. Thin system contracts stay only where `doc-routing` already allows
(security, money, ingest, critical E2E).

**On the ~20% cap.** Treat it as a **review-size throttle**, not a quality target.
The risky assumption is “coverage might be thin, so always delete only 20%.”
Safer rule: **do not retire a technical doc until tests (or a remaining thin
contract) cover that behavior.** If coverage is already high, a larger slice is
fine. If coverage is thin, the first run may be mostly **writing tests**, not
deleting docs. A small per-run cap still helps reviews stay reviewable.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  d1["<b>Inventory docs</b><br/>✦ doc-inventory (new)<br/>◇ explore"]
  d2["<b>Coverage gate</b><br/>✦ docs-coverage-gate (new)<br/>◇ verifier"]
  d3{"<b>Which slice?</b><br/>◉ HIL<br/>size follows coverage"}
  d4["<b>Fill test holes</b><br/>✦ generate-bdd-test-spec<br/>✦ coverage-gap-fill (new)"]
  d5["<b>Rewrite as stories</b><br/>✦ story-migrate-slice (new)"]
  d6["<b>Retire tech dupes</b><br/>✦ tech-doc-retire (new)<br/>only if tests cover it"]
  d7["<b>Remember</b><br/>✦ project-memory<br/>✦ review-docs"]

  d1 --> d2 --> d3
  d3 -->|Tests missing| d4 --> d5
  d3 -->|Covered| d5 --> d6 --> d7

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef proposed fill:#4A4578,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7,stroke-dasharray:6 4
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class d4,d7 skill
  class d1,d2,d5,d6 proposed
  class d3 hil
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

**Reuse**

| Kind        | What                                                                                         |
| ----------- | -------------------------------------------------------------------------------------------- |
| Rules       | `doc-routing` (product story first) · `testing` · `core-principles`                          |
| Skills      | `review-docs` · `sync-spec-docs` · `generate-bdd-test-spec` · `project-memory`               |
| Subagents   | `explore` (find duplicate inventories) · `verifier` (prove tests still express the behavior) |
| Automations | Spec acceptance drift stub — report story vs code, not more encyclopedia                     |

**Add** (one job each)

| Skill                  | One job                                                                        |
| ---------------------- | ------------------------------------------------------------------------------ |
| `docs-to-user-stories` | Thin orchestrator only                                                         |
| `doc-inventory`        | Classify each doc: story, thin contract, duplicate-of-code, duplicate-of-tests |
| `docs-coverage-gate`   | For each proposed deletion: which tests cover it? Missing → do not delete      |
| `story-migrate-slice`  | Rewrite **one** topic as user story + acceptance                               |
| `tech-doc-retire`      | Remove or shrink technical markdown only after the gate passes                 |

Do **not** add a skill that “rewrites all docs.” Do not delete behavior that has
no test and no remaining contract. `coverage-gap-fill` is listed under
[Optimize test suite](#optimize-test-suite) — reuse it, do not clone it.

---

### App performance

Proposed `/performance-optimize`. Measure first. Then fix **one** slow path:
algorithm, workflow, or SQL. Guessing is not a skill.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"fontFamily":"ui-sans-serif, system-ui, -apple-system, Segoe UI, sans-serif","fontSize":"15px","background":"#2B313C","lineColor":"#9AA6B8","textColor":"#9AA6B8","primaryTextColor":"#E8EEF7","edgeLabelBackground":"#2B313C"},"flowchart":{"curve":"basis","htmlLabels":true,"nodeSpacing":31,"rankSpacing":48,"padding":16,"useMaxWidth":true}}}%%
flowchart LR
  p1["<b>Load context</b><br/>✦ project-memory<br/>▣ doc-routing"]
  p2["<b>Profile</b><br/>✦ perf-profile (new)<br/>◇ explore"]
  p3["<b>Split the report</b><br/>one skill each<br/>✦ slow-query-find (new)<br/>✦ slow-path-find (new)"]
  p4{"<b>Which hotspot?</b><br/>◉ HIL"}
  p5["<b>One fix</b><br/>✦ perf-fix-query (new)<br/>or ✦ perf-fix-hotpath (new)"]
  p6["<b>Prove faster</b><br/>same profiler + ▣ testing<br/>◇ verifier"]
  p7(["<b>Remember</b><br/>✦ project-memory"])

  p1 --> p2 --> p3 --> p4 --> p5 --> p6 --> p7

  classDef skill fill:#3A5F9A,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef proposed fill:#4A4578,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7,stroke-dasharray:6 4
  classDef hil fill:#A34D16,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  classDef done fill:#2A6B5C,stroke:#A8B4C4,stroke-width:1.4px,color:#E8EEF7
  class p1,p6 skill
  class p2,p3,p5 proposed
  class p4 hil
  class p7 done
```

![✦ skill](docs/assets/legend-skill.svg) · ![◉ HIL](docs/assets/legend-hil.svg) · ![◇ subagent](docs/assets/legend-subagent.svg)

**Reuse**

| Kind      | What                                                                                                                                 |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Rules     | `testing` · `code-quality` · `security-basics` (no secrets in traces) · `deep-modules-clean-architecture`                            |
| Skills    | `grill-me` · `implementation-plan-review` · `execute-approved-plan` (if the fix needs a contract) · `review-code` · `project-memory` |
| Subagents | `explore` (find the hot path in code) · `verifier` (ladder still green) · Bugbot if the “faster” change looks like a behavior bug    |
| Consumer  | Profiler / EXPLAIN / APM commands — discover from README, do not invent                                                              |

**Add** (one job each)

| Skill                  | One job                                                        |
| ---------------------- | -------------------------------------------------------------- |
| `performance-optimize` | Thin orchestrator only                                         |
| `perf-profile`         | Capture before numbers (CPU, render, query time) — report only |
| `slow-query-find`      | Rank slow SQL / N+1 / missing indexes — no edits               |
| `slow-path-find`       | Rank slow algorithms and workflows — no edits                  |
| `perf-fix-query`       | One query or index change; prove with the same profiler        |
| `perf-fix-hotpath`     | One algorithm or workflow change; prove with the same profiler |

Do **not** add a skill that “makes the app faster.” No fix without a before
measurement. No “optimize everything we saw.” Ship still `/ship-local` then
`/ship-prod`.

## Quick install

Full flags, clone, CI, troubleshooting: [docs/install.md](docs/install.md).

```bash
git submodule add git@github.com:RaphaelBecker/cursor-harness.git vendor/cursor-harness
cp vendor/cursor-harness/templates/harness.project.yaml harness.project.yaml
./vendor/cursor-harness/install.sh --target . --mode symlink --with-agents
```

Requires `bash`, `python3` (stdlib), and `git`. Default packs: `core`. Add
`--packs core,github-board,market-ux,bdd` when you want those optional sets.

## Layout

```text
cursor-harness/
├── README.md           # workflows + this contents table
├── HARNESS.md          # agent inventory → .cursor/HARNESS.md
├── CONTRIBUTING.md
├── install.sh
├── manifest.yaml       # pack_sets registry
├── runtime/            # night-shift CLI (not copied into .cursor/)
├── rules/              # *.mdc
├── skills/             # SKILL.md packs + workflows/
├── agents/
├── automations/        # prompt stubs
├── hooks/
├── templates/          # harness.project.yaml + consumer copies
└── docs/               # catalogs + architecture + install
```

## License

MIT — [LICENSE](LICENSE).
