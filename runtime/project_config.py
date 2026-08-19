#!/usr/bin/env python3
"""Load harness.project.yaml, validate the consumer interface, resolve pack sets."""
from __future__ import annotations

import argparse
import os
import re
import shlex
import sys
from pathlib import Path
from typing import Any

ISSUE_SOURCES = {"github", "files", "none"}
KNOWN_PACKS = ("core", "github-board", "market-ux", "bdd")
CODE_GLOBS_HINT = "core-principles + developer-communication are always-on; other rules load on globs / skills"


class YamlError(ValueError):
    pass


def parse_simple_yaml(text: str) -> Any:
    """Indent-based YAML subset: maps, lists, scalars. No anchors or tags."""
    lines: list[tuple[int, str]] = []
    for raw in text.splitlines():
        stripped = raw.split("#", 1)[0].rstrip()
        if not stripped.strip():
            continue
        indent = len(stripped) - len(stripped.lstrip(" "))
        if "\t" in raw[:indent]:
            raise YamlError("tabs are not allowed in indentation")
        lines.append((indent, stripped.strip()))
    value, _ = _parse_block(lines, 0, 0)
    return value if value is not None else {}


def _parse_scalar(token: str) -> Any:
    if token in ("", "~", "null", "Null", "NULL"):
        return None
    if token in ("true", "True", "TRUE", "yes", "Yes"):
        return True
    if token in ("false", "False", "FALSE", "no", "No"):
        return False
    if re.fullmatch(r"-?\d+", token):
        return int(token)
    if (token.startswith('"') and token.endswith('"')) or (
        token.startswith("'") and token.endswith("'")
    ):
        return token[1:-1]
    return token


def _parse_block(lines: list[tuple[int, str]], i: int, indent: int) -> tuple[Any, int]:
    if i >= len(lines):
        return None, i
    cur_indent, content = lines[i]
    if cur_indent < indent:
        return None, i
    if content.startswith("- "):
        return _parse_list(lines, i, cur_indent)
    if ":" in content:
        return _parse_map(lines, i, cur_indent)
    return _parse_scalar(content), i + 1


def _parse_map(lines: list[tuple[int, str]], i: int, indent: int) -> tuple[dict[str, Any], int]:
    result: dict[str, Any] = {}
    while i < len(lines):
        cur_indent, content = lines[i]
        if cur_indent < indent:
            break
        if cur_indent > indent:
            raise YamlError(f"unexpected indent at: {content}")
        if content.startswith("- "):
            raise YamlError(f"list item where a key was expected: {content}")
        if ":" not in content:
            raise YamlError(f"expected key: {content}")
        key, rest = content.split(":", 1)
        key = key.strip()
        rest = rest.strip()
        i += 1
        if rest:
            result[key] = _parse_scalar(rest)
            continue
        if i >= len(lines) or lines[i][0] <= indent:
            result[key] = {}
            continue
        child, i = _parse_block(lines, i, lines[i][0])
        result[key] = {} if child is None else child
    return result, i


def _parse_list(lines: list[tuple[int, str]], i: int, indent: int) -> tuple[list[Any], int]:
    result: list[Any] = []
    while i < len(lines):
        cur_indent, content = lines[i]
        if cur_indent < indent:
            break
        if cur_indent > indent:
            raise YamlError(f"unexpected indent at: {content}")
        if not content.startswith("- "):
            break
        item = content[2:].strip()
        i += 1
        if item and not (item.endswith(":") and i < len(lines) and lines[i][0] > cur_indent):
            if item.endswith(":") and ":" in item[:-1]:
                # inline map on a list item is not used; treat as scalar
                result.append(_parse_scalar(item))
            elif item.endswith(":"):
                key = item[:-1].strip()
                if i < len(lines) and lines[i][0] > cur_indent:
                    child, i = _parse_block(lines, i, lines[i][0])
                    result.append({key: {} if child is None else child})
                else:
                    result.append({key: {}})
            else:
                result.append(_parse_scalar(item))
            continue
        if i < len(lines) and lines[i][0] > cur_indent:
            child, i = _parse_block(lines, i, lines[i][0])
            result.append({} if child is None else child)
        else:
            result.append(_parse_scalar(item) if item else None)
    return result, i


