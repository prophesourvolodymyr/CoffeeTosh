<div align="center">

<img src="WEBSITE/assets/Banner%20Read%20Me.png" alt="Coffeetosh — Lid closed. Mac awake." width="800"/>

# Coffeetosh

**Keep your MacBook alive with the lid closed. One command.Easy to use. Forever free.**

macOS 13+ &nbsp;·&nbsp; Swift &nbsp;·&nbsp; MIT License

[![Download](https://img.shields.io/badge/Download-.dmg-D4923A?style=flat-square&logo=apple&logoColor=white)](https://github.com/prophesourvolodymyr/CoffeeTosh/releases/latest/download/CoffeeTosh.dmg)
[![License: MIT](https://img.shields.io/badge/License-MIT-A89680?style=flat-square)](LICENSE)

</div>

---

## What is Coffeetosh?

Coffeetosh is a macOS menu bar app and CLI tool that prevents your MacBook from sleeping when the lid is closed. It is designed for SSH workflows, overnight tasks, and anyone who needs their Mac to keep running while physically closed — without disabling sleep globally or using unsafe kernel tricks.

- **Menu bar app** — one-click start/stop with session timer and status
- **Full CLI** — start, stop, monitor, add time, and configure from your terminal
- **Two modes** — Lid Closed (headless server) and Keep Awake (lid open, no idle sleep)
- **Automatic restore** — all system settings return to exactly what they were before
- **Lid-open password lock** — when the lid opens mid-session, macOS locks the screen automatically
- **No root hacks** — uses standard `pmset`, `caffeinate`, and IOKit APIs only

---

## Installation

### Option A — Download the app

1. Download [CoffeeTosh.dmg](https://github.com/prophesourvolodymyr/CoffeeTosh/releases/latest/download/CoffeeTosh.dmg)
2. Open the `.dmg` and drag **Coffeetosh.app** to `/Applications`
3. Launch the app, then enable the CLI from the menu bar:
   **Menu bar icon → Settings → Install CLI Tool**

### Option B — Homebrew

```bash
brew install coffeetosh
```

---

## Quick Start

```bash
# Start an 8-hour Lid Closed session (default)
coffeetosh start

# Start with explicit duration and mode
coffeetosh start 4 --mode keep-awake

# Check what's running
coffeetosh status

# Add 30 minutes to the current session
coffeetosh add

# Stop and restore everything
coffeetosh stop
```

---

## Two Modes

| Mode | Flag | Use case | Admin required |
|------|------|----------|----------------|
| **Lid Closed** | `--mode coffeetosh` (default) | Headless server, SSH, overnight tasks | Yes — `pmset` once at start, once at stop |
| **Keep Awake** | `--mode keep-awake` | Presentations, downloads, monitoring | No |

Add `--low-power` to any Lid Closed session to simultaneously enable macOS Low Power Mode. It is restored automatically on stop.

```bash
coffeetosh start 8 --low-power
```

---

## CLI Reference

| Command | Description |
|---------|-------------|
| `coffeetosh start [hours] [flags]` | Start a session |
| `coffeetosh stop` | Stop and restore all system settings |
| `coffeetosh status` | Show current session state |
| `coffeetosh add [minutes]` | Extend a running session (default: +30 min) |
| `coffeetosh preset set <mode> <duration>` | Save a Quick Preset |
| `coffeetosh preset clear` | Remove the saved preset |
| `coffeetosh battery` | Show battery percentage and charge state |
| `coffeetosh mac-temp` | Show CPU and GPU die temperatures |
| `coffeetosh install-cli` | Create `/usr/local/bin/coffeetosh` symlink |
| `coffeetosh help` | Print the inline usage reference |

### `start` flags

| Flag | Default | Description |
|------|---------|-------------|
| `[hours]` | `8` | Session duration in hours. Use `0` for indefinite. |
| `--mode <mode>` | `coffeetosh` | `coffeetosh` / `lid-closed` or `keep-awake` |
| `--low-power` | off | Enable macOS Low Power Mode for the session |
| `--minutes` / `-m` | — | Specify duration in minutes instead of hours |

---

## How Lid Closed Mode Works

When you run `coffeetosh start` with Lid Closed mode, the following happens in order:

**Step 1 — Admin password: `pmset -a disablesleep 1`**
The CLI prompts for your macOS admin password once. This runs `pmset -a disablesleep 1` via `sudo`, telling the macOS power management kernel extension to ignore the clamshell (lid) sensor. No kernel extensions, no SIP bypass, no root access stored. The original `pmset` state is captured first so it can be restored exactly.

**Step 2 — Daemon spawns detached, CLI exits**
The CLI launches `coffeetosh-daemon` as a fully detached background process (no `waitUntilExit()`). The daemon is orphaned from the CLI immediately and survives terminal closes, SSH disconnects, and parent app quits. The CLI writes `~/.coffeetosh/status.json` with the session metadata, then exits.

**Step 3 — `caffeinate -is` holds sleep prevention**
The daemon starts `caffeinate -is` as a child subprocess. `-i` prevents idle sleep, `-s` prevents system sleep. Combined with the `pmset` flag from Step 1, macOS cannot sleep regardless of lid state.

**Step 4 — IOKit polls the lid every 5 seconds**
The daemon reads `AppleClamshellState` from `IOPMrootDomain` via IOKit on a 5-second tick loop — the same registry value macOS itself uses to detect lid transitions. On lid close it saves the current display brightness to `status.json` and dims the display to minimum.

**Step 5 — Lid opens → macOS password lock screen**
When the daemon detects lid-open, it immediately calls `CGSession -suspend`. This is identical to pressing **Ctrl+Cmd+Q** and is enforced by `securityd` — killing Coffeetosh does not unlock the screen. The daemon also restores the saved display brightness.

**Step 6 — Session ends → full restore**
On timer expiry, `coffeetosh stop`, or any SIGINT/SIGTERM/SIGHUP signal, the daemon restores `pmset` to the exact snapshot from Step 1 (requires admin password once), terminates `caffeinate`, restores brightness, and marks the session inactive.

```
coffeetosh start                 coffeetosh-daemon (detached)
|                                    |
|-- sudo pmset -a disablesleep 1     |
|   (admin password, once)           |
|-- spawn daemon ------------------> |  caffeinate -is  (holds sleep prevention)
|-- write status.json                |  IOKit lid poll  (every 5 seconds)
`-- exit                             |
                                     |
--------- lid closes --------------- |
                                     |-- save brightness to status.json
                                     |-- set display to minimum
                                     `-- Mac keeps running (SSH, processes...)

--------- lid opens ---------------- |
                                     |-- CGSession -suspend
                                     `-- macOS password lock screen (OS-level)

-- stop / timer / SIGTERM ---------- |
                                     |-- restore pmset  (admin password, once)
                                     |-- kill caffeinate
                                     |-- restore brightness
                                     `-- exit
```

> **Password note:** Asked exactly twice — once at start, once at stop. Never stored. Piped to `sudo -S` via stdin with echo disabled, pipe closed immediately. If your `sudo` token is still valid, no prompt appears at all.

---

## Architecture

```
Coffeetosh.app / coffeetosh (CLI)
├── CoffeetoshCore           — Shared Swift library
│   ├── SleepManager         — Dual-mode engine (IOKit + pmset + caffeinate)
│   ├── DaemonLauncher       — Spawns and detaches coffeetosh-daemon
│   ├── LidStateMonitor      — IOKit AppleClamshellState polling
│   ├── CaffeinateProcess    — caffeinate -is subprocess wrapper
│   ├── StatusFileManager    — JSON state (~/.coffeetosh/status.json)
│   ├── PrefsFileManager     — User prefs (Quick Preset, SSH monitor flag)
│   ├── SSHMonitor           — Watches syslog for SSH connection events
│   └── ACPowerMonitor       — Tracks charger connect/disconnect
├── coffeetosh-daemon        — Detached background process (countdown + lid monitor)
├── coffeetosh               — CLI tool (start, stop, status, add, preset...)
└── coffeetosh-cleanup       — Boot-time recovery (registered as LaunchDaemon)
```

---

## Building from Source

Requires Xcode 15+ or Swift 5.9+, macOS 13 Ventura or later.

```bash
git clone https://github.com/prophesourvolodymyr/CoffeeTosh.git
cd CoffeeTosh

# Build all targets
swift build

# Run the CLI
.build/debug/coffeetosh help

# Run the daemon (for testing — normally launched by the CLI)
.build/debug/coffeetosh-daemon

# Open the Mac app in Xcode
open CoffeeTosh/CoffeeTosh.xcodeproj
```

---

## Contributing

Pull requests and issues are welcome. The codebase is plain Swift with no external dependencies. `CoffeetoshCore` is a Swift Package library; the CLI, daemon, and cleanup tool are standalone executables built via SPM.

Please keep changes focused and test that `coffeetosh stop` correctly restores `pmset` after every modification to the sleep prevention logic.

---

## License

MIT — see [LICENSE](LICENSE) for details.

---

<div align="center">
Made with ☕ by <a href="https://github.com/prophesourvolodymyr">Volodymyr</a>
</div>
