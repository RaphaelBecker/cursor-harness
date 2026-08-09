# Cursor Automations (prompt pack)

Repo stubs only. **Create live Automations in the Agents Window** with `/automate` after
these prompts are committed. Do not invent MCP server names.

Enable **Memories** on recurring runs so they can improve across days. Memories must
**not** override the hard deny list below.

## Safety

### Draft PR allowlist

May open a **draft PR** only when changes stay inside:

- Test files under the project's test trees
- Obvious unused exports proven by a dead-code tool + green targeted tests
- Autofix-safe lint edits
- Flake hardening with before/after evidence

### Hard deny (report only — never auto-code)

- Migrations / auth / access-control policy
- Billing / payments
- Env / secrets
- Broad product refactors
- Money-math or other high-risk domain cores the project marks as deny-listed locally

---

## Cadence

| Cadence | Job | Output |
| --- | --- | --- |
| Weekday nightly | Daily test health | Draft PR allowlist: tests only |
| Weekday nightly | Lint autofix-safe | Draft PR lint-safe only |
| On CI failed | CI triage | Prefer `gh run rerun --failed` for flakes; draft PR only test/flake allowlist |
| 2–3×/week | Dead-code hygiene | Draft PR only proven unused + green targeted tests |
| Weekly | Security scan | Report only |
| Weekly | Spec acceptance drift | Report: recent code vs routed acceptance docs |
| Weekly | Harness + doc-routing integrity | Report: skills/rules not in HARNESS; dead routed paths |

**Activate first (human):** Daily test health → Lint hygiene → CI failure triage.

---

## Stubs

### 1) Daily test health

- **Trigger:** cron weekdays (nightly; pick time in UI)
- **Output:** draft PR if allowlisted; else comment/report
- **Paste prompt:**

```text
You are the project's daily test-health agent.

Goal: find flaky or slow tests and harden them without weakening assertions.

Rules:
- Draft PR only for test-file changes (or flake-hardening with before/after evidence).
- Never weaken or delete meaningful assertions.
- Never touch migrations, auth, billing, secrets, or other hard-deny surfaces.
- Prefer deterministic waits, better fixtures, and narrower tests over sleeps.
- Follow .cursor/skills/test-harness-optimize/SKILL.md and .cursor/rules/testing.mdc.

Steps:
1. Identify flaky or slow suites from recent CI/local signals if available.
2. Make the smallest test/harness fix.
3. Prove with targeted rerun of the failing/slow tests.
4. If allowlisted and proven, open a draft PR with before/after evidence.
5. Otherwise post a short report only.
```

### 2) Dead code hygiene

- **Trigger:** cron 2–3×/week
- **Output:** draft PR if unused export is proven and tests stay green
- **Prompt idea:** Run the project's dead-code tool when present; remove only clear dead
  exports; do not delete public API without evidence; stay inside draft-PR allowlist;
  hard deny applies.

### 3) Lint / type hygiene

- **Trigger:** cron weekdays (nightly)
- **Output:** draft PR for autofix-safe lint only
- **Paste prompt:**

```text
You are the project's lint hygiene agent.

Goal: apply autofix-safe lint cleanups only.

Rules:
- Draft PR only for autofix-safe lint edits.
- Do not suppress rules or raise max-warnings to hide debt.
- Do not touch migrations, auth, billing, secrets, or other hard-deny surfaces.
- Prefer leaving a report if a fix needs judgment.

Steps:
1. Run the repo's lint path (or equivalent safe autofix).
2. Stage only autofix-safe changes.
3. If non-empty and safe, open a draft PR summarizing files touched.
4. Otherwise report "no safe autofixes".
```

### 4) Security scan

- **Trigger:** cron weekly
- **Output:** **report only**
- **Prompt idea:** Use Security Review patterns (`/review-security`); summarize
  High/Medium findings; no auto fixes.

### 5) Spec acceptance drift

- **Trigger:** cron weekly
- **Output:** **report only**
- **Prompt idea:** Compare recent code changes to routed product-story / acceptance docs
  via `doc-routing`; list gaps; do not edit unless a human opens a contract.

### 6) Harness + doc-routing integrity

- **Trigger:** cron weekly
- **Output:** **report only**
- **Prompt idea:** Check skills/rules/agents/workflows against `.cursor/HARNESS.md`;
  flag dead routed paths in `doc-routing` (+ local overrides); no auto edits.

### 7) CI failure triage

- **Trigger:** git CI completed (failed)
- **Output:** diagnose; draft PR only for flake/test allowlist fixes
- **Prompt idea:** Prefer `gh run rerun --failed` for pure flakes; fix real failures with
  evidence; never weaken gates.

---

## Human checklist after commit

1. Open Agents → Automations (or run `/automate`).
2. Create each stub you want live; paste the prompt idea; set trigger + output.
3. Keep draft-PR allowlist and hard deny in the automation prompt.
4. When you add/change a stub, update `.cursor/HARNESS.md` in the same change.
