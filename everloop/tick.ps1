# everloop (Windows) — run ONE bounded step in a FRESH process over durable on-disk state, then exit.
# Chain on a schedule (pm2/Task Scheduler) for indefinite operation. Each tick is a new process,
# so no single context accumulates — that's how an everloop agent survives context-window limits.
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

$lock = ".everloop-lock"
if (Test-Path $lock) { Write-Host "everloop: a tick is already running; skipping."; exit 0 }
$PID | Out-File $lock
try {
  # 1. BOOT — rehydrate cheaply from the boot block.
  if (Test-Path state/RESUME.md) { Write-Host "everloop: booting from state/RESUME.md"; Get-Content state/RESUME.md | ForEach-Object { "  | $_" } }

  # 2. STEP — one bounded unit of work. Swap for a Claude Code /tick (see docs/).
  $step = if ($env:EVERLOOP_STEP) { $env:EVERLOOP_STEP } else { "examples/counter/step.sh" }
  Write-Host "everloop: running step -> $step"
  bash $step

  # 3. EXIT — state is on disk; the process/context is discarded; next tick starts clean.
  Write-Host "everloop: tick complete; exiting. State persisted to disk."
}
finally { Remove-Item $lock -Force -ErrorAction SilentlyContinue }
