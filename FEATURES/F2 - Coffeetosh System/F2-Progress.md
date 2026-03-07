# 📊 F2 - Coffeetosh System Progress Tracker
**Status:** ✅ Complete (Phase 10 — Bug Fix Sprint)
**Last Updated:** 2026-03-05
**Source:** R1-Coffeetosh-System-Documentation.md

---

## 🧑 USER TODOS (Manual Setup Required)
*Tasks the user must complete before development can proceed.*
- [ ] **Environment Setup:** Initialize Xcode workspace configured for macOS CLI and Menu Bar Application (Minimum Target: macOS 13 - Ventura).
- [ ] **Provisioning:** Ensure ad-hoc signing configuration is clear of sandboxing rules to allow `NSAppleScript` admin executions.
- [ ] **Homebrew Publishing:** Create a Homebrew tap (`homebrew-coffeetosh`) and write a formula so users can `brew install coffeetosh/tap/lidcaf` for CLI-only distribution.

---

## 📋 PHASE 1: Data Models & Environment Preparation
*Scaffolding the shared brain of the application.*

- [x] Create `status.json` schema struct (Codable) ensuring definitions for `active`, `mode`, `daemonPid`, and `startTime`.
- [x] Build the `FileSystemWatcher` logic using `DispatchSource.makeFileSystemObjectSource` to monitor file changes natively.

---

## 🏗️ PHASE 2: Dual-Mode Engine Construction (`SleepManager.swift`)
*Implementing the primary macOS system interfaces.*

- [x] **Mode A (Keep Awake):** Implement `IOPMAssertionCreateWithName` for standard user-idle system sleep prevention (No Admin).
- [x] **Mode B (Headless):** Implement `NSAppleScript` wrapper capturing `sudo pmset -a disablesleep 1`.
- [x] Store original macOS `pmset -g` configurations in memory to guarantee perfect restoration.
- [x] Fork proper `caffeinate -dis` subprocess.

---

## 🧠 PHASE 3: Background Daemon & IPC
*The standalone process executing physics when the GUI dies.*

- [x] Configure `lidcaf-daemon` as a separate Swift executable.
- [x] Inject Daemon file read/write lifecycle (daemon checking timer vs `status.json`).
- [x] Mount Signal traps (`SIGINT`, `SIGTERM`, `SIGHUP`) returning system defaults unconditionally upon death.
- [x] Establish Process Detachment protocol (GUI spawns Daemon via `Process()` then immediately detaches lock).

---

## 📡 PHASE 4: Command Line Interface (CLI) Integration
*Adding terminal control for SSH users.*

- [x] Establish ArgParser mapping for `lidcaf start [hours]` and `lidcaf status`.
- [x] Create `lidcaf install-cli` utility symlinking `/Applications/.../MacOS/lidcaf` directly into `/usr/local/bin/lidcaf`.

---

## 🛡️ PHASE 5: Advanced System Monitors (Settings Implementations)
*Building the intelligent automations from settings.*

- [x] **SSH Monitor:** Create continuous background poll using `netstat -an | grep '\.22 '` tracking ESTABLISHED states, configuring safe 60s drop-grace periods.
- [x] **AC Power Hooks:** Subscribe to `NSWorkspace.didWakeNotification` or `IOKit` power change events to force-trigger last-used durations upon plugging in.

---

## 🚑 PHASE 6: Failsafe & Boot Crash Recovery
*The deepest safety layer against broken batteries.*

- [x] Create `~/Library/LaunchAgents/com.coffeetosh.lidcaf.cleanup.plist` Boot-time script.
- [x] Program `lidcaf-cleanup` to inspect JSON for ghosted `daemonPid`. 
- [x] Connect fallback parameters to `pmset -a disablesleep 0` if panic failure is inherently unresolvable.
- [x] Prepare Build Script (`build.sh`) automating multi-binary compile (Daemon vs App) into a unified `.dmg` installer.

---

## 🐛 BUGFIXES

- [x] **IOPMAssertion Process Lifecycle Fix:** Moved sleep-prevention activation from CLI → Daemon. IOPMAssertions are tied to the process that creates them — the CLI exited immediately, killing the assertion. Now the daemon (long-running) holds the assertion. CLI only writes `status.json`; daemon reads it and calls `SleepManager.activate()`. Added foreground-mode fallback with RunLoop if daemon binary is missing.
- [x] **Brightness Nudge Indicator:** Added `BrightnessHelper.swift` — bumps display brightness up 1 notch (+6.25%) on activate, restores original on deactivate. Visual confirmation that Coffeetosh is active. Uses IOKit `IODisplaySetFloatParameter` (built-in displays only).
- [x] **Dual Sleep Assertion (Mode A):** Mode A only prevented system sleep, not display sleep. Added second `IOPMAssertionCreateWithName` with type `PreventUserIdleDisplaySleep` alongside `PreventUserIdleSystemSleep`. Both assertions now held by daemon.
- [x] **Mode B Admin Dialog Fix:** Daemon is a background process with no GUI — `NSAppleScript` admin dialog failed silently. Split Mode B activation: CLI runs `sudo pmset -a disablesleep 1` (has TTY), daemon calls `activateModeBDaemonOnly()` (only starts caffeinate). Added `preActivateModeBAdmin()` and `skipAdmin` parameter.
- [x] **Sudo TTY / Password Visibility Fix:** `NSAppleScript` blocked in terminal context. Replaced with `runWithSudo()` using `termios` to disable terminal echo, `readLine()` for password input, and `sudo -S` piped via `zsh -c` for non-interactive admin execution. Password is never visible on screen.
- [x] **Stop Command Stale Status Fix:** CLI's `SleepManager.shared.isActive` was always false (daemon activated, not CLI), so `restore()` bailed out and never cleaned `status.json`. Fixed by directly calling `StatusFileManager.markInactive()` in stop flow instead of relying on SleepManager state.
- [x] **Stale Status.json on Failed Start:** `StatusFileManager.write()` was called BEFORE admin password prompt — if user cancelled, status showed active. Moved write to AFTER admin success.

