#!/usr/bin/env bash
# Install cursor-harness packs into a project's .cursor/ directory.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install.sh [options]

Install cursor-harness rules, skills, agents, automations, hooks, and HARNESS.md
into a target project.

Options:
  --target <path>     Project root to install into (default: auto-detect)
  --mode <symlink|copy>
                      Install mode (default: symlink, or manifest defaults.mode)
  --force             Replace existing non-symlink files managed by the harness
  --with-agents       Copy templates/AGENTS.md to project root if missing
  --dry-run           Print actions without changing the filesystem
  -h, --help          Show this help

Examples:
  ./vendor/cursor-harness/install.sh --target .
  ./vendor/cursor-harness/install.sh --target . --mode copy --with-agents
EOF
}

HARNESS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${HARNESS_ROOT}/manifest.yaml"

TARGET=""
MODE=""
FORCE=0
WITH_AGENTS=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --with-agents)
      WITH_AGENTS=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "$MANIFEST" ]]; then
  echo "error: manifest not found at $MANIFEST" >&2
  exit 1
fi

# Default target: parent of vendor/cursor-harness when nested; else cwd.
if [[ -z "$TARGET" ]]; then
  base="$(basename "$HARNESS_ROOT")"
  parent="$(basename "$(dirname "$HARNESS_ROOT")")"
  if [[ "$base" == "cursor-harness" && "$parent" == "vendor" ]]; then
    TARGET="$(cd "$HARNESS_ROOT/../.." && pwd)"
  else
    TARGET="$(pwd)"
  fi
else
  TARGET="$(cd "$TARGET" && pwd)"
fi

if [[ -z "$MODE" ]]; then
  MODE="$(
    python3 - "$MANIFEST" <<'PY'
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
m = re.search(r"(?m)^\s*mode:\s*(\w+)\s*$", text)
print(m.group(1) if m else "symlink")
PY
  )"
fi

if [[ "$MODE" != "symlink" && "$MODE" != "copy" ]]; then
  echo "error: --mode must be symlink or copy (got: $MODE)" >&2
  exit 1
fi

log() {
  printf '%s\n' "$*"
}

ensure_dir() {
  local dir="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN: mkdir -p $dir"
    return 0
  fi
  mkdir -p "$dir"
}

