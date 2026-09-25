#!/usr/bin/env bash
# Push gate for /ship-prod. Only preflight.sh may arm it (parent check).
# The shell guard allows raw `git push` and `gh pr create` / `gh pr merge`
# only while this marker is unexpired. Direct push scripts named in
# harness.project.yaml `ship.direct_push` are a separate allow, decided
# by the classifier — this file only arms, clears, and checks the marker.
# The classifier also allows `git push origin main` inside this checkout's
# vendor/cursor-harness while the marker is fresh, when that push
# fast-forwards main and does not use --force.
#
# Marker: <checkout>/.cursor/night-shift/ship-prod-push-gate
# Contents: one integer, the unix expiry. TTL is 6 hours. A missing,
# unreadable, stale, or further-out expiry does not open the gate.
set -euo pipefail

TTL=21600
MARKER_REL=".cursor/night-shift/ship-prod-push-gate"

SOURCE_DIR="$(python3 -c 'import os,sys; print(os.path.dirname(os.path.realpath(sys.argv[1])))' "${BASH_SOURCE[0]}")"

usage() {
  cat >&2 <<'EOF'
usage: ship-prod-push-gate.sh arm|clear|fresh --root PATH
       ship-prod-push-gate.sh classify   # JSON on stdin → ok | deny<TAB>message
EOF
  exit 2
}

CMD="${1:-}"
[[ -n "$CMD" ]] || usage
shift

ROOT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="${2:-}"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "unknown arg: $1" >&2; usage ;;
  esac
done

resolve_root() {
  if [[ -z "$ROOT" ]]; then
    echo "push-gate: --root is required" >&2
    exit 2
  fi
  ROOT="$(cd "$ROOT" && pwd)"
}

marker_file() {
  printf '%s/%s' "$ROOT" "$MARKER_REL"
}

ancestor_is_preflight() {
  local pid cmd i
  pid=$PPID
  for i in 1 2 3 4 5 6; do
    [[ -n "${pid:-}" && "$pid" != "0" && "$pid" != "1" ]] || return 1
    cmd="$(ps -o command= -p "$pid" 2>/dev/null || true)"
    if [[ "$cmd" == *preflight.sh* ]]; then
      return 0
    fi
    pid="$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d '[:space:]' || true)"
  done
  return 1
}

case "$CMD" in
  arm)
    resolve_root
    if ! ancestor_is_preflight; then
      echo "Pushes/PRs only via /ship-prod; land with /ship-local." >&2
      exit 1
    fi
    file="$(marker_file)"
    mkdir -p "$(dirname "$file")"
    echo $(( $(date +%s) + TTL )) >"$file"
    ;;
  clear)
    resolve_root
    rm -f "$(marker_file)"
    ;;
  fresh)
    resolve_root
    file="$(marker_file)"
    [[ -f "$file" ]] || exit 1
    exp="$(tr -d '[:space:]' <"$file")"
    [[ "$exp" =~ ^[0-9]+$ ]] || exit 1
    now="$(date +%s)"
    if (( exp > now && exp <= now + TTL )); then
      exit 0
    fi
    exit 1
    ;;
  classify)
    exec python3 "$SOURCE_DIR/push-gate-classify.py" "$SOURCE_DIR/ship-prod-push-gate.sh"
    ;;
  *)
    usage
    ;;
esac
