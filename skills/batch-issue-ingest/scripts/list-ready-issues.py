#!/usr/bin/env python3
"""List GitHub Project items whose status matches the Ready column."""
from __future__ import annotations

import argparse
import json
import subprocess
import sys


def gh_json(args: list[str]) -> object:
    proc = subprocess.run(
        ["gh", *args],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        sys.stderr.write(proc.stderr or proc.stdout or "gh failed\n")
        raise SystemExit(proc.returncode)
    raw = (proc.stdout or "").strip()
    if not raw:
        return {}
    return json.loads(raw)


def item_status(item: dict) -> str:
    status = item.get("status")
    if isinstance(status, str):
        return status.strip()
    if isinstance(status, dict):
        for key in ("name", "option", "title"):
            val = status.get(key)
            if isinstance(val, str) and val.strip():
                return val.strip()
    fields = item.get("fields") or item.get("fieldValues") or []
    if isinstance(fields, list):
        for field in fields:
            if not isinstance(field, dict):
                continue
            name = str(field.get("name") or field.get("field") or "").lower()
            if name in {"status", "state", "column"}:
                for key in ("value", "name", "option"):
                    val = field.get(key)
                    if isinstance(val, str) and val.strip():
                        return val.strip()
    return ""


def item_summary(item: dict) -> dict:
    content = item.get("content") if isinstance(item.get("content"), dict) else {}
    return {
        "project_item_id": item.get("id"),
        "status": item_status(item),
        "title": item.get("title") or content.get("title"),
        "type": content.get("type") or item.get("type") or "Unknown",
        "number": content.get("number") or item.get("number"),
        "repository": content.get("repository") or item.get("repository"),
        "url": content.get("url") or item.get("url"),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--owner", required=True)
    parser.add_argument("--project", required=True, help="GitHub Project number")
    parser.add_argument("--ready", default="Ready")
    parser.add_argument("--limit", type=int, default=10)
    parser.add_argument("--min", type=int, default=5)
    args = parser.parse_args()

    payload = gh_json(
        [
            "project",
            "item-list",
            str(args.project),
            "--owner",
            args.owner,
            "--format",
            "json",
            "--limit",
            "100",
        ]
    )
    items = payload if isinstance(payload, list) else payload.get("items", [])
    if not isinstance(items, list):
        items = []

    wanted = args.ready.strip().lower()
    ready = [
        item_summary(item)
        for item in items
        if isinstance(item, dict) and item_status(item).lower() == wanted
    ]
    selected = ready[: max(args.limit, 0)]
    note = None
    if len(ready) < args.min:
        note = f"Fewer than {args.min} {args.ready!r} items; using all {len(ready)}."
    elif len(ready) > args.limit:
        note = f"{len(ready)} {args.ready!r} items on the board; selected {len(selected)}."

    json.dump(
        {
            "owner": args.owner,
            "project": args.project,
            "ready": args.ready,
            "ready_count": len(ready),
            "selected_count": len(selected),
            "selected": selected,
            "note": note,
        },
        sys.stdout,
        indent=2,
    )
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
