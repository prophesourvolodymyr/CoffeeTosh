# N1 - Coffeetosh System (LidCaf Core Engine)

**Date:** 2026-03-02
**Status:** 💡 Raw Idea

---

## The Idea

Build the core system engine for **LidCaf** — a macOS utility that prevents a MacBook from sleeping when the lid is closed, specifically to maintain active SSH connections for headless operation.

Apple strictly forces sleep on lid-close unless the machine is on AC power with an external display connected. The standard `IOPMAssertion` API is insufficient for lid-closed battery operation. The only reliable bypass is using `pmset -a disablesleep 1` combined with a `caffeinate` process. This app must wrap that approach cleanly.

## Core Logic Components

### 1. SleepManager
- Executes `pmset -a disablesleep 1` to disable system sleep on lid close.
- Spawns a `caffeinate` process as a secondary safety net.
- Tracks original `pmset` settings so they can be restored.
- Handles timer-based durations (1–24 hours, or indefinite).
- Manages state via a shared mechanism (UserDefaults or a local status file) so GUI and CLI stay in sync.

### 2. CLI Tool (`lidcaf`)
- A standalone command-line executable usable over SSH.
- Commands: `lidcaf start [hours]`, `lidcaf stop`, `lidcaf status`.
- Reads/writes the same state file or UserDefaults as the GUI app.
- If started via CLI, the Menu Bar icon in the GUI must reflect the active state.
- If stopped from the GUI, the CLI daemon/process must also terminate.

### 3. Safety & Cleanup (Critical)
- On timer expiry → restore original `pmset` sleep settings.
- On user "Stop" action → restore settings.
- On app crash or unexpected quit → use `applicationWillTerminate`, signal traps (`SIGINT`, `SIGTERM`, `SIGHUP`) in the CLI, and potentially a launchd cleanup mechanism.
- **Must never leave the system in a "sleep disabled" state after the app is gone.**

### 4. Privilege Escalation
- `pmset` requires root/admin privileges.
- Use `NSAppleScript` with `"administrator privileges"` to execute `pmset` changes securely.
- Request admin once per session ideally, not on every toggle.

### 5. Build System (`build.sh`)
- Compile Swift source using `swiftc` (no Xcode project required).
- Assemble the `.app` bundle (Contents/MacOS, Contents/Resources, Info.plist).
- Place CLI tool alongside or provide symlink instructions for `/usr/local/bin/lidcaf`.
- Package final `.app` into a mountable `LidCaf.dmg` via `hdiutil`.

## Why This Matters

Developers and sysadmins who SSH into their MacBooks need the machine to stay awake with the lid closed. Apple provides no first-party solution for this on battery. This removes the friction entirely — one toggle or one CLI command.

## Who Benefits

- Developers running headless MacBook servers.
- Sysadmins managing remote machines.
- Anyone who needs SSH persistence with a closed lid on battery.
