#!/usr/bin/env bash
# Dispatch one CI shard and poll it in short steps.
# No tmux. No caller-owned sleep loop.
#
#   shard-check.sh dispatch --workflow FILE --shard NAME --ref SHA --branch BRANCH [--seconds S]
#   shard-check.sh find     --workflow FILE --shard NAME --ref SHA
#   shard-check.sh wait-step --run ID [--seconds S]
#
# The workflow run-name for a shard input must be: shard-check <shard> <ref>
# S is capped at 90. Exit 3 means call again.
#
# Exit codes: 0 dispatched or shard green, 1 shard or gh failed,
# 3 not finished yet, 2 usage.
set -uo pipefail

MAX_WAIT_STEP=90

usage() {
  sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' >&2
  exit 2
}

[[ $# -ge 1 ]] || usage
ACTION="$1"
shift
WORKFLOW=""
SHARD=""
REF=""
BRANCH=""
RUN_ID=""
SECONDS_STEP="$MAX_WAIT_STEP"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workflow) WORKFLOW="${2:-}"; shift 2 ;;
    --shard) SHARD="${2:-}"; shift 2 ;;
    --ref) REF="${2:-}"; shift 2 ;;
    --branch) BRANCH="${2:-}"; shift 2 ;;
    --run) RUN_ID="${2:-}"; shift 2 ;;
    --seconds) SECONDS_STEP="${2:-}"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "shard-check: unknown argument: $1" >&2; usage ;;
  esac
done

[[ "$SECONDS_STEP" =~ ^[0-9]+$ ]] || { echo "shard-check: --seconds must be an integer" >&2; exit 2; }
(( SECONDS_STEP > MAX_WAIT_STEP )) && SECONDS_STEP=$MAX_WAIT_STEP

require_shard_ref() {
  [[ "$SHARD" =~ ^[a-z][a-z0-9_-]*$ ]] || { echo "shard-check: --shard must be a job id" >&2; exit 2; }
  [[ "$REF" =~ ^[0-9a-f]{40}$ ]] || { echo "shard-check: --ref must be a 40-character sha" >&2; exit 2; }
  [[ -n "$WORKFLOW" && "$WORKFLOW" =~ ^[A-Za-z0-9._/-]+$ && "$WORKFLOW" != *..* ]] \
    || { echo "shard-check: --workflow must be a workflow file name" >&2; exit 2; }
}

list_matches() {
  local json
  json="$(gh run list --workflow "$WORKFLOW" --event workflow_dispatch --limit 20 \
    --json databaseId,displayTitle,url,status,createdAt)" || {
    echo "shard-check: gh run list failed" >&2
    return 1
  }
  SHARD_CHECK_NEEDLE="shard-check ${SHARD} ${REF}" python3 -c '
import json, os, sys
needle = os.environ["SHARD_CHECK_NEEDLE"]
rows = json.load(sys.stdin)
rows = [row for row in rows if needle in (row.get("displayTitle") or "")]
rows.sort(key=lambda row: row.get("createdAt") or "", reverse=True)
if not rows:
    print("MISSING")
    raise SystemExit(0)
row = rows[0]
run_id = row.get("databaseId")
url = row.get("url") or ""
status = row.get("status") or ""
print("FOUND")
print("run: " + str(run_id))
print("url: " + url)
print("status: " + status)
' <<<"$json"
}

show_match() {
  local parsed first
  parsed="$(list_matches)" || return 1
  first="$(printf '%s\n' "$parsed" | head -n 1)"
  if [[ "$first" == "MISSING" ]]; then
    return 3
  fi
  if [[ "$first" != "FOUND" ]]; then
    echo "shard-check: unexpected run list" >&2
    return 1
  fi
  printf '%s\n' "$parsed" | tail -n +2
  return 0
}

case "$ACTION" in
  find)
    require_shard_ref
    show_match
    code=$?
    if [[ "$code" -eq 0 ]]; then
      exit 0
    fi
    if [[ "$code" -eq 3 ]]; then
      echo "state: pending"
      echo "shard: $SHARD"
      echo "ref: $REF"
    fi
    exit "$code"
    ;;
  dispatch)
    require_shard_ref
    [[ "$BRANCH" =~ ^[A-Za-z0-9][A-Za-z0-9._/-]*$ && "$BRANCH" != *..* ]] \
      || { echo "shard-check: --branch must be the default branch" >&2; exit 2; }
    gh workflow run "$WORKFLOW" --ref "$BRANCH" -f "shard=${SHARD}" -f "ref=${REF}" || {
      echo "shard-check: gh workflow run failed" >&2
      exit 1
    }
    deadline=$(( $(date +%s) + SECONDS_STEP ))
    while true; do
      show_match
      code=$?
      if [[ "$code" -eq 0 ]]; then
        echo "state: dispatched"
        exit 0
      fi
      if [[ "$code" -ne 3 ]]; then
        exit "$code"
      fi
      if (( $(date +%s) >= deadline )); then
        echo "state: pending"
        echo "shard: $SHARD"
        echo "ref: $REF"
        echo "next: shard-check.sh find --workflow $WORKFLOW --shard $SHARD --ref $REF"
        exit 3
      fi
      sleep 2
    done
    ;;
  wait-step)
    [[ "$RUN_ID" =~ ^[0-9]+$ ]] || { echo "shard-check: --run must be a run id" >&2; exit 2; }
    deadline=$(( $(date +%s) + SECONDS_STEP ))
    while true; do
      json="$(gh run view "$RUN_ID" --json status,conclusion,url)" || {
        echo "shard-check: gh run view failed" >&2
        exit 1
      }
      parsed="$(python3 -c '
import json, sys
row = json.load(sys.stdin)
print(row.get("status") or "")
print(row.get("conclusion") or "")
print(row.get("url") or "")
' <<<"$json")"
      status="$(printf '%s\n' "$parsed" | sed -n '1p')"
      conclusion="$(printf '%s\n' "$parsed" | sed -n '2p')"
      url="$(printf '%s\n' "$parsed" | sed -n '3p')"
      echo "run: $RUN_ID"
      echo "status: $status"
      echo "conclusion: $conclusion"
      echo "url: $url"
      if [[ "$status" == "completed" ]]; then
        if [[ "$conclusion" == "success" ]]; then
          exit 0
        fi
        exit 1
      fi
      if (( $(date +%s) >= deadline )); then
        echo "state: running"
        echo "next: shard-check.sh wait-step --run $RUN_ID"
        exit 3
      fi
      sleep 2
    done
    ;;
  *)
    usage
    ;;
esac