def load_yaml_file(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    data = parse_simple_yaml(text)
    if data is None:
        return {}
    if not isinstance(data, dict):
        raise YamlError(f"{path} must be a mapping at the top level")
    return data


def project_yaml_path(target: Path) -> Path:
    return target / "harness.project.yaml"


def load_project(target: Path) -> dict[str, Any]:
    path = project_yaml_path(target)
    if not path.is_file():
        raise FileNotFoundError(str(path))
    return load_yaml_file(path)


def check_project(target: Path, *, harness_root: Path | None = None) -> list[str]:
    """Return human-readable errors. Empty list means OK."""
    errors: list[str] = []
    path = project_yaml_path(target)
    template_hint = "vendor/cursor-harness/templates/harness.project.yaml"
    if harness_root is not None:
        template_hint = str(harness_root / "templates" / "harness.project.yaml")

    if not path.is_file():
        errors.append(
            f"missing {path.name} at {path} — copy {template_hint} to {path}"
        )
        return errors

    try:
        data = load_yaml_file(path)
    except YamlError as exc:
        errors.append(f"invalid YAML in {path}: {exc}")
        return errors

    source = data.get("issue_source")
    if source not in ISSUE_SOURCES:
        errors.append(
            f"issue_source must be one of {sorted(ISSUE_SOURCES)} (got {source!r})"
        )
    elif source == "github":
        gh = data.get("github") or {}
        if not isinstance(gh, dict) or not str(gh.get("owner") or "").strip():
            errors.append("issue_source=github requires github.owner")
        if not isinstance(gh, dict) or gh.get("project") in (None, ""):
            errors.append("issue_source=github requires github.project (GitHub Project number)")
        if not isinstance(gh, dict) or not str(gh.get("ready") or "").strip():
            errors.append("issue_source=github requires github.ready (Status column name)")
    elif source == "files":
        files = data.get("files") or {}
        rel = str((files or {}).get("path") or "").strip() if isinstance(files, dict) else ""
        if not rel:
            errors.append("issue_source=files requires files.path")
        elif not (target / rel).exists():
            errors.append(f"files.path does not exist: {rel}")

    test = data.get("test")
    if test is None:
        errors.append("test is required (set test.discover: true or name commands)")
    elif not isinstance(test, dict):
        errors.append("test must be a mapping")
    else:
        discover = bool(test.get("discover"))
        named = any(test.get(k) for k in ("targeted", "fast", "full"))
        if not discover and not named:
            errors.append("test.discover must be true, or set test.targeted / test.fast / test.full")

    slots = data.get("slots")
    if slots not in (None, {}, []):
        if not isinstance(slots, dict):
            errors.append("slots must be a mapping when present")
        else:
            count = slots.get("count")
            if not isinstance(count, int) or count < 1:
                errors.append("slots.count must be an integer >= 1 when slots is set")
            lease = str(slots.get("lease") or "").strip()
            if lease:
                lease_path = (target / lease).resolve() if not os.path.isabs(lease) else Path(lease)
                if not lease_path.exists():
                    errors.append(f"slots.lease does not exist: {lease}")

    packs = data.get("packs")
    if packs is None:
        errors.append("packs is required (at least: [core])")
    elif not isinstance(packs, list) or not packs:
        errors.append("packs must be a non-empty list")
    else:
        unknown = [p for p in packs if p not in KNOWN_PACKS]
        if unknown:
            errors.append(f"unknown packs {unknown} — known: {list(KNOWN_PACKS)}")
        if "core" not in packs:
            errors.append("packs must include core")

    docs = data.get("docs")
    if docs is not None and not isinstance(docs, dict):
        errors.append("docs must be a mapping when present")

    executor = data.get("executor")
    if executor is not None:
        if not isinstance(executor, dict):
            errors.append("executor must be a mapping when present")
        elif executor.get("command") in (None, ""):
            errors.append("executor.command is required when executor is set")

    return errors


def load_manifest(manifest_path: Path) -> dict[str, Any]:
    return load_yaml_file(manifest_path)


def normalize_pack_names(names: list[str], *, all_sets: list[str]) -> list[str]:
    expanded: list[str] = []
    for name in names:
        item = str(name).strip()
        if not item:
            continue
        if item == "all":
            for key in all_sets:
                if key not in expanded:
                    expanded.append(key)
            continue
        if item not in expanded:
            expanded.append(item)
    if "core" not in expanded:
        expanded.insert(0, "core")
    return expanded


def resolve_pack_sets(
    manifest: dict[str, Any], pack_names: list[str]
) -> dict[str, Any]:
    sets = manifest.get("pack_sets") or {}
    if not isinstance(sets, dict) or not sets:
        raise YamlError("manifest.yaml is missing pack_sets")
    names = normalize_pack_names(pack_names, all_sets=list(sets.keys()))
    rules: list[str] = []
    skills: list[str] = []
    agents: list[str] = []
    automations = False
    hooks = False
    for name in names:
        block = sets.get(name)
        if not isinstance(block, dict):
            raise YamlError(f"unknown pack set: {name}")
        for item in block.get("rules") or []:
            if item not in rules:
                rules.append(item)
        for item in block.get("skills") or []:
            if item not in skills:
                skills.append(item)
        for item in block.get("agents") or []:
            if item not in agents:
                agents.append(item)
        if block.get("automations") is True:
            automations = True
        hooks_block = block.get("hooks")
        if hooks_block is True:
            hooks = True
        elif isinstance(hooks_block, dict) and hooks_block.get("enabled") is True:
            hooks = True
    return {
        "names": names,
        "rules": rules,
        "skills": skills,
        "agents": agents,
        "automations": automations,
        "hooks": hooks,
    }


def packs_from_project_or_flag(target: Path, packs_flag: str | None) -> list[str]:
    if packs_flag:
        return [p.strip() for p in packs_flag.split(",") if p.strip()]
    path = project_yaml_path(target)
    if path.is_file():
        data = load_yaml_file(path)
        packs = data.get("packs")
        if isinstance(packs, list) and packs:
            return [str(p) for p in packs]
    return ["core"]


def dump_bash_packs(resolved: dict[str, Any]) -> str:
    def emit(name: str, values: list[str]) -> str:
        body = "\n".join(f"  {shlex.quote(v)}" for v in values)
        return f"{name}=(\n{body}\n)\n"

    out = emit("RULES", resolved["rules"])
    out += emit("SKILLS", resolved["skills"])
    out += emit("AGENTS", resolved["agents"])
    out += f"PACK_NAMES={shlex.quote(','.join(resolved['names']))}\n"
    out += f"HOOKS_ENABLED={'1' if resolved['hooks'] else '0'}\n"
    out += f"AUTOMATIONS_ENABLED={'1' if resolved['automations'] else '0'}\n"
    return out


def default_executor(project: dict[str, Any]) -> dict[str, str]:
    ex = project.get("executor") if isinstance(project.get("executor"), dict) else {}
    return {
        "command": str(ex.get("command") or "agent"),
        "prompt": str(ex.get("prompt") or "@execute-approved-plan"),
        "model": str(ex.get("model") or "composer-2.5"),
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="harness.project.yaml helpers")
    sub = parser.add_subparsers(dest="cmd", required=True)

    check = sub.add_parser("check", help="validate consumer harness.project.yaml")
    check.add_argument("--target", required=True)
    check.add_argument("--harness-root", default="")

    dump = sub.add_parser("dump-packs", help="print bash arrays for install.sh")
    dump.add_argument("--manifest", required=True)
    dump.add_argument("--target", required=True)
    dump.add_argument("--packs", default="")

    args = parser.parse_args(argv)
    if args.cmd == "check":
        target = Path(args.target).resolve()
        harness_root = Path(args.harness_root).resolve() if args.harness_root else None
        errors = check_project(target, harness_root=harness_root)
        if errors:
            print("harness.project.yaml check failed:", file=sys.stderr)
            for err in errors:
                print(f"  - {err}", file=sys.stderr)
            return 1
        print(f"ok: {project_yaml_path(target)}")
        print(CODE_GLOBS_HINT)
        return 0

    if args.cmd == "dump-packs":
        manifest = load_manifest(Path(args.manifest))
        names = packs_from_project_or_flag(Path(args.target).resolve(), args.packs or None)
        resolved = resolve_pack_sets(manifest, names)
        sys.stdout.write(dump_bash_packs(resolved))
        return 0

    return 2


if __name__ == "__main__":
    raise SystemExit(main())