---

## 🆕 PHASE 7: Quality-of-Life Features

- [x] **`coffeetosh add [minutes]` Command:** Extends active session duration. Default 30 minutes. Updates `durationSeconds` in `status.json` — daemon picks up change on next 5-second tick. Validates daemon is actually running (PID check) before modifying; auto-cleans stale sessions.
- [x] **`--low-power` Flag:** Optional flag for headless mode. Enables macOS Low Power Mode via `sudo pmset -a lowpowermode 1` on start, automatically restores on stop. Created `PowerSavingHelper.swift` utility that tracks whether Low Power Mode was already enabled to avoid disabling user's own setting.
- [x] **Minimum Brightness for Headless:** ~~When headless mode activates, display brightness is set to minimum immediately.~~ **Replaced by lid detection** — brightness now managed by `LidStateMonitor` in daemon (see Phase 8).
- [x] **Cross-Process Brightness Persistence:** `originalBrightness` persisted to `status.json` so daemon, stop CLI, and crash handler can all restore brightness correctly. Previously brightness was saved in CLI process memory and lost across process boundaries.

---

## 🆕 PHASE 8: Lid State Detection

- [x] **`LidStateMonitor.swift`:** New IOKit utility that reads `AppleClamshellState` from `IOPMrootDomain`. Polls on daemon's 5-second tick loop. Detects open/close transitions via edge detection (`previousClosed` state tracking).
- [x] **Daemon Integration:** Daemon polls lid state on every tick. On lid close → saves current brightness to `status.json`, sets display to minimum. On lid open → restores brightness from `status.json`. Only active for headless mode.
- [x] **Initial Lid State:** If lid is already closed at daemon start (e.g., started via SSH), applies minimum brightness immediately.
- [x] **Status.json `lidClosed` Field:** Daemon writes current lid state to `status.json` on each transition. Status command reads it.
- [x] **Status Command:** Shows "Lid: Closed 🔒" / "Lid: Open 🔓" and "Low Power Mode: ON ⚡" in `coffeetosh status` output.
- [x] **Removed CLI-side brightness:** `PowerSavingHelper.activate()` no longer called from CLI start. All brightness management is now daemon-driven via lid events.
- [x] **`--low-power` stays session-wide:** Low Power Mode is enabled at start (CLI has TTY for sudo) and disabled at stop. Cannot toggle dynamically from daemon (no TTY for sudo authentication).

---

## 🆕 PHASE 9: Shared Preset Store & CLI Preset Command

- [x] **`PrefsFileManager.swift`** — New `CoffeetoshCore` utility that reads/writes `~/.coffeetosh/prefs.json`. Pattern mirrors `StatusFileManager`. `read()` is non-throwing (returns empty prefs on failure). `write()` is atomic. Shared by GUI and CLI so they always see the same preset.
- [x] **`coffeetosh preset` command** — Shows current saved preset.
- [x] **`coffeetosh preset set <mode> <duration>`** — Saves a preset (e.g. `coffeetosh preset set keep-awake 2h`). Accepts `30m`, `1h`, `2h`, `4h`, `8h`, `24h`, `0` (indefinite). Stores `presetMode` as `"keepAwake"` or `"headless"` for GUI compatibility.
- [x] **`coffeetosh preset clear`** — Clears saved preset.
- [x] **`coffeetosh start` with no args** — Detects preset-mode intent (`no hours value + no --mode flag`) and uses the saved preset. Exits with a helpful message if no preset is saved. Passes `--low-power` through to the underlying `handleStart` call.
- [x] **GUI mirrors to prefs.json** — Both `DashboardPresetView.savePreset()` and `SettingsView.PresetPickerSection.savePreset()/clearPreset()` now call `PrefsFileManager.write()` alongside `@AppStorage` so the CLI always sees what the user set in the app.

---

## 🆕 PHASE 10: Bug Fix Sprint — CLI & System

- [x] **Bug #3 — FileSystemWatcher atomic rename** — Rewrote `FileSystemWatcher.swift` to watch BOTH the file (`fileSource`) AND the parent directory (`dirSource`). Directory watcher fires immediately on atomic renames. File watcher calls `reopenFileWatch()` on `.rename`/`.delete` (50ms delay then re-opens fd). All three sources feed into a single `handleFileChange()`.
- [x] **Bug #6 — CLI --minutes flag** — Added `--minutes`/`-m` flag to `handleStart` arg parsing in `main.swift`. Converts minutes to fractional hours (`m / 60.0`). Updated `printUsage()` to document both forms. Allows sub-hour durations like `coffeetosh start --minutes 45`.

---

## 🆕 PHASE 11: Bug Fix Sprint — CLI History & Analytics Sync

- [x] **CLI stop race condition (history not recorded):** `handleStop()` sent SIGTERM via `DaemonLauncher.stop()` and then immediately called `StatusFileManager.markInactive()`. Because `markInactive()` could win the race before the daemon processed SIGTERM, the daemon's `SleepManager.restore()` guard (`fileActive=false`) skipped history recording silently. **Fix:** CLI now records the session history itself (it has all data from the initial `status` read at the top of `handleStop()`) BEFORE calling `markInactive()` and BEFORE sending SIGTERM. The daemon's `restore()` still correctly runs deactivation cleanup (`isActive=true` in-memory), but its `status.active` guard skips the duplicate history write. This guarantees exactly one history entry regardless of signal timing.