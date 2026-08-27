#!/usr/bin/env python3
"""Discover human-created worktrees, fire one local Cursor agent each, report status.

Never creates, switches, or deletes git worktrees. Humans create Cursor worktrees.
Do not pass '&' to `agent` (that is Cursor cloud handoff).
"""
from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path
from typing import Any

_RUNTIME = Path(__file__).resolve().parent
if str(_RUNTIME) not in sys.path:
    sys.path.insert(0, str(_RUNTIME))

from project_config import (
    check_project,
    default_executor,
    load_project,
    project_yaml_path,
)

NIGHT_DIR = Path(".cursor") / "night-shift"
CONTRACT_NAME = "contract.md"
BLOCKED_NAME = "BLOCKED.md"
STATUS_NAME = "status.json"
PID_NAME = "agent.pid"
LOG_NAME = "agent.log"
HANDOFF_NAME = "HANDOFF.md"
DECISIONS_NAME = "decisions.tsv"
DECISION_TAIL = 5


def night_dir(worktree: Path) -> Path:
    return worktree / NIGHT_DIR


def contract_path(worktree: Path) -> Path:
    return night_dir(worktree) / CONTRACT_NAME


def blocked_path(worktree: Path) -> Path:
    return night_dir(worktree) / BLOCKED_NAME


def pid_path(worktree: Path) -> Path:
    return night_dir(worktree) / PID_NAME


def log_path(worktree: Path) -> Path:
    return night_dir(worktree) / LOG_NAME


def parse_frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---"):
        return {}
    parts = text.split("---", 2)
    if len(parts) < 3:
        return {}
    meta: dict[str, str] = {}
    for raw in parts[1].splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or ":" not in line:
            continue
        key, value = line.split(":", 1)
        meta[key.strip().lower()] = value.strip().strip("\"'")
    return meta


def contract_status(worktree: Path) -> str:
    path = contract_path(worktree)
    if not path.is_file():
        return "missing"
    meta = parse_frontmatter(path.read_text(encoding="utf-8"))
    status = (meta.get("status") or "").lower()
    if status in {"approved", "draft", "blocked"}:
        return status
    if (meta.get("approved") or "").lower() in {"true", "yes"}:
        return "approved"
    return "draft"


