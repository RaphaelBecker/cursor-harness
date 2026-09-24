#!/usr/bin/env python3
"""List project_memory.md Candidates rows whose fix may now live in code, docs,
scripts, tests, or a skill, with the commit or file that resolved them.

Report only. The agent reads the evidence and deletes the rows that can no longer
recur; rows that still guide future work stay.

Usage: python3 .cursor/skills/project-memory/prune-candidates.py [--root DIR] [--memory FILE]

Signals per row (strongest first):
  owner    lesson says "Owned by <file>" or "Stale:" (retired audit rows)
  commit   a commit message names the row id (e.g. "... (resolves <id>)")
  file     a tracked file outside the memory file names the row id
  none     no evidence: keep unless a human says otherwise
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

HARNESS_ROOT = Path(__file__).resolve().parents[2]


def git(repo: Path, *args: str) -> str:
    try:
        return subprocess.run(
            ["git", "-C", str(repo), *args], capture_output=True, text=True, check=False
        ).stdout
    except OSError:
        return ""


def candidate_rows(text: str) -> list[dict[str, str]]:
    rows, header = [], None
    for line in text.splitlines():
        if not line.startswith("|"):
            header = None if not line.strip() else header
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if cells and cells[0] == "id":
            header = cells
            continue
        if header and not set(cells[0]) <= {"-", " "} and len(cells) == len(header):
            rows.append(dict(zip(header, cells)))
    return rows


def evidence(row: dict[str, str], repos: list[Path], memory_name: str) -> tuple[str, str]:
    lesson, rid = row.get("lesson", ""), row["id"]
    owned = re.search(r"Owned by (.+?)(?:\.\s*$|$)", lesson)
    if owned:
        return "owner", owned.group(1)
    if lesson.startswith("Stale:"):
        return "owner", lesson
    for repo in repos:
        log = git(repo, "log", "-1", "--format=%h %s", "-F", f"--grep={rid}")
        if log.strip():
            return "commit", f"{repo.name}@{log.strip()}"
    for repo in repos:
        hits = [
            f
            for f in git(repo, "grep", "-l", "-F", rid).splitlines()
            if Path(f).name != memory_name and "/plans/" not in f and not f.startswith("plans/")
        ]
        if hits:
            return "file", f"{repo.name}:{', '.join(hits[:3])}"
    return "none", "-"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", default=".")
    parser.add_argument("--memory", default="project_memory.md")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    memory = root / args.memory
    if not memory.is_file():
        print(f"no {memory}", file=sys.stderr)
        return 1
    repos = [root] + ([HARNESS_ROOT] if HARNESS_ROOT != root and (HARNESS_ROOT / ".git").exists() else [])
    rows = candidate_rows(memory.read_text(encoding="utf-8"))
    print("| id | status | signal | resolved by |")
    print("| --- | --- | --- | --- |")
    counts: dict[str, int] = {}
    for row in rows:
        signal, where = evidence(row, repos, memory.name)
        counts[signal] = counts.get(signal, 0) + 1
        print(f"| {row['id']} | {row.get('status', '?')} | {signal} | {where} |")
    summary = " · ".join(f"{k}: {v}" for k, v in sorted(counts.items()))
    print(f"\nrows: {len(rows)} · {summary}")
    print("Prune rows whose fix is built in (owner/commit/file, after checking it); keep lessons that still guide work.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
