// main.swift
// coffeetosh — CLI Tool for Coffeetosh
// Commands: start, stop, status, install-cli

import Foundation
import CoffeetoshCore

// MARK: - CLI Entry Point ────────────────────────────────────────

let args = CommandLine.arguments
let command = args.count > 1 ? args[1] : "help"

switch command {
case "start":
    handleStart(args: Array(args.dropFirst(2)))
case "stop":
    handleStop()
case "add":
    handleAdd(args: Array(args.dropFirst(2)))
case "status":
    handleStatus()
case "install-cli":
    handleInstallCLI()
case "help", "--help", "-h":
    printUsage()
default:
    print("Unknown command: \(command)")
    printUsage()
    exit(1)
}

// MARK: - Start ──────────────────────────────────────────────────

func handleStart(args: [String]) {
    // Parse hours (default: 8)
    var hours: Double = 8
    var mode: CoffeetoshMode = .headless  // Default: Mode B (Headless)
    var lowPower: Bool = false

    var i = 0
    while i < args.count {
        let arg = args[i]
        if arg == "--mode", i + 1 < args.count {
            let modeStr = args[i + 1]
            switch modeStr {
            case "keep-awake", "a":
                mode = .keepAwake
            case "coffeetosh", "headless", "b":
                mode = .headless
            default:
                print("⚠️  Unknown mode: \(modeStr). Use 'keep-awake' or 'coffeetosh'.")
                exit(1)
            }
            i += 2
        } else if arg == "--low-power" {
            lowPower = true
            i += 1
        } else if let h = Double(arg) {
            hours = h
            i += 1
        } else {
            print("⚠️  Unknown argument: \(arg)")
            printUsage()
            exit(1)
        }
    }

    let durationSeconds = hours == 0 ? 0 : Int(hours * 3600)

    // Check if already active
    if let status = try? StatusFileManager.read(), status.active {
        print("⚠️  A session is already active (\(status.mode.rawValue)). Stop it first: coffeetosh stop")
        exit(1)
    }

    // Write the desired session config to status.json.
    // The DAEMON is the long-running process — it will call SleepManager.activate()
    // and hold the IOPMAssertion / caffeinate process alive.
    // If the CLI activated it here, the assertion would die when the CLI exits.
    let pendingStatus = CoffeetoshStatus(
        active: true,
        mode: mode,
        startTime: Date(),
        durationSeconds: durationSeconds,
        daemonPid: nil,          // Daemon will fill this in
        caffeinatePid: nil,      // Daemon will fill this in
        originalPmset: nil,      // Daemon will capture this
        sshMonitorEnabled: nil,
        consecutiveZeroCount: nil,
        expiredAt: nil,
        lastCheckTime: nil,
        lowPowerEnabled: lowPower ? true : nil
    )
    // For Mode B: run admin pmset from CLI BEFORE writing status.json.
    // The daemon can't show password dialogs — it's a detached background process.
    // We do this first so a failed/cancelled password doesn't leave a ghost session.
    if mode == .headless {
        print("🔐 Mode B requires admin access to set pmset…")
        print("   Enter your macOS password below (typing is hidden):")
        let adminOk = SleepManager.shared.preActivateModeBAdmin()
        guard adminOk else {
            print("❌ Admin access denied — cannot activate Headless mode.")
            exit(1)
        }
    }

    // Enable Low Power Mode now (CLI has TTY for sudo) — stays on for entire session.
    // Brightness is NOT touched here — the daemon handles it via lid detection.
    if mode == .headless && lowPower {
        print("🔐 Enabling Low Power Mode…")
        print("   Enter your macOS password below (typing is hidden):")
        let lpOk = ShellHelper.runWithSudo("pmset -a lowpowermode 1")
        if lpOk {
            print("⚡ Low Power Mode enabled")
        } else {
            print("⚠️  Failed to enable Low Power Mode — continuing without it.")
        }
    }

    // Now write session config — admin succeeded (or Mode A doesn't need it)
    try? StatusFileManager.write(pendingStatus)

    // Launch the daemon — it reads status.json and activates sleep prevention
    if let pid = DaemonLauncher.launch() {
        // Give daemon a moment to activate and report errors
        Thread.sleep(forTimeInterval: 0.5)

        // Verify daemon actually activated
        let lowPowerStr = lowPower ? " | Low Power: ON" : ""
        if let check = try? StatusFileManager.read(), check.active, check.daemonPid != nil {
            print("☕ Coffeetosh started!")
            print("   Mode: \(mode == .headless ? "Coffeetosh/Headless (Mode B)" : "Keep Awake (Mode A)")")
            print("   Duration: \(durationSeconds == 0 ? "∞ (indefinite)" : "\(hours)h")\(lowPowerStr)")
            print("   Daemon PID: \(pid)")
        } else {
            print("☕ Coffeetosh started!")
            print("   Mode: \(mode == .headless ? "Coffeetosh/Headless (Mode B)" : "Keep Awake (Mode A)")")
            print("   Duration: \(durationSeconds == 0 ? "∞ (indefinite)" : "\(hours)h")\(lowPowerStr)")
            print("   Daemon PID: \(pid)")
            print("   ⚠️  Daemon may still be initializing — check: coffeetosh status")
        }
    } else {
        // No daemon binary found — fall back to foreground mode with a RunLoop
        print("☕ Coffeetosh starting in foreground mode (no daemon binary found)…")
        // For Mode B, admin pmset was already done above via preActivateModeBAdmin().
        // Pass skipAdmin: true so activateModeB() doesn't try NSAppleScript a second time.
        let success = SleepManager.shared.activate(mode: mode, durationSeconds: durationSeconds, skipAdmin: mode == .headless)
        guard success else {
            try? StatusFileManager.markInactive()
            print("❌ Failed to activate \(mode.rawValue) mode.")
            exit(1)
        }
        print("   Mode: \(mode == .headless ? "Coffeetosh/Headless (Mode B)" : "Keep Awake (Mode A)")")
        print("   Duration: \(durationSeconds == 0 ? "∞ (indefinite)" : "\(hours)h")")
        print("   Running in foreground — press Ctrl+C to stop.")

        // Install signal handler for clean Ctrl+C
        signal(SIGINT) { _ in
            SleepManager.shared.restore()
            print("\n🛑 Coffeetosh stopped. System sleep defaults restored.")
            exit(0)
        }

        // Keep the process alive so the IOPMAssertion stays held
        RunLoop.current.run()
    }
}

