#!/usr/bin/env python3
"""Classify a beforeShellExecution command for the ship-prod push gate.

Raw `git push` and `gh pr create` / `gh pr merge` need a fresh marker.
npm scripts listed in harness.project.yaml `ship.direct_push` are allowed
only from the primary checkout on branch `main`. Their child `git push`
is not this command, so it is not denied here — only an agent-typed
`git push` (or an equivalent `bash -c` / `eval` / substitution) is.

A fresh marker on the consumer checkout also allows one push from its
vendored harness: `git push origin main` inside `<consumer>/vendor/cursor-harness`,
and only when that updates `main` as a fast-forward (no `--force`).
"""

from __future__ import annotations

import json
import os
import re
import shlex
import subprocess
import sys
from functools import lru_cache
from pathlib import Path

MSG_PUSH = "Pushes/PRs only via /ship-prod; land with /ship-local."
MSG_SCRIPT = "Direct push scripts only from the primary checkout on main."
MARKER_REL = ".cursor/night-shift/ship-prod-push-gate"

WRAPPERS = {"sudo", "time", "nice", "command", "exec", "nohup"}
GIT_WITH_ARG = {
    "-C",
    "--git-dir",
    "--work-tree",
    "-c",
    "--namespace",
    "--config-env",
    "--super-prefix",
    "--list-cmds",
}
GH_WITH_ARG = {"-R", "--repo", "--hostname", "-e", "--env"}


def main() -> None:
    gate = sys.argv[1]
    try:
        data = json.load(sys.stdin)
    except Exception:
        print("ok")
        return
    command = data.get("command") or ""
    cwd = data.get("cwd") or os.getcwd()
    if MARKER_REL in command:
        deny(MSG_PUSH)
        return
    try:
        decision = classify(command, cwd, gate)
    except Exception:
        if re.search(r"(^|[\s;&|(`])git\s+push\b", command) or re.search(
            r"(^|[\s;&|(`])gh\s+pr\s+(create|merge)\b", command
        ):
            deny(MSG_PUSH)
            return
        print("ok")
        return
    if decision:
        deny(decision)
        return
    print("ok")


def deny(message: str) -> None:
    sys.stdout.write("deny\t" + message + "\n")


def classify(command: str, cwd: str, gate: str) -> str | None:
    """Return a deny message, or None when this command is not a gated push."""
    reason: str | None = None
    for segment, effective in segments(command, cwd):
        hit = classify_segment(segment, effective, gate, depth=0)
        reason = prefer(reason, hit)
        if reason == MSG_PUSH:
            return reason
    return reason


def prefer(current: str | None, new: str | None) -> str | None:
    if new == MSG_PUSH or current == MSG_PUSH:
        return MSG_PUSH
    return new or current


def segments(command: str, cwd: str) -> list[tuple[str, str]]:
    parts = split_shell(command)
    stack = [cwd]
    out: list[tuple[str, str]] = []
    for raw in parts:
        pop_after = 0
        while raw.startswith("("):
            stack.append(stack[-1])
            raw = raw[1:].strip()
        while raw.endswith(")") and len(raw) > 1:
            pop_after += 1
            raw = raw[:-1].strip()
        if not raw:
            for _ in range(pop_after):
                if len(stack) > 1:
                    stack.pop()
            continue
        effective = stack[-1]
        words = safe_split(raw)
        words = strip_wrappers(words)
        if words and os.path.basename(words[0]) == "cd" and len(words) >= 2 and not words[1].startswith("-"):
            stack[-1] = join_cwd(effective, words[1])
        else:
            out.append((raw, effective))
        for _ in range(pop_after):
            if len(stack) > 1:
                stack.pop()
    return out


def split_shell(command: str) -> list[str]:
    parts: list[str] = []
    buf: list[str] = []
    i = 0
    n = len(command)
    quote: str | None = None
    while i < n:
        c = command[i]
        if quote:
            buf.append(c)
            if c == "\\" and quote == '"' and i + 1 < n:
                buf.append(command[i + 1])
                i += 2
                continue
            if c == quote:
                quote = None
            i += 1
            continue
        if c in {"'", '"'}:
            quote = c
            buf.append(c)
            i += 1
            continue
        if c == "\\" and i + 1 < n:
            buf.append(command[i + 1])
            i += 2
            continue
        if command.startswith("&&", i) or command.startswith("||", i):
            parts.append("".join(buf))
            buf = []
            i += 2
            continue
        if c in {";", "\n", "|", "&"}:
            parts.append("".join(buf))
            buf = []
            i += 1
            continue
        buf.append(c)
        i += 1
    parts.append("".join(buf))
    return [part.strip() for part in parts if part.strip()]


