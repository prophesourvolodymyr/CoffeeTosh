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
case "preset":
    handlePreset(args: Array(args.dropFirst(2)))
case "battery":
    handleBattery()
case "mac-temp", "temp":   // "temp" kept for backward compat
    handleMacTemp()
case "help", "--help", "-h":
    printUsage()
default:
    print("Unknown command: \(command)")
    printUsage()
    exit(1)
}

// MARK: - Start ──────────────────────────────────────────────────

func handleStart(args: [String]) {
    // ── Preset shortcut ──────────────────────────────────────────────────────
    // `coffeetosh start` (no hours value, no --mode flag) → activate saved preset.
    let wantsPreset = !args.contains { Double($0) != nil } && !args.contains("--mode")
    if wantsPreset {
        let prefs = PrefsFileManager.read()
        guard prefs.hasPreset else {
            print("No Quick Preset saved.")
            print("   Set one in the app:  Menu Bar -> Settings -> Quick Preset")
            print("   Or in terminal:      coffeetosh preset set <mode> <duration>")
            print("")
            print("   Or start with explicit args:")
            print("     coffeetosh start 8                       Lid Closed, 8 hours")
            print("     coffeetosh start 2 --mode keep-awake     Keep Awake, 2 hours")
            exit(1)
        }
        let wantsLowPower = args.contains("--low-power")
        let h        = prefs.presetDurationSeconds == 0 ? 0.0 : Double(prefs.presetDurationSeconds) / 3600.0
        let hoursStr = h == 0 ? "0" : (h == Double(Int(h)) ? "\(Int(h))" : "\(h)")
        let modeStr  = prefs.presetMode == "headless" ? "coffeetosh" : "keep-awake"
        let durLabel = prefs.presetDurationSeconds == 0 ? "inf" : "\(prefs.presetDurationSeconds / 60)m"
        let modeName = prefs.presetMode == "headless" ? "Lid Closed" : "Keep Awake"
        print("Quick Preset: \(modeName) - \(durLabel)")
        var expanded = [hoursStr, "--mode", modeStr]
        if wantsLowPower { expanded.append("--low-power") }
        handleStart(args: expanded)
        return
    }

    // ── Normal arg parsing ───────────────────────────────────────────────────
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
            case "coffeetosh", "headless", "lid-closed", "b":
                mode = .headless
            default:
                print("⚠️  Unknown mode: \(modeStr). Use 'keep-awake' or 'lid-closed'.")
                exit(1)
            }
            i += 2
        } else if arg == "--low-power" {
            lowPower = true
            i += 1
        } else if (arg == "--minutes" || arg == "-m"), i + 1 < args.count {
            if let m = Double(args[i + 1]) { hours = m / 60.0 } else {
                print("⚠️  Invalid minutes value: \(args[i + 1])")
                exit(1)
            }
            i += 2
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
            print("❌ Admin access denied — cannot activate Lid Closed mode.")
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
            print("   Mode: \(mode == .headless ? "Lid Closed" : "Keep Awake")")
            print("   Duration: \(durationSeconds == 0 ? "∞ (indefinite)" : "\(hours)h")\(lowPowerStr)")
            print("   Daemon PID: \(pid)")
        } else {
            print("☕ Coffeetosh started!")
            print("   Mode: \(mode == .headless ? "Lid Closed" : "Keep Awake")")
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
        print("   Mode: \(mode == .headless ? "Lid Closed" : "Keep Awake")")
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

    // Record history NOW — before sending SIGTERM or calling markInactive().
    // The daemon's signal handler also calls SleepManager.restore() which
    // records history, but there is a race: if we call markInactive() first,
    // the daemon sees active=false and skips recording.  By writing history here
    // then marking inactive BEFORE sending SIGTERM, we guarantee exactly one entry:
    // the CLI records it, and the daemon's restore() guard (fileActive=false)
    // skips the duplicate.  SleepManager's deactivation logic still runs in the
    // daemon (it has isActive=true in-memory) to kill caffeinate / release assertions.
    if let start = status.startTime {
        let actualSecs = max(1, Int(Date().timeIntervalSince(start)))
        let item = SessionHistoryItem(
            startTime: start,
            durationSeconds: status.durationSeconds,
            actualDurationSeconds: actualSecs,
            mode: status.mode,
            endReason: "User Stopped"
        )
        HistoryManager.shared.appendSession(item)
    }

    // Mark file inactive BEFORE SIGTERM — daemon's restore() will see
    // active=false and skip the duplicate history write, while still
    // running deactivation cleanup (caffeinate kill, IOPMAssertion release).
    try? StatusFileManager.markInactive()

    // Signal the daemon to clean up (kill caffeinate, release assertions)
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
        let modeName = status.mode == .headless ? "Lid Closed" : "Keep Awake"
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
        print("coffeetosh installed at \(symlinkPath)")
        print("   Run: coffeetosh status")
    } else {
        print("Failed to create symlink. Try manually:")
        print("   sudo ln -sf \"\(ownPath)\" \(symlinkPath)")
    }
}