// MARK: - Stop ───────────────────────────────────────────────────

func handleStop() {
    guard let status = try? StatusFileManager.read(), status.active else {
        print("ℹ️  Coffeetosh is not active.")
        exit(0)
    }

    // Signal the daemon to stop (it will restore pmset via signal trap)
    DaemonLauncher.stop()

    // For Mode B: restore pmset from CLI (daemon may not be able to sudo)
    if status.mode == .headless {
        print("🔐 Restoring pmset (may require password)…")
        _ = ShellHelper.runWithSudo("pmset -a disablesleep 0")

        // Restore Low Power Mode if we enabled it
        if status.lowPowerEnabled == true {
            _ = ShellHelper.runWithSudo("pmset -a lowpowermode 0")
        }
    }

    // Restore brightness from persisted status.json value (saved by daemon on lid close)
    if let originalBrightness = status.originalBrightness {
        _ = BrightnessHelper.setBuiltInBrightnessPublic(originalBrightness)
        print("🔆 Brightness restored to \(String(format: "%.1f%%", originalBrightness * 100))")
    }

    // Always mark status as inactive — the CLI process never called activate(),
    // so SleepManager.shared.restore() would skip (isActive == false).
    try? StatusFileManager.markInactive()

    print("🛑 Coffeetosh stopped. System sleep defaults restored.")
}

// MARK: - Add Time ───────────────────────────────────────────────

func handleAdd(args: [String]) {
    guard let status = try? StatusFileManager.read(), status.active else {
        print("ℹ️  Coffeetosh is not active. Start a session first.")
        exit(1)
    }

    // Verify daemon is actually running
    if let pid = status.daemonPid, kill(pid_t(pid), 0) != 0 {
        print("ℹ️  Session expired (daemon not running). Start a new session.")
        try? StatusFileManager.markInactive()
        exit(1)
    }

    // Parse minutes to add (default: 30)
    let minutesToAdd: Int
    if let first = args.first, let mins = Int(first) {
        minutesToAdd = mins
    } else if let first = args.first, let hrs = Double(first), first.contains(".") {
        minutesToAdd = Int(hrs * 60)
    } else {
        minutesToAdd = 30
    }

    let secondsToAdd = minutesToAdd * 60

    if status.durationSeconds == 0 {
        print("ℹ️  Session is indefinite — no timer to extend.")
        exit(0)
    }

    // Update durationSeconds in status.json — daemon reads this on next tick
    var updated = status
    updated.durationSeconds += secondsToAdd
    try? StatusFileManager.write(updated)

    let newTotal = updated.durationSeconds / 60
    let remaining = updated.remainingFormatted
    print("⏱️  Added \(minutesToAdd) minutes to session.")
    print("   New total: \(newTotal / 60)h \(newTotal % 60)m | Remaining: \(remaining)")
}