def safe_split(segment: str) -> list[str]:
    try:
        return shlex.split(segment)
    except ValueError:
        return segment.split()


def strip_wrappers(words: list[str]) -> list[str]:
    while words:
        head = words[0]
        if re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", head):
            words = words[1:]
            continue
        base = os.path.basename(head)
        if base == "sudo":
            words = words[1:]
            while words and words[0].startswith("-"):
                words = words[1:]
            continue
        if base in WRAPPERS:
            words = words[1:]
            continue
        break
    return words


def join_cwd(cwd: str, target: str) -> str:
    target = os.path.expanduser(target)
    if os.path.isabs(target):
        return os.path.normpath(target)
    return os.path.normpath(os.path.join(cwd, target))


def classify_segment(segment: str, cwd: str, gate: str, depth: int) -> str | None:
    if depth > 3:
        return None
    words = strip_wrappers(safe_split(segment))
    if not words:
        return None
    reason: str | None = None

    inner = nested_sources(words)
    for source in inner:
        reason = prefer(reason, classify(source, cwd, gate) if depth == 0 else classify_segment(source, cwd, gate, depth + 1))

    for match in re.finditer(r"\$\((.*?)\)|`([^`]*)`", segment, re.S):
        source = match.group(1) if match.group(1) is not None else match.group(2)
        reason = prefer(reason, classify(source, cwd, gate))

    base = os.path.basename(words[0])
    if base in {"python", "python3", "node"} and "-c" in words:
        idx = words.index("-c")
        if idx + 1 < len(words) and code_invokes_push(words[idx + 1]):
            root = toplevel(cwd)
            if not marker_fresh(gate, root):
                reason = prefer(reason, MSG_PUSH)

    is_push, git_target = scan_git(words)
    if is_push:
        push_path = join_cwd(cwd, git_target) if git_target else cwd
        root = toplevel(push_path)
        if not push_permitted(words, root, gate, push_path):
            reason = prefer(reason, MSG_PUSH)

    if scan_gh_pr(words) and not marker_fresh(gate, toplevel(cwd)):
        reason = prefer(reason, MSG_PUSH)

    script = scan_npm_script(words)
    if script:
        name, prefix = script
        where = join_cwd(cwd, prefix) if prefix else cwd
        reason = prefer(reason, direct_script(name, where, gate, invoked=True))

    where = cwd
    reason = prefer(reason, wrapper_body(words, where))
    return reason


def nested_sources(words: list[str]) -> list[str]:
    if not words:
        return []
    base = os.path.basename(words[0])
    if base == "eval" and len(words) >= 2:
        return [" ".join(words[1:])]
    if base in {"bash", "sh", "zsh", "dash"} and "-c" in words:
        idx = words.index("-c")
        if idx + 1 < len(words):
            return [words[idx + 1]]
    return []


def code_invokes_push(code: str) -> bool:
    if re.search(r"\bgit\s+push\b", code) or re.search(r"\bgh\s+pr\s+(create|merge)\b", code):
        return True
    if re.search(r"""['"]git['"]\s*,\s*['"]push['"]""", code):
        return True
    return bool(
        re.search(r"""['"]gh['"]""", code)
        and re.search(r"""['"]pr['"]\s*,\s*['"](create|merge)['"]""", code)
    )


def scan_git(words: list[str]) -> tuple[bool, str | None]:
    if not words or os.path.basename(words[0]) != "git":
        return False, None
    args = words[1:]
    i = 0
    target: str | None = None
    while i < len(args):
        arg = args[i]
        if arg == "-C" and i + 1 < len(args):
            target = args[i + 1]
            i += 2
            continue
        if arg in GIT_WITH_ARG and arg != "-C":
            i += 2
            continue
        if arg.startswith("--git-dir=") or arg.startswith("--work-tree=") or arg.startswith("--namespace=") or arg.startswith("--config-env="):
            i += 1
            continue
        if arg.startswith("-c") and arg != "-c":
            i += 1
            continue
        if arg.startswith("-") and arg != "--":
            i += 1
            continue
        return arg == "push", target
    return False, target


