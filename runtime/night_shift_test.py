#!/usr/bin/env python3
"""Plan frontmatter status: only the plan's own top-level key counts. Run: python3 runtime/night_shift_test.py"""
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import night_shift as ns  # noqa: E402

TODOS_FIRST = """---
name: Demo
todos:
  - id: a
    content: first --- step
    status: pending
  - id: b
    status: completed
status: approved
commits: authorized
---

# Body
status: approved
"""

STATUS_FIRST = """---
status: approved
todos:
  - id: a
    status: completed
---
body
"""


class PlanStatusTest(unittest.TestCase):
    def test_todo_status_does_not_count_as_plan_status(self):
        self.assertEqual(ns.plan_frontmatter_status(TODOS_FIRST), "approved")
        self.assertEqual(ns.plan_frontmatter_status(STATUS_FIRST), "approved")

    def test_archive_rewrites_only_the_plan_status(self):
        out = ns.replace_frontmatter_status(TODOS_FIRST, "archived")
        self.assertIn("    status: pending\n", out)
        self.assertIn("    status: completed\n", out)
        self.assertIn("\nstatus: archived\ncommits: authorized\n", out)
        self.assertTrue(out.endswith("# Body\nstatus: approved\n"))
        self.assertEqual(ns.plan_frontmatter_status(out), "archived")

    def test_missing_status_is_appended_inside_frontmatter(self):
        out = ns.replace_frontmatter_status("---\nname: x\n---\nbody\n", "archived")
        self.assertEqual(out, "---\nname: x\nstatus: archived\n---\nbody\n")

    def test_archive_plans_touches_approved_plans_only(self):
        with tempfile.TemporaryDirectory() as tmp:
            plans = Path(tmp) / ".cursor/plans"
            plans.mkdir(parents=True)
            (plans / "live.plan.md").write_text(TODOS_FIRST, encoding="utf-8")
            draft = STATUS_FIRST.replace("status: approved", "status: draft")
            (plans / "draft.plan.md").write_text(draft, encoding="utf-8")
            archived = ns.archive_approved_plans(Path(tmp))
            self.assertEqual([p.name for p in archived], ["live.plan.md"])
            self.assertEqual((plans / "draft.plan.md").read_text(encoding="utf-8"), draft)


if __name__ == "__main__":
    unittest.main()