// MARK: - Status ─────────────────────────────────────────────────

func handleStatus() {
    guard let status = try? StatusFileManager.read() else {
        print("Coffeetosh: INACTIVE")
        print("(No status file found)")
        return
    }

    if status.active {
        let modeName = status.mode == .headless ? "Coffeetosh/Headless" : "Keep Awake"
        print("Coffeetosh: ACTIVE (Mode: \(modeName))")

        if let start = status.startTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            print("Started: \(formatter.string(from: start))")
        }

        if status.durationSeconds > 0 {
            let totalH = status.durationSeconds / 3600
            let remaining = status.remainingFormatted
            print("Duration: \(totalH)h | Remaining: \(remaining)")
        } else {
            print("Duration: ∞ (indefinite)")
        }

        if let pid = status.daemonPid {
            let alive = DaemonLauncher.isRunning() ? "running" : "dead"
            print("Daemon PID: \(pid) (\(alive))")
        }

        if let lidClosed = status.lidClosed {
            print("Lid: \(lidClosed ? "Closed 🔒" : "Open 🔓")")
        }

        if status.lowPowerEnabled == true {
            print("Low Power Mode: ON ⚡")
        }

        if status.sshMonitorEnabled == true {
            print("SSH Monitor: ON (zero-count: \(status.consecutiveZeroCount ?? 0))")
        }
    } else {
        print("Coffeetosh: INACTIVE")
        if let expired = status.expiredAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            print("Last session expired: \(formatter.string(from: expired))")
        }
    }
}

// MARK: - Install CLI ────────────────────────────────────────────

func handleInstallCLI() {
    // Determine own binary path
    let ownPath: String
    if let bundlePath = Bundle.main.executablePath,
       bundlePath.contains(".app/Contents/MacOS") {
        ownPath = bundlePath
    } else {
        // Running from SPM build or direct path
        ownPath = CommandLine.arguments[0]
    }

    let symlinkPath = "/usr/local/bin/coffeetosh"
    let binDir = "/usr/local/bin"

    // Ensure /usr/local/bin exists
    if !FileManager.default.fileExists(atPath: binDir) {
        print("Creating \(binDir)…")
        ShellHelper.runWithAdmin("mkdir -p \(binDir)")
    }

    // Remove existing symlink
    if FileManager.default.fileExists(atPath: symlinkPath) {
        ShellHelper.runWithAdmin("rm \(symlinkPath)")
    }

    // Create symlink
    let success = ShellHelper.runWithAdmin("ln -sf \"\(ownPath)\" \(symlinkPath)")
    if success {
        print("✅ coffeetosh installed at \(symlinkPath)")
        print("   Run: coffeetosh status")
    } else {
        print("❌ Failed to create symlink. Try manually:")
        print("   sudo ln -sf \"\(ownPath)\" \(symlinkPath)")
    }
}

// MARK: - Usage ──────────────────────────────────────────────────

func printUsage() {
    print("""
    ☕ Coffeetosh — Prevent macOS sleep on lid close

    USAGE:
      coffeetosh start [hours]               Start Mode B (Headless), default 8h
      coffeetosh start [hours] --mode keep-awake   Start Mode A (idle-sleep only)
      coffeetosh start [hours] --low-power   Start headless with Low Power Mode
      coffeetosh start 0                     Start indefinitely
      coffeetosh stop                        Stop active session, restore settings
      coffeetosh add [minutes]               Add time to active session (default: 30)
      coffeetosh status                      Print current state
      coffeetosh install-cli                 Symlink to /usr/local/bin/coffeetosh
      coffeetosh help                        Show this message

    MODES:
      coffeetosh (default)   Lid-closed + SSH safe. Requires admin.
      keep-awake         Idle-sleep prevention only. No admin needed.

    OPTIONS:
      --low-power        Enable macOS Low Power Mode during headless session.
                         Automatically disabled on stop. Requires admin.

    EXAMPLES:
      coffeetosh start 8                     Keep awake for 8 hours (headless)
      coffeetosh start 8 --low-power         Headless + Low Power Mode
      coffeetosh start 2 --mode keep-awake   Prevent idle sleep for 2 hours
      coffeetosh add 60                      Add 60 minutes to current session
      coffeetosh add                         Add 30 minutes (default)
      ssh user@macbook.local "coffeetosh start 12"   Start remotely over SSH
    """)
}