def scan_gh_pr(words: list[str]) -> bool:
    if not words or os.path.basename(words[0]) != "gh":
        return False
    args = words[1:]
    positional: list[str] = []
    i = 0
    while i < len(args):
        arg = args[i]
        if arg in GH_WITH_ARG and i + 1 < len(args):
            i += 2
            continue
        if arg.startswith("--repo=") or arg.startswith("--hostname="):
            i += 1
            continue
        if arg == "--":
            positional.extend(args[i + 1 :])
            break
        if arg.startswith("-"):
            i += 1
            continue
        positional.append(arg)
        i += 1
    return len(positional) >= 2 and positional[0] == "pr" and positional[1] in {"create", "merge"}


def scan_npm_script(words: list[str]) -> tuple[str, str | None] | None:
    if not words or os.path.basename(words[0]) not in {"npm", "npm.cmd"}:
        return None
    args = words[1:]
    prefix: str | None = None
    i = 0
    while i < len(args):
        arg = args[i]
        if arg == "--prefix" and i + 1 < len(args):
            prefix = args[i + 1]
            i += 2
            continue
        if arg.startswith("--prefix="):
            prefix = arg.split("=", 1)[1]
            i += 1
            continue
        if arg in {"run", "run-script"}:
            i += 1
            while i < len(args):
                arg = args[i]
                if arg == "--":
                    return None
                if arg == "--prefix" and i + 1 < len(args):
                    prefix = args[i + 1]
                    i += 2
                    continue
                if arg.startswith("--prefix="):
                    prefix = arg.split("=", 1)[1]
                    i += 1
                    continue
                if arg.startswith("-"):
                    i += 1
                    continue
                return arg, prefix
            return None
        if arg.startswith("-"):
            i += 1
            continue
        return None
    return None


def direct_script(name: str, where: str, gate: str, invoked: bool) -> str | None:
    del gate, invoked
    root = toplevel(where)
    if not root or name not in direct_names(root):
        return None
    if not primary_main(where):
        return MSG_SCRIPT
    return None


def wrapper_body(words: list[str], where: str) -> str | None:
    """A package.json body that is not itself git/gh is the same gate as npm run.

    Bodies that are `git push` stay raw pushes. The npm script may run that
    git push as a child; this classifier never opens the script file to
    deny that child, because the child is not the agent command.
    """
    root = toplevel(where)
    if not root:
        return None
    names = direct_names(root)
    if not names:
        return None
    pkg = find_package(where)
    if not pkg:
        return None
    try:
        scripts = json.loads(pkg.read_text(encoding="utf-8")).get("scripts") or {}
    except (OSError, json.JSONDecodeError):
        return None
    for name in names:
        body = scripts.get(name)
        if not isinstance(body, str):
            continue
        body_words = strip_wrappers(safe_split(body))
        if not body_words or os.path.basename(body_words[0]) in {"git", "gh"}:
            continue
        if words[: len(body_words)] == body_words:
            if not primary_main(where):
                return MSG_SCRIPT
    return None


def push_permitted(words: list[str], repo: str | None, gate: str, push_path: str) -> bool:
    """True when this push may run.

    A fresh marker on the repo being pushed allows it (force still hits the
    shell guard). Otherwise the only extra allow is a fast-forward
    `git push origin main` of the consumer's vendored cursor-harness while
    the consumer marker is fresh.
    """
    if marker_fresh(gate, repo):
        return True
    if not origin_main_push(words):
        return False
    consumer = vendored_harness_consumer(repo, push_path)
    if not consumer or not marker_fresh(gate, consumer):
        return False
    return main_fast_forward(repo)


def origin_main_push(words: list[str]) -> bool:
    """True only for `git push origin main` (no flags, no other refspec)."""
    sub, args = git_subcommand(words)
    if sub != "push":
        return False
    remote: str | None = None
    refspecs: list[str] = []
    i = 0
    while i < len(args):
        arg = args[i]
        if arg == "--":
            rest = args[i + 1 :]
            if remote is None:
                if not rest:
                    return False
                remote = rest[0]
                refspecs.extend(rest[1:])
            else:
                refspecs.extend(rest)
            break
        if arg.startswith("-") or arg.startswith("+"):
            return False
        if remote is None:
            remote = arg
        else:
            refspecs.append(arg)
        i += 1
    return remote == "origin" and refspecs == ["main"]


