#!/usr/bin/env bash
# Context governor — warn at the smart-zone line; never hijack with /summarize.
#
# Smart zone = 60% of Cursor's model window (the same denominator as the context
# ring). That is ~160k on a 256k window, not 16k.
#
# Token count: use Cursor's own fields when present (documented on preCompact:
# context_tokens, context_window_size, context_usage_percent). Stay silent when
# they are missing. Never invent a figure from file sizes or transcript bytes.
#
# Warn only: never followup_message "/summarize". That slash replaces the
# agent's next action (idle-main complete, CI watch, merge) with compact, so
# long skills die after "starting X". On `stop` at/above 60% (once per epoch),
# nudge the agent to invoke the outstanding command instead. preCompact re-arms.
# Fail-open: any error still prints {} and exits 0.
#
# stdin is the hook JSON — do not steal it with a python heredoc.
set -u

CODE=$(cat <<'PY'
import json
import os
import re
import sys

def emit(obj):
    sys.stdout.write(json.dumps(obj, separators=(",", ":")) + "\n")
    sys.exit(0)

def emit_nothing():
    emit({})

raw = sys.stdin.read()
try:
    data = json.loads(raw) if raw.strip() else {}
except json.JSONDecodeError:
    emit_nothing()
if not isinstance(data, dict):
    emit_nothing()

event = str(data.get("hook_event_name") or "")
conversation_id = str(data.get("conversation_id") or "")
if not re.fullmatch(r"[a-zA-Z0-9-]+", conversation_id):
    emit_nothing()

def as_int(value):
    if isinstance(value, bool) or value is None:
        return None
    if isinstance(value, int):
        return value if value >= 0 else None
    if isinstance(value, float):
        return int(value) if value >= 0 else None
    if isinstance(value, str) and value.isdigit():
        return int(value)
    return None

tokens = as_int(data.get("context_tokens"))
window = as_int(data.get("context_window_size")) or 0
percent = as_int(data.get("context_usage_percent"))
status = str(data.get("status") or "")

state_dir = os.path.join(os.environ.get("TMPDIR") or "/tmp", "cursor-harness-context-governor")
try:
    os.makedirs(state_dir, mode=0o700, exist_ok=True)
except OSError:
    emit_nothing()
state_path = os.path.join(state_dir, conversation_id)

fired = 0
warned_level = 0
try:
    with open(state_path, encoding="utf-8") as fh:
        for line in fh:
            key, _, value = line.strip().partition("=")
            if not value.isdigit():
                continue
            if key == "fired":
                fired = int(value)
            elif key == "warned_level":
                warned_level = int(value)
except OSError:
    pass
if warned_level > 2:
    warned_level = 0
if fired not in (0, 1):
    fired = 0

def write_state():
    try:
        with open(state_path, "w", encoding="utf-8") as fh:
            fh.write(f"fired={fired}\nwarned_level={warned_level}\n")
    except OSError:
        pass

if percent is None:
    percent = 0
if window > 0:
    soft = window * 60 // 100
    hard = window * 80 // 100
    if tokens is not None:
        percent = tokens * 100 // window
else:
    soft = 160_000
    hard = 220_000

if tokens is not None:
    if tokens >= hard:
        level = 2
    elif tokens >= soft:
        level = 1
    else:
        level = 0
elif percent >= 80:
    level = 2
elif percent >= 60:
    level = 1
else:
    level = 0

def ring_label():
    tokens_k = (tokens or 0) // 1000
    window_k = window // 1000
    if window_k > 0:
        return f"{tokens_k}k / {window_k}k tokens ({percent}% on the context ring)"
    if tokens is not None:
        return f"{tokens_k}k tokens on the context ring"
    return f"{percent}% on the context ring"

if event == "preCompact":
    fired = 0
    warned_level = 0
    write_state()
    emit({"user_message": f"Cursor is compacting context ({ring_label()})."})

if event == "stop":
    if status and status != "completed":
        emit_nothing()
    if fired or level < 1:
        write_state()
        emit_nothing()
    fired = 1
    warned_level = level
    write_state()
    emit({
        "followup_message": (
            "Continue the in-progress skill. Do not run /summarize. "
            "If you announced a command, invoke it as a tool/Shell call now. "
            "Wait for long gates to finish in this sitting."
        )
    })

if event == "postToolUse":
    if level < 1 or level <= warned_level:
        write_state()
        emit_nothing()
    warned_level = level
    write_state()
    emit({
        "additional_context": (
            f"Context governor: Cursor's context ring is at {ring_label()}. "
            f"Do not compact and do not end this turn. Invoke the next "
            f"required tool/Shell call now. Compact with /summarize only "
            f"after that command has started or the skill has finished."
        )
    })

write_state()
emit_nothing()
PY
)
python3 -c "$CODE" || printf '{}\n'
exit 0