# Install a file or directory from src to dest using MODE.
install_path() {
  local src="$1"
  local dest="$2"
  local kind="${3:-file}" # file | dir

  if [[ ! -e "$src" ]]; then
    echo "error: missing source: $src" >&2
    exit 1
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    # Symlinks are always safe to replace (harness-managed).
    # Copy mode may refresh regular files (harness pack updates).
    # Symlink mode refuses to replace a real file unless --force
    # (protects project-local overrides that replaced a link).
    if [[ -L "$dest" ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        log "DRY-RUN: rm $dest"
      else
        rm "$dest"
      fi
    elif [[ "$MODE" == "copy" || "$FORCE" -eq 1 ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        log "DRY-RUN: rm -rf $dest"
      else
        rm -rf "$dest"
      fi
    elif [[ "$DRY_RUN" -eq 1 ]]; then
      log "DRY-RUN: would refuse overwrite (non-symlink): $dest"
      return 0
    else
      echo "error: refusing to overwrite non-symlink path: $dest (use --force)" >&2
      exit 1
    fi
  fi

  ensure_dir "$(dirname "$dest")"

  if [[ "$MODE" == "symlink" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "DRY-RUN: ln -s $src $dest"
    else
      ln -s "$src" "$dest"
    fi
  else
    if [[ "$kind" == "dir" ]]; then
      if [[ "$DRY_RUN" -eq 1 ]]; then
        log "DRY-RUN: cp -R $src $dest"
      else
        cp -R "$src" "$dest"
      fi
    else
      if [[ "$DRY_RUN" -eq 1 ]]; then
        log "DRY-RUN: cp $src $dest"
      else
        cp "$src" "$dest"
      fi
    fi
  fi
  log "installed ($MODE): $dest"
}

# Parse pack lists from the simple manifest.yaml without PyYAML.
eval "$(
  python3 - "$MANIFEST" <<'PY'
import re, shlex, sys

text = open(sys.argv[1], encoding="utf-8").read().splitlines()
section = None
hooks_enabled = True
automations_enabled = False
harness_map = "HARNESS.md"
rules = []
skills = []
agents = []

for raw in text:
    line = raw.split("#", 1)[0].rstrip()
    if not line.strip():
        continue
    m = re.match(r"^\s*harness_map:\s*(.+?)\s*$", line)
    if m:
        harness_map = m.group(1).strip().strip("\"'")
        section = None
        continue
    m = re.match(r"^\s*automations:\s*(true|false)\s*$", line, re.I)
    if m:
        automations_enabled = m.group(1).lower() == "true"
        section = None
        continue
    if re.match(r"^\s*rules:\s*$", line):
        section = "rules"
        continue
    if re.match(r"^\s*skills:\s*$", line):
        section = "skills"
        continue
    if re.match(r"^\s*agents:\s*$", line):
        section = "agents"
        continue
    if re.match(r"^\s*hooks:\s*$", line):
        section = "hooks"
        continue
    m = re.match(r"^\s*enabled:\s*(true|false)\s*$", line, re.I)
    if section == "hooks" and m:
        hooks_enabled = m.group(1).lower() == "true"
        continue
    m = re.match(r"^\s*-\s+(.+?)\s*$", line)
    if m and section in ("rules", "skills", "agents"):
        item = m.group(1).strip().strip("\"'")
        if section == "rules":
            rules.append(item)
        elif section == "skills":
            skills.append(item)
        else:
            agents.append(item)
        continue
    # Leaving packs subsections when indentation drops to top-level keys
    if re.match(r"^[A-Za-z]", line) and section in ("rules", "skills", "agents", "hooks"):
        section = None

def emit(name, values):
    print(f"{name}=(")
    for v in values:
        print(f"  {shlex.quote(v)}")
    print(")")

emit("RULES", rules)
emit("SKILLS", skills)
emit("AGENTS", agents)
print(f"HARNESS_MAP={shlex.quote(harness_map)}")
print(f"HOOKS_ENABLED={'1' if hooks_enabled else '0'}")
print(f"AUTOMATIONS_ENABLED={'1' if automations_enabled else '0'}")
PY
)"

CURSOR_DIR="${TARGET}/.cursor"
ensure_dir "${CURSOR_DIR}/rules"
ensure_dir "${CURSOR_DIR}/skills"
ensure_dir "${CURSOR_DIR}/hooks"

log "cursor-harness install"
log "  harness: $HARNESS_ROOT"
log "  target:  $TARGET"
log "  mode:    $MODE"

if [[ -n "${HARNESS_MAP:-}" ]]; then
  install_path "${HARNESS_ROOT}/${HARNESS_MAP}" "${CURSOR_DIR}/HARNESS.md" file
fi

for rule in "${RULES[@]:-}"; do
  [[ -z "${rule:-}" ]] && continue
  install_path "${HARNESS_ROOT}/rules/${rule}" "${CURSOR_DIR}/rules/${rule}" file
done

for skill in "${SKILLS[@]:-}"; do
  [[ -z "${skill:-}" ]] && continue
  install_path "${HARNESS_ROOT}/skills/${skill}" "${CURSOR_DIR}/skills/${skill}" dir
done

for agent in "${AGENTS[@]:-}"; do
  [[ -z "${agent:-}" ]] && continue
  ensure_dir "${CURSOR_DIR}/agents"
  install_path "${HARNESS_ROOT}/agents/${agent}" "${CURSOR_DIR}/agents/${agent}" file
done

if [[ "${AUTOMATIONS_ENABLED}" -eq 1 ]]; then
  install_path "${HARNESS_ROOT}/automations" "${CURSOR_DIR}/automations" dir
fi

if [[ "${HOOKS_ENABLED}" -eq 1 ]]; then
  # Install hook scripts (basename only under .cursor/hooks/)
  while IFS= read -r -d '' script; do
    name="$(basename "$script")"
    install_path "$script" "${CURSOR_DIR}/hooks/${name}" file
    if [[ "$DRY_RUN" -eq 0 ]]; then
      chmod +x "${CURSOR_DIR}/hooks/${name}" 2>/dev/null || true
    else
      log "DRY-RUN: chmod +x ${CURSOR_DIR}/hooks/${name}"
    fi
  done < <(find "${HARNESS_ROOT}/hooks/scripts" -type f -print0 2>/dev/null || true)

  # Merge harness hooks.json into project hooks.json (namespace by command path).
  HARNESS_HOOKS="${HARNESS_ROOT}/hooks/hooks.json"
  DEST_HOOKS="${CURSOR_DIR}/hooks.json"
  if [[ ! -f "$HARNESS_HOOKS" ]]; then
    echo "error: missing $HARNESS_HOOKS" >&2
    exit 1
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "DRY-RUN: merge hooks into $DEST_HOOKS"
  else
    python3 - "$HARNESS_HOOKS" "$DEST_HOOKS" <<'PY'
import json, sys
from pathlib import Path

harness_path = Path(sys.argv[1])
dest_path = Path(sys.argv[2])

harness = json.loads(harness_path.read_text(encoding="utf-8"))
if dest_path.exists():
    project = json.loads(dest_path.read_text(encoding="utf-8"))
else:
    project = {"version": 1, "hooks": {}}

if "hooks" not in project or not isinstance(project["hooks"], dict):
    project["hooks"] = {}
project.setdefault("version", harness.get("version", 1))

harness_commands = set()
for event, entries in harness.get("hooks", {}).items():
    for entry in entries or []:
        cmd = entry.get("command")
        if cmd:
            harness_commands.add(cmd)

# Drop previous harness-managed entries (same command paths), keep others.
for event, entries in list(project["hooks"].items()):
    if not isinstance(entries, list):
        continue
    project["hooks"][event] = [
        e for e in entries
        if not (isinstance(e, dict) and e.get("command") in harness_commands)
    ]

for event, entries in harness.get("hooks", {}).items():
    project["hooks"].setdefault(event, [])
    for entry in entries or []:
        project["hooks"][event].append(entry)

# Remove empty event arrays for cleanliness
project["hooks"] = {k: v for k, v in project["hooks"].items() if v}

dest_path.write_text(json.dumps(project, indent=2) + "\n", encoding="utf-8")
print(f"merged hooks: {dest_path}")
PY
  fi
fi

if [[ "$WITH_AGENTS" -eq 1 ]]; then
  agents_src="${HARNESS_ROOT}/templates/AGENTS.md"
  agents_dest="${TARGET}/AGENTS.md"
  if [[ -e "$agents_dest" ]]; then
    log "skip AGENTS.md (already exists): $agents_dest"
  else
    if [[ "$DRY_RUN" -eq 1 ]]; then
      log "DRY-RUN: cp $agents_src $agents_dest"
    else
      cp "$agents_src" "$agents_dest"
    fi
    log "installed: $agents_dest"
  fi
fi

log "done."