def git_subcommand(words: list[str]) -> tuple[str | None, list[str]]:
    if not words or os.path.basename(words[0]) != "git":
        return None, []
    args = words[1:]
    i = 0
    while i < len(args):
        arg = args[i]
        if arg in GIT_WITH_ARG:
            i += 2
            continue
        if (
            arg.startswith("--git-dir=")
            or arg.startswith("--work-tree=")
            or arg.startswith("--namespace=")
            or arg.startswith("--config-env=")
        ):
            i += 1
            continue
        if arg.startswith("-c") and arg != "-c":
            i += 1
            continue
        if arg.startswith("-") and arg != "--":
            i += 1
            continue
        if arg == "--":
            rest = args[i + 1 :]
            if not rest:
                return None, []
            return rest[0], rest[1:]
        return arg, args[i + 1 :]
    return None, []


def vendored_harness_consumer(repo: str | None, push_path: str) -> str | None:
    """Return the consumer toplevel when push_path is its vendor/cursor-harness.

    Match the path the command used (cwd or git -C), not git's toplevel.
    A vendor symlink makes toplevel follow the link, so the real checkout
    often lives outside the consumer. The repository being pushed must still
    be that symlink's checkout.
    """
    if not repo or not push_path:
        return None
    cur = os.path.abspath(push_path)
    for _ in range(12):
        parent = os.path.dirname(cur)
        if os.path.basename(cur) == "cursor-harness" and os.path.basename(parent) == "vendor":
            return _consumer_owning_harness(os.path.dirname(parent), repo)
        if parent == cur:
            break
        cur = parent
    return None


def _consumer_owning_harness(consumer: str, repo: str) -> str | None:
    consumer_top = toplevel(consumer)
    if not consumer_top:
        return None
    if os.path.realpath(consumer_top) != os.path.realpath(consumer):
        return None
    vendored = os.path.join(consumer_top, "vendor", "cursor-harness")
    if not os.path.isdir(vendored):
        return None
    vendored_top = toplevel(vendored)
    if not vendored_top or os.path.realpath(vendored_top) != os.path.realpath(repo):
        return None
    return os.path.realpath(consumer_top)


def main_fast_forward(repo: str | None) -> bool:
    """True when refs/remotes/origin/main is an ancestor of refs/heads/main."""
    if not repo or not os.path.isdir(repo):
        return False
    result = subprocess.run(
        [
            "git",
            "-C",
            repo,
            "merge-base",
            "--is-ancestor",
            "refs/remotes/origin/main",
            "refs/heads/main",
        ],
        capture_output=True,
        text=True,
    )
    return result.returncode == 0


def marker_fresh(gate: str, root: str | None) -> bool:
    if not root:
        return False
    result = subprocess.run(
        ["bash", gate, "fresh", "--root", root],
        capture_output=True,
        text=True,
    )
    return result.returncode == 0


def toplevel(path: str) -> str | None:
    if not path or not os.path.isdir(path):
        return None
    result = subprocess.run(
        ["git", "-C", path, "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip() or None


def primary_main(path: str) -> bool:
    if not path or not os.path.isdir(path):
        return False
    result = subprocess.run(
        [
            "git",
            "-C",
            path,
            "rev-parse",
            "--path-format=absolute",
            "--git-dir",
            "--git-common-dir",
            "--abbrev-ref",
            "HEAD",
        ],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return False
    lines = [line.strip() for line in result.stdout.splitlines() if line.strip()]
    if len(lines) < 3:
        return False
    git_dir, common, branch = lines[0], lines[1], lines[2]
    return os.path.realpath(git_dir) == os.path.realpath(common) and branch == "main"


@lru_cache(maxsize=8)
def direct_names(root: str) -> tuple[str, ...]:
    yaml_path = Path(root) / "harness.project.yaml"
    if not yaml_path.is_file():
        return ()
    runtime = Path(__file__).resolve().parents[2] / "runtime"
    sys.path.insert(0, str(runtime))
    try:
        from project_config import load_yaml_file
    except Exception:
        return ()
    try:
        data = load_yaml_file(yaml_path)
    except Exception:
        return ()
    ship = data.get("ship") or {}
    if not isinstance(ship, dict):
        return ()
    names = ship.get("direct_push") or []
    if isinstance(names, str):
        names = [names]
    if not isinstance(names, list):
        return ()
    return tuple(str(name) for name in names if isinstance(name, str) and name)


def find_package(start: str) -> Path | None:
    cur = Path(start).resolve()
    root = toplevel(start)
    while True:
        cand = cur / "package.json"
        if cand.is_file():
            return cand
        if root and cur == Path(root):
            return None
        if cur.parent == cur:
            return None
        cur = cur.parent


if __name__ == "__main__":
    main()
