#!/usr/bin/env bash
# everloop — run ONE bounded step in a FRESH process over durable on-disk state, then exit.
# Chain these on a schedule (pm2/cron) for indefinite operation. Because each tick is a new
# process, no single context/memory ever accumulates — that's how an everloop agent survives
# context-window limits and runs 24/7.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

LOCK=".everloop-lock"
if [ -f "$LOCK" ]; then echo "everloop: a tick is already running ($LOCK); skipping."; exit 0; fi
echo $$ > "$LOCK"; trap 'rm -f "$LOCK"' EXIT

# 1. BOOT — a fresh process rehydrates cheaply from the boot block (not from memory).
if [ -f state/RESUME.md ]; then echo "everloop: booting from state/RESUME.md"; sed 's/^/  | /' state/RESUME.md; fi

# 2. STEP — do one bounded unit of work. Swap this for a Claude Code /tick (see docs/).
STEP="${EVERLOOP_STEP:-examples/counter/step.sh}"
echo "everloop: running step → $STEP"
bash "$STEP"

# 3. EXIT — state is on disk; the process (and its context) is discarded. Next tick starts clean.
echo "everloop: tick complete; exiting. State persisted to disk."