// MARK: - Preset ──────────────────────────────────────────────────────────────

func handlePreset(args: [String]) {
    // No subcommand -> show current preset
    if args.isEmpty {
        let prefs = PrefsFileManager.read()
        if prefs.hasPreset {
            let modeLabel = prefs.presetMode == "headless" ? "Lid Closed" : "Keep Awake"
            let durLabel  = prefs.presetDurationSeconds == 0
                ? "inf (indefinite)"
                : "\(prefs.presetDurationSeconds / 60)m"
            print("Quick Preset: \(modeLabel) - \(durLabel)")
            print("   coffeetosh start  <- will use this preset")
        } else {
            print("No Quick Preset saved.")
            print("   coffeetosh preset set keep-awake 2h")
            print("   coffeetosh preset set lid-closed 8h")
        }
        return
    }

    switch args[0] {
    case "set":
        // coffeetosh preset set <mode> <duration>
        guard args.count >= 3 else {
            print("Usage: coffeetosh preset set <mode> <duration>")
            print("  mode:     keep-awake | lid-closed")
            print("  duration: 30m | 1h | 2h | 4h | 8h | 0 (indefinite)")
            exit(1)
        }
        let modeArg = args[1]
        let durArg  = args[2]

        let presetMode: String
        switch modeArg {
        case "keep-awake", "a", "keepAwake": presetMode = "keepAwake"
        case "headless", "lid-closed", "b", "coffeetosh": presetMode = "headless"
        default:
            print("Unknown mode: \(modeArg). Use 'keep-awake' or 'lid-closed'.")
            exit(1)
        }

        let presetSeconds: Int
        if durArg == "0" || durArg == "inf" {
            presetSeconds = 0
        } else if durArg.hasSuffix("h"), let h = Int(durArg.dropLast()) {
            presetSeconds = h * 3600
        } else if durArg.hasSuffix("m"), let m = Int(durArg.dropLast()) {
            presetSeconds = m * 60
        } else if let m = Int(durArg) {
            presetSeconds = m * 60
        } else {
            print("Unknown duration: \(durArg). Use '2h', '30m', or '0' for indefinite.")
            exit(1)
        }

        try? PrefsFileManager.write(CoffeetoshPrefs(
            presetMode: presetMode,
            presetDurationSeconds: presetSeconds
        ))
        let modeLabel = presetMode == "headless" ? "Lid Closed" : "Keep Awake"
        let durLabel  = presetSeconds == 0 ? "inf" : "\(presetSeconds / 60)m"
        print("Quick Preset saved: \(modeLabel) - \(durLabel)")
        print("   coffeetosh start  <- will now use this preset")

    case "clear":
        try? PrefsFileManager.write(CoffeetoshPrefs())
        print("Quick Preset cleared.")

    default:
        print("Unknown preset subcommand: \(args[0])")
        print("   coffeetosh preset                         Show current preset")
        print("   coffeetosh preset set <mode> <duration>   Save preset")
        print("   coffeetosh preset clear                   Remove preset")
        exit(1)
    }
}

// MARK: - Battery ──────────────────────────────────────────────────