def list_worktrees(repo: Path) -> list[dict[str, str]]:
    proc = subprocess.run(
        ["git", "-C", str(repo), "worktree", "list", "--porcelain"],
        check=False,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        err = (proc.stderr or "").strip()
        if "not a git repository" in err:
            raise RuntimeError(
                f"{repo} is not a git repository. night-shift only discovers existing "
                "git worktrees (humans create Cursor worktrees)."
            )
        raise RuntimeError(err or "git worktree list failed")
    trees: list[dict[str, str]] = []
    current: dict[str, str] = {}
    for line in proc.stdout.splitlines():
        if line.startswith("worktree "):
            if current:
                trees.append(current)
            current = {"path": line.split(" ", 1)[1]}
        elif line.startswith("branch "):
            current["branch"] = line.split(" ", 1)[1]
        elif line.startswith("HEAD "):
            current["head"] = line.split(" ", 1)[1]
        elif line == "bare":
            current["bare"] = "1"
        elif line == "detached":
            current["detached"] = "1"
        elif not line and current:
            trees.append(current)
            current = {}
    if current:
        trees.append(current)
    return [t for t in trees if t.get("path") and not t.get("bare")]


def pid_running(pid: int) -> bool:
    try:
        os.kill(pid, 0)
    except OSError:
        return False
    return True


def read_pid(worktree: Path) -> int | None:
    path = pid_path(worktree)
    if not path.is_file():
        return None
    try:
        pid = int(path.read_text(encoding="utf-8").strip())
    except ValueError:
        return None
    if pid_running(pid):
        return pid
    path.unlink(missing_ok=True)
    return None


def last_decision_rows(worktree: Path, n: int = DECISION_TAIL) -> list[str]:
    path = night_dir(worktree) / DECISIONS_NAME
    if not path.is_file():
        return []
    lines = [
        line.rstrip("\n")
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if not lines:
        return []
    body = lines[1:] if lines[0].startswith("ts\t") else lines
    return body[-n:]


def worktree_state(worktree: Path) -> str:
    if blocked_path(worktree).is_file():
        return "blocked"
    if read_pid(worktree) is not None:
        return "running"
    handoff = night_dir(worktree) / HANDOFF_NAME
    if handoff.is_file():
        text = handoff.read_text(encoding="utf-8").lower()
        if "ready-for-manual-test" in text or "manual test" in text:
            return "ready-for-manual-test"
        return "handoff"
    status = contract_status(worktree)
    if status == "approved":
        return "ready-to-fire"
    if status == "missing":
        return "no-contract"
    return status


def discover(repo: Path) -> list[dict[str, str]]:
    rows = []
    for tree in list_worktrees(repo):
        path = Path(tree["path"])
        rows.append(
            {
                "path": str(path),
                "branch": tree.get("branch", ""),
                "contract": contract_status(path),
                "state": worktree_state(path),
            }
        )
    return rows


def _slot_script(target: Path, project: dict[str, Any], key: str) -> str | None:
    slots = project.get("slots")
    if not isinstance(slots, dict):
        return None
    raw = str(slots.get(key) or "").strip()
    if not raw:
        return None
    return raw if os.path.isabs(raw) else str(target / raw)


def builtin_live_holders(target: Path) -> list[Path]:
    slot_root = target / NIGHT_DIR / "slots"
    live: list[Path] = []
    if not slot_root.is_dir():
        return live
    for holder in slot_root.glob("*.pid"):
        try:
            pid = int(holder.read_text(encoding="utf-8").strip())
        except ValueError:
            continue
        if pid_running(pid):
            live.append(holder)
    return live


def has_live_leases(target: Path, project: dict[str, Any]) -> bool:
    """True when another worktree holds a shared test-pool slot.

    Prefer `<slots.status|slots.lease> has-live-leases`: exit 0 = live,
    exit 1 = idle. `/ship-prod` waits (bounded) when live. Any other exit
    falls back to built-in pid holders.
    """
    cmd = _slot_script(target, project, "status") or _slot_script(target, project, "lease")
    if cmd:
        proc = subprocess.run(
            [cmd, "has-live-leases"],
            cwd=str(target),
            capture_output=True,
            text=True,
            check=False,
        )
        if proc.returncode == 0:
            return True
        if proc.returncode == 1:
            return False
    return bool(builtin_live_holders(target))


def acquire_slot(target: Path, project: dict[str, Any], worktree: Path) -> None:
    slots = project.get("slots")
    if not isinstance(slots, dict) or not slots:
        return
    # Custom lease is a test-pool script: acquire at worktree proof, not at fire.
    if _slot_script(target, project, "lease"):
        return
    count = int(slots.get("count") or 0)
    if count < 1:
        return
    # Built-in file lock pool when count is set without a custom lease command.
    slot_root = target / NIGHT_DIR / "slots"
    slot_root.mkdir(parents=True, exist_ok=True)
    deadline = time.time() + 6 * 3600
    while time.time() < deadline:
        held = 0
        for holder in slot_root.glob("*.pid"):
            try:
                pid = int(holder.read_text(encoding="utf-8").strip())
            except ValueError:
                holder.unlink(missing_ok=True)
                continue
            if pid_running(pid):
                held += 1
            else:
                holder.unlink(missing_ok=True)
        if held < count:
            (slot_root / f"{os.getpid()}-{worktree.name}.pid").write_text(
                f"{os.getpid()}\n", encoding="utf-8"
            )
            return
        time.sleep(5)
    raise RuntimeError("timed out waiting for a test slot")


def fire_one(
    target: Path,
    project: dict[str, Any],
    worktree: Path,
    *,
    dry_run: bool,
) -> str:
    state = worktree_state(worktree)
    if state == "blocked":
        return f"skip blocked: {worktree}"
    if state == "running":
        return f"skip running: {worktree}"
    if contract_status(worktree) != "approved":
        return f"skip (no approved contract): {worktree}"

    night_dir(worktree).mkdir(parents=True, exist_ok=True)
    blocked_path(worktree).unlink(missing_ok=True)
    executor = default_executor(project)
    command = executor["command"]
    if shutil.which(command) is None and not dry_run:
        raise RuntimeError(
            f"{command!r} is not on PATH — install Cursor CLI or set executor.command"
        )
    argv = [command, "-p", executor["prompt"]]
    if executor["model"]:
        argv.extend(["--model", executor["model"]])
    if dry_run:
        return f"DRY-RUN: cwd={worktree} {' '.join(argv)}"

    acquire_slot(target, project, worktree)
    log = log_path(worktree)
    env = os.environ.copy()
    env["CURSOR_HARNESS_UNATTENDED"] = "1"
    env["CURSOR_HARNESS_NIGHT_SHIFT"] = "1"
    handle = log.open("ab")
    proc = subprocess.Popen(
        argv,
        cwd=str(worktree),
        env=env,
        stdout=handle,
        stderr=subprocess.STDOUT,
        start_new_session=True,
    )
    pid_path(worktree).write_text(f"{proc.pid}\n", encoding="utf-8")
    return f"fired pid={proc.pid} cwd={worktree} log={log}"


def cmd_check(target: Path, harness_root: Path) -> int:
    errors = check_project(target, harness_root=harness_root)
    if errors:
        print("harness.project.yaml check failed:", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1
    print(f"ok: {project_yaml_path(target)}")
    return 0


def cmd_discover(target: Path) -> int:
    rows = discover(target)
    if not rows:
        print("no git worktrees found")
        return 0
    print(f"{'state':<24} {'contract':<12} path")
    for row in rows:
        print(f"{row['state']:<24} {row['contract']:<12} {row['path']}")
    print(
        "\nHumans create Cursor worktrees. This CLI never runs git worktree add. "
        "Night agents = prepared trees with status: approved. "
        "About 3 parallel runs has been comfortable on a laptop — not a harness cap."
    )
    return 0


def cmd_fire(target: Path, *, dry_run: bool) -> int:
    errors = check_project(target)
    if errors:
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1
    project = load_project(target)
    rows = discover(target)
    approved = [Path(r["path"]) for r in rows if r["contract"] == "approved"]
    if not approved:
        print(
            "nothing to fire: no worktree has .cursor/night-shift/contract.md with status: approved",
            file=sys.stderr,
        )
        print(
            "Create Cursor worktrees yourself, run /prep, then fire.",
            file=sys.stderr,
        )
        return 1
    for tree in approved:
        print(fire_one(target, project, tree, dry_run=dry_run))
    return 0


def cmd_status(target: Path) -> int:
    rows = discover(target)
    ready = blocked = running = other = 0
    print(f"{'state':<24} path")
    for row in rows:
        state = row["state"]
        if state == "ready-for-manual-test" or state == "handoff":
            ready += 1
        elif state == "blocked":
            blocked += 1
        elif state == "running":
            running += 1
        else:
            other += 1
        extra = ""
        bp = blocked_path(Path(row["path"]))
        if bp.is_file():
            first = bp.read_text(encoding="utf-8").strip().splitlines()
            if first:
                extra = f"  — {first[0][:80]}"
        print(f"{state:<24} {row['path']}{extra}")
        for decision in last_decision_rows(Path(row["path"])):
            print(f"  {decision}")
    print(
        f"\nready-for-manual-test/handoff={ready}  blocked={blocked}  "
        f"running={running}  other={other}"
    )
    print("After Nightshift: skim decisions.tsv + manual-test the ready trees, then /ship-local per tree.")
    return 0


def cmd_slots_status(target: Path) -> int:
    """Exit 0 if another worktree holds a test-pool slot (STOP); 1 if idle."""
    errors = check_project(target)
    if errors:
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 2
    project = load_project(target)
    live = has_live_leases(target, project)
    holders = builtin_live_holders(target)
    if live:
        extra = f" ({len(holders)} built-in pid holder(s))" if holders else ""
        print(f"live{extra}")
        return 0
    print("idle")
    return 1


def harness_root_from_file() -> Path:
    return Path(__file__).resolve().parent.parent


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Night-shift CLI — fire local Cursor agents in existing worktrees"
    )
    parser.add_argument("--target", default=".", help="consumer project root (git repo)")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("check", help="validate harness.project.yaml")
    sub.add_parser("discover", help="list existing git worktrees and contract state")
    fire = sub.add_parser("fire", help="start one local agent per approved worktree")
    fire.add_argument("--dry-run", action="store_true")
    sub.add_parser("status", help="morning board")
    sub.add_parser(
        "slots-status",
        help="exit 0 if another worktree holds a test-pool slot (live); 1 if idle",
    )

    args = parser.parse_args(argv)
    target = Path(args.target).resolve()
    try:
        if args.cmd == "check":
            return cmd_check(target, harness_root_from_file())
        if args.cmd == "discover":
            return cmd_discover(target)
        if args.cmd == "fire":
            return cmd_fire(target, dry_run=args.dry_run)
        if args.cmd == "status":
            return cmd_status(target)
        if args.cmd == "slots-status":
            return cmd_slots_status(target)
    except RuntimeError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
