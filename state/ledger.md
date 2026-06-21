# Ledger — append-only

One line per tick. This is the durable trace; a fresh process reads `state/RESUME.md` (the boot
block) for quick context and this ledger tail for history. Never edit past lines.

