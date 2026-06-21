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

The big, mature agent projects are excellent — and solve a *different* problem. everloop is the
small survival primitive they each assume you've already built. Honest comparison:

| You're looking at… | What it actually is | Why everloop is different |
|---|---|---|
| **claude-flow** | A multi-agent **swarm orchestrator** — spin up fleets of agents, route tasks between them. Much larger & more mature. | everloop runs **one** loop and has *no* opinion about agents, swarms, or routing. It's the disposable-process-over-durable-state trick underneath, not a fleet manager. |
| **LangGraph** | A **graph workflow framework** with checkpointers; you model your app as nodes/edges and *assemble* persistence from its primitives. | everloop isn't a framework you build inside. It's ~50 lines of loop + `state/` you own outright. No graph, no DSL, bring your own step logic. |
| **Letta / MemGPT** | **Tiered memory** — self-editing context so an agent remembers more *within* a session. | Complementary, not competing. Letta answers "what does the agent remember?"; everloop answers "how does the **process** never die?" Use both: Letta for memory, everloop for the immortal loop. |
| **A cron job + a script** | The closest honest analogue — and a fine start. | everloop is that, plus the parts you'd hand-roll next: a regenerated boot block, an append-only ledger, a tick lock, and a swappable scheduler. ~50 lines so you can read all of it. |

**The one-line test:** if your problem is *"my long-running agent fills its context window and
dies,"* everloop is aimed squarely at it. If your problem is orchestration, memory, or workflow
modeling, reach for the projects above — and wrap them in an everloop tick so they survive.

## Status

`v0.1.0` — minimal but real. The core mechanic works and is tested. Roadmap: richer state
helpers, a Claude Code reference agent, and a verification/guard layer. Issues and PRs welcome.

## License

[MIT](LICENSE).
