#!/usr/bin/env bash
# Dependency-free demo step (no API key, no LLM). It increments a counter that lives ONLY on
# disk — proving state survives across separate, fresh processes. This is the everloop mechanic
# in miniature. To build a real agent, swap this file for a Claude Code /tick that reads
# state/RESUME.md, does one action, and regenerates the boot block (see docs/wire-claude-code.md).
set -uo pipefail
mkdir -p state

COUNT_FILE="state/counter.txt"
n=$(cat "$COUNT_FILE" 2>/dev/null || echo 0)
n=$((n + 1))
echo "$n" > "$COUNT_FILE"

ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "- tick $n @ $ts (pid $$): counter advanced to $n" >> state/ledger.md

# Regenerate the boot block so the NEXT fresh process resumes correctly with no shared memory.
cat > state/RESUME.md <<EOF
# RESUME — boot block (regenerated every tick)
Counter is at **$n**. The next tick will advance it to $((n + 1)).
A fresh process reads this to resume; nothing is remembered between ticks except this file + state/.
EOF

echo "step: counter → $n  (pid $$)"
