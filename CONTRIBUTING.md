# Contributing to everloop

everloop is intentionally tiny — ~50 lines of loop + state. Contributions that keep it small,
honest, and dependency-free are very welcome.

## Principles

- **Stay minimal.** everloop is a *primitive*, not a framework. If a feature belongs in a bigger
  tool (orchestration, memory, workflows), it probably doesn't belong here.
- **Dependency-free core.** The counter demo and tick driver must run from a clean checkout with no
  install. New examples may add deps, but keep them in `examples/<name>/`.
- **Bounded + idempotent.** Anything tick-related must do one bounded unit of work and be safe to
  re-run.
- **Honesty over polish.** Don't claim behavior that isn't there. Verify results against the source
  of record (remote / live API), not a local copy — self-reported success is not success.

## How to contribute

1. Open an issue describing the change (bug, example, doc, or a small core improvement).
2. Fork, branch, and keep the diff focused.
3. Make sure the demo still works from a clean checkout:
   ```bash
   bash everloop/tick.sh && bash everloop/tick.sh && cat state/counter.txt   # => 2
   ```
4. Open a PR linking the issue. Describe what you changed and how you verified it.

## Good first contributions

- New `examples/<runtime>/` showing everloop with a different model/CLI.
- Doc clarity, typo fixes, a clearer diagram.
- Portability fixes for the `.sh` / `.ps1` drivers across shells.

Be kind, be concise, and assume good faith. Thanks for helping keep the loop running.
