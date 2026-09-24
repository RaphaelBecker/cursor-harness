#!/usr/bin/env bash
# Run a long gate detached and check it in short, separate calls.
# No tmux. The gate survives the calling shell (own session via python3).
#
#   gate-run.sh start     --name NAME -- CMD [ARGS...]
#   gate-run.sh status    --name NAME [--lines N]
#   gate-run.sh wait-step --name NAME [--seconds S] [--lines N]   (S capped at 90)
#
# State lives in $GATE_RUN_DIR (default: <git-dir>/gate-run/NAME): pid, log,
# exit (written once the gate ends), started.
#
# Exit codes (status / wait-step): 0 gate green, 1 gate red (see `exit:`),
# 3 still running, 4 dead (process gone, no exit marker), 2 usage / no run.
set -uo pipefail

MAX_WAIT_STEP=90

usage() {
  sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' >&2
  exit 2
}

[[ $# -ge 1 ]] || usage
ACTION="$1"
shift
NAME=""
LINES=15
SECONDS_STEP=60
CMD=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="${2:-}"; shift 2 ;;
    --lines) LINES="${2:-15}"; shift 2 ;;
    --seconds) SECONDS_STEP="${2:-60}"; shift 2 ;;
    --) shift; CMD=("$@"); break ;;
    -h|--help) usage ;;
    *) echo "gate-run: unknown argument: $1" >&2; usage ;;
  esac
done

[[ "$NAME" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "gate-run: --name must be [A-Za-z0-9._-]+" >&2; exit 2; }

if [[ -n "${GATE_RUN_DIR:-}" ]]; then
  STATE="$GATE_RUN_DIR/$NAME"
else
  git_dir="$(git rev-parse --absolute-git-dir 2>/dev/null)" || {
    echo "gate-run: not in a git checkout; set GATE_RUN_DIR" >&2
    exit 2
  }
  STATE="$git_dir/gate-run/$NAME"
fi

pid_alive() {
  local pid
  pid="$(cat "$STATE/pid" 2>/dev/null)" || return 1
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

report() {
  if [[ ! -f "$STATE/pid" ]]; then
    echo "gate-run: no run named $NAME ($STATE)" >&2
    return 2
  fi
  local started now rc state code
  started="$(cat "$STATE/started" 2>/dev/null || echo 0)"
  now="$(date +%s)"
  if [[ -f "$STATE/exit" ]]; then
    rc="$(tr -dc '0-9' <"$STATE/exit")"
    rc="${rc:-1}"
    state="done"
    if [[ "$rc" -eq 0 ]]; then code=0; else code=1; fi
  elif pid_alive; then
    state="running"
    code=3
  else
    state="dead"
    code=4
  fi
  echo "gate: $NAME"
  echo "state: $state"
  [[ "$state" == "done" ]] && echo "exit: $rc"
  echo "elapsed: $((now - started))s"
  echo "log: $STATE/log"
  echo "--- last $LINES log lines ---"
  tail -n "$LINES" "$STATE/log" 2>/dev/null || true
  return "$code"
}

case "$ACTION" in
  start)
    [[ ${#CMD[@]} -gt 0 ]] || { echo "gate-run: start needs -- CMD" >&2; exit 2; }
    if [[ -f "$STATE/pid" && ! -f "$STATE/exit" ]] && pid_alive; then
      echo "gate-run: $NAME is already running; use status" >&2
      report
      exit 2
    fi
    rm -rf "$STATE"
    mkdir -p "$STATE"
    date +%s >"$STATE/started"
    python3 - "$STATE" "${CMD[@]}" <<'PY' || { echo "gate-run: failed to launch" >&2; exit 2; }
import os, subprocess, sys
state, cmd = sys.argv[1], sys.argv[2:]
runner = (
    'rc=0; "$@" || rc=$?; '
    'printf "%s\\n" "$rc" >"$0/exit.tmp" && mv "$0/exit.tmp" "$0/exit"; '
    'printf "EXIT=%s\\n" "$rc"'
)
with open(os.path.join(state, "log"), "ab") as log:
    proc = subprocess.Popen(
        ["bash", "-c", runner, state, *cmd],
        stdin=subprocess.DEVNULL, stdout=log, stderr=subprocess.STDOUT,
        start_new_session=True, close_fds=True,
    )
with open(os.path.join(state, "pid"), "w") as fh:
    fh.write(f"{proc.pid}\n")
PY
    echo "gate-run: started $NAME (pid $(cat "$STATE/pid"))"
    echo "log: $STATE/log"
    echo "next: gate-run.sh wait-step --name $NAME   (repeat; each call returns within ${MAX_WAIT_STEP}s)"
    ;;
  status)
    report
    exit $?
    ;;
  wait-step)
    [[ "$SECONDS_STEP" =~ ^[0-9]+$ ]] || { echo "gate-run: --seconds must be an integer" >&2; exit 2; }
    (( SECONDS_STEP > MAX_WAIT_STEP )) && SECONDS_STEP=$MAX_WAIT_STEP
    deadline=$(( $(date +%s) + SECONDS_STEP ))
    while [[ -f "$STATE/pid" && ! -f "$STATE/exit" ]] && pid_alive && (( $(date +%s) < deadline )); do
      sleep 2
    done
    report
    exit $?
    ;;
  *)
    usage
    ;;
esac
