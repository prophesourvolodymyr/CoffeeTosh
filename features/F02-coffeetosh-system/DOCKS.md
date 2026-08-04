# F02 — Coffeetosh System

The shared macOS sleep-prevention engine, CLI, detached daemon, state persistence, lid monitoring, recovery, and security behavior.

## What We Build

- Keep Awake and Lid Closed session modes.
- Detached countdown daemon that survives GUI and terminal exit.
- `pmset`, `caffeinate`, IOKit, brightness, and status-file coordination.
- Lid-open screen locking and complete restoration of system state.
- CLI commands, presets, status reporting, and recovery behavior.

## Existing Documentation

- `F2-Doc.md` — migrated system-engine specification.
- `F2-Progress.md` — migrated implementation history.
- `../../genesis/ARCHITECTURE.md` — migrated technical architecture.

## Dependencies

- F01 — visual and brand conventions apply to the user-facing controls.
