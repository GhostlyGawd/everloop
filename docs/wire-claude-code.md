# Wiring everloop to Claude Code (or any agent)

The demo step just increments a counter. To build a real autonomous agent, replace it with a step
that invokes your model once per tick. The contract is the same: **boot from state → do ONE
bounded thing → write state → exit.**

## 1. Define what one tick does

Create a slash command in your repo at `.claude/commands/tick.md` describing a single bounded
action, e.g.:

```markdown
# /tick
1. Read state/RESUME.md and the tail of state/ledger.md to reconstitute context.
2. Pick the ONE highest-value next action and do it (bounded — finish within this tick).
3. Append a one-line entry to state/ledger.md describing what you did + evidence.
4. Regenerate state/RESUME.md so the next fresh tick can resume.
5. Commit (and push) the state change. Then stop.
```

## 2. Point the step at Claude Code

Set the step to a headless Claude Code run and let everloop drive it:

```bash
# examples/claude/step.sh
claude --print "/tick"
```

```bash
EVERLOOP_STEP=examples/claude/step.sh pm2 start ecosystem.config.cjs
```

Each cron fire spawns a **fresh** `claude` process with an empty context window. It reads
`RESUME.md`, does one tick, writes state, and exits — so the agent runs indefinitely without any
session filling up.

## 3. Keep ticks bounded and idempotent

- One action per tick. Decompose big work across ticks; never assume unbounded context.
- Make the boot block (`RESUME.md`) small (< ~2k tokens) so cold starts stay cheap.
- Read the ledger **tail**, not the whole file.
- Commit state atomically so an interrupted tick is safe to re-run.

## 4. Recommended guards (bring your own, or wait for the roadmap)

- **Verify before "done":** have an independent step/agent check claims rather than self-grading.
- **Don't game the metric:** measure success from an external source, not self-report.
- **Block secrets:** scan staged changes before committing in a tick.

These are exactly the patterns everloop is being extracted from. They'll land as an optional
guard layer — see the README roadmap.