func handleBattery() {
    let raw = ShellHelper.run("pmset -g batt")
    guard !raw.isEmpty else {
        print("Battery: unavailable (pmset failed)")
        return
    }

    // Sample pmset output:
    // Now drawing from 'Battery Power'
    //  -InternalBattery-0 (id=...)\t79%; discharging; 3:42 remaining present: true
    let lines = raw.components(separatedBy: "\n")

    // Source line (first line)
    let sourceLine = lines.first ?? ""
    let isCharging = sourceLine.contains("AC Power")
    let source = isCharging ? "AC Power (charging)" : "Battery Power"

    // Battery stats line
    if let statsLine = lines.first(where: { $0.contains("%") }) {
        // Extract percentage
        let percentStr: String
        if let range = statsLine.range(of: #"(\d+)%"#, options: .regularExpression),
           let numRange = statsLine.range(of: #"\d+"#, options: .regularExpression, range: range) {
            percentStr = String(statsLine[numRange]) + "%"
        } else {
            percentStr = "?%"
        }

        // Extract time remaining
        let timeStr: String
        if statsLine.contains("(no estimate)") || statsLine.contains("not charging") {
            timeStr = "no estimate"
        } else if let tr = statsLine.range(of: #"\d+:\d+"#, options: .regularExpression) {
            timeStr = String(statsLine[tr]) + " remaining"
        } else {
            timeStr = ""
        }

        // Status keyword
        let status: String
        if statsLine.contains("charging") { status = "charging" }
        else if statsLine.contains("discharging") { status = "discharging" }
        else if statsLine.contains("finishing charge") { status = "finishing charge" }
        else { status = "idle" }

        print("Battery: \(percentStr) — \(status)")
        print("Source:  \(source)")
        if !timeStr.isEmpty { print("Time:    \(timeStr)") }
    } else {
        print("Battery: \(source)")
        print(raw)
    }
}

// MARK: - Temperature ────────────────────────────────────────────

func handleMacTemp() {
    // Run powermetrics with inherited stdio so sudo can prompt for a password
    // naturally in the terminal. No pipes — no silent failures, no quote issues.
    print("Mac temperature (admin password may be required):")

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/zsh")
    process.arguments = ["-c",
        "sudo powermetrics --samplers smc -i1 -n1 2>&1 | grep -E 'CPU die temperature|GPU die temperature'"
    ]
    // Inherit terminal stdio — lets sudo prompt interactively
    process.standardInput  = FileHandle.standardInput
    process.standardOutput = FileHandle.standardOutput
    process.standardError  = FileHandle.standardError

    do {
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            print("powermetrics exited with status \(process.terminationStatus)")
        }
    } catch {
        print("Failed to run powermetrics: \(error)")
    }
}

// MARK: - Usage ──────────────────────────────────────────────────

func printUsage() {
    print("""
    Coffeetosh -- Prevent macOS sleep on lid close

    USAGE:
      coffeetosh start                              Start with saved Quick Preset
      coffeetosh start [hours]                      Start Lid Closed mode (default 8h)
      coffeetosh start [hours] --mode keep-awake    Start Keep Awake mode
      coffeetosh start [hours] --low-power          Lid Closed + Low Power Mode
      coffeetosh start --minutes <mins>             Start with a minute-level duration
      coffeetosh start -m <mins>                    Shorthand for --minutes
      coffeetosh start 0                            Start indefinitely
      coffeetosh stop                               Stop session, restore settings
      coffeetosh add [minutes]                      Add time to session (default: 30m)
      coffeetosh status                             Print current state
      coffeetosh battery                            Show battery %, source, time remaining
      coffeetosh mac-temp                           Show Mac CPU/GPU temperature (needs admin)
      coffeetosh preset                             Show saved Quick Preset
      coffeetosh preset set <mode> <duration>       Save a Quick Preset
      coffeetosh preset clear                       Remove saved preset
      coffeetosh install-cli                        Symlink to /usr/local/bin
      coffeetosh help                               Show this message

    MODES:
      coffeetosh (default)   Lid-closed + SSH safe. Requires admin.
      keep-awake             Idle-sleep prevention only. No admin needed.

    OPTIONS:
      --low-power        Enable macOS Low Power Mode during Lid Closed session.
                         Automatically disabled on stop. Requires admin.

    PRESET DURATION FORMAT:
      30m   1h   2h   4h   8h   24h   0 (indefinite)

    EXAMPLES:
      coffeetosh start                              Use saved Quick Preset
      coffeetosh start 8                            Lid Closed, 8 hours
      coffeetosh start 8 --low-power                Lid Closed + Low Power Mode
      coffeetosh start 2 --mode keep-awake          Keep Awake, 2 hours
      coffeetosh preset set keep-awake 2h           Save preset: Keep Awake 2h
      coffeetosh preset set lid-closed 8h           Save preset: Lid Closed 8h
      coffeetosh add 60                             Add 60 min to running session
      ssh user@macbook.local "coffeetosh start 12"  Remote start over SSH
    """)
}
