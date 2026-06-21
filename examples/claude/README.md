# examples/claude — a Claude Code agent that never dies

This is the reference example: each everloop tick is one fresh `claude` process. The agent reads
its boot block, does **one bounded thing**, writes state, and exits — so it runs forever without a
context window ever filling up.

## Run it

```bash
# from the repo root. Requires the `claude` CLI installed + authenticated. Spends tokens.
echo "Goal: keep a running TODO of improvements to this repo in state/GOAL.md" > state/GOAL.md
EVERLOOP_STEP=examples/claude/step.sh bash everloop/tick.sh   # one tick
EVERLOOP_STEP=examples/claude/step.sh bash everloop/tick.sh   # another, fresh context
```

Each run is a brand-new `claude --print` process. It rehydrates from `state/RESUME.md`, advances the
goal by one step, appends to `state/ledger.md`, and regenerates `RESUME.md` for the next tick.

## Run it forever

```bash
EVERLOOP_STEP=examples/claude/step.sh pm2 start ecosystem.config.cjs
pm2 logs everloop
```

## How `step.sh` works

It calls `claude --print "<one-tick instruction>"`. The instruction is deliberately bounded —
**one action per tick** — and tells the model that on-disk state is the only thing that carries
over. That single rule is what keeps each context small and the loop immortal.

## Make it yours

- Put your real objective in `state/GOAL.md`.
- Edit the prompt in `step.sh`, or point it at a repo slash command (`claude --print "/tick"`) and
  define `/tick` in `.claude/commands/tick.md` (see [`../../docs/wire-claude-code.md`](../../docs/wire-claude-code.md)).
- Keep ticks bounded and idempotent; keep `RESUME.md` small. That's the whole discipline.

## A note on trust

If your agent commits or reports results, verify them against the **source of record** (the remote,
the live API) — not a local copy that can go stale. Self-reported success is not success. (This
lesson was learned the hard way; see the everloop roadmap's "verification/guard layer.")
