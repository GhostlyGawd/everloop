#!/usr/bin/env bash
# everloop step, backed by Claude Code. ONE tick = one FRESH `claude` process (empty context)
# that reads the boot block, does ONE bounded thing, updates state, and exits. Chained by
# everloop/tick.sh on a schedule, this is an agent that runs indefinitely without filling context.
#
# Cost & auth: this spends Claude tokens and needs the `claude` CLI installed + authenticated.
# Run it with:   EVERLOOP_STEP=examples/claude/step.sh bash everloop/tick.sh
# (the dependency-free counter demo is the default step; this is the real-agent example.)
set -uo pipefail

if ! command -v claude >/dev/null 2>&1; then
  echo "examples/claude: the 'claude' CLI is not on PATH. Install Claude Code, or use the counter demo." >&2
  exit 3
fi

# The bounded instruction for a single tick. Self-contained (no slash command needed).
read -r -d '' PROMPT <<'EOF' || true
You are exactly ONE tick of an everloop agent. Your whole job is one small, bounded step, then exit.
1. Read state/RESUME.md (your boot block) and the last ~10 lines of state/ledger.md for context.
2. Read state/GOAL.md for the objective. Do exactly ONE small action toward it — finish it within
   this tick. If GOAL.md is missing or the goal is already met, just record a brief status instead.
3. Append ONE line to state/ledger.md: what you did + any evidence (a path, a command, a result).
4. Rewrite state/RESUME.md (keep it under ~30 lines) so the NEXT fresh tick can resume with no memory
   of this one. State on disk is the only thing that carries over.
Do not do more than one action. Do not loop. Stop when the four steps are done.
EOF

# --print runs once and exits (no chat loop); the fresh context is discarded on exit.
exec claude --print "$PROMPT"
