<h1 align="center">everloop</h1>

<p align="center"><b>Your autonomous agent dies when its context window fills up. everloop is the fix.</b></p>

<p align="center">
A tiny, dependency-free starter kit for agents that run <b>24/7</b> by executing bounded
<b>ticks</b> over durable on-disk state — surviving context limits, crashes, and restarts.
</p>

---

## The problem

Every "autonomous agent" hits the same wall: a single LLM session has a **finite context
window**. Run a long loop in one session and it slowly fills up, degrades, forgets, and dies.
Bolting on summarization just delays the funeral.

## The idea

Don't keep the agent alive. Keep its **state** alive.

```
  scheduler ─fires every N min─┐
                               ▼
   ┌─────────── one TICK = a FRESH process (empty context) ───────────┐
   │  boot from RESUME.md  →  do ONE bounded step  →  write state  →   │ ──► exit (context discarded)
   └──────────────────────────────────────────────────────────────────┘
                               │  state lives on disk (git)
                               ▼
              next fire = another fresh process, resumes from disk
```

No single process accumulates context, so **nothing ever fills up**. The loop is immortal
because each link in it is disposable. Memory is files (a boot block + an append-only ledger),
so a crashed or missed tick just means the next one resumes — no recovery code needed.

## 10-second demo (no API key, no dependencies)

```bash
git clone https://github.com/GhostlyGawd/everloop && cd everloop
bash everloop/tick.sh   # run it 3 times
bash everloop/tick.sh
bash everloop/tick.sh
cat state/counter.txt   # => 3
```

Three **separate processes**, each starting cold, advanced a counter `1 → 2 → 3` with **no shared
memory** — only `state/`. That's the whole trick. Now swap the demo step for a real Claude Code
`/tick` and you have an agent that runs forever. → [`docs/wire-claude-code.md`](docs/wire-claude-code.md)

## What you get

- **`everloop/tick.sh` / `.ps1`** — the bounded tick driver (lock → boot → one step → persist → exit).
- **`state/`** — durable memory: a regenerated `RESUME.md` boot block + an append-only `ledger.md`.
- **`examples/counter/`** — the dependency-free demo above (runnable in CI, proves the mechanic).
- **`ecosystem.config.cjs`** — pm2 driver: one tick per cron fire in a fresh process. Or use cron/systemd.
- **`docs/wire-claude-code.md`** — turn each tick into a Claude Code run.

## Run it forever

```bash
npm i -g pm2
pm2 start ecosystem.config.cjs   # one tick per interval, each a fresh process
pm2 logs everloop                # watch
```

Because state is just files in git, the scheduler is swappable (pm2, cron, systemd, a cloud
routine) and you can move the agent between machines without losing a thing.

## Why not just use \<X\>?

everloop is intentionally *small* and *unopinionated*. It is **not** a general agent framework,
a memory database, or a workflow engine — it's the ~50 lines of loop + state plumbing that those
tools leave you to assemble yourself. Bring your own model and your own step logic; everloop just
makes the loop survive.

## Status

`v0.1.0` — minimal but real. The core mechanic works and is tested. Roadmap: richer state
helpers, a Claude Code reference agent, and a verification/guard layer. Issues and PRs welcome.

## License

[MIT](LICENSE).
