// CaffeinateProcess.swift
// Coffeetosh / Coffeetosh Core Engine
// Manages a caffeinate subprocess for Mode B (Headless).

import Foundation

// MARK: - CaffeinateProcess

/// Spawns and manages a `caffeinate -is` subprocess.
/// `-i` = prevent idle sleep, `-s` = prevent system sleep.
/// Display sleep is intentionally NOT prevented — screen goes off on lid close to save energy.
public final class CaffeinateProcess {

    private var process: Process?

    /// The running caffeinate PID (nil if not running).
    public var pid: Int32? {
        return process?.isRunning == true ? process?.processIdentifier : nil
    }

    // ── Start ───────────────────────────────────────────────────

    /// Launches `caffeinate -dis` as a child process.
    /// Returns the PID on success, nil on failure.
    public init() {}

    @discardableResult
    public func start() -> Int32? {
        stop() // Kill any prior instance

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        proc.arguments = ["-is"]

        do {
            try proc.run()
            process = proc
            print("[CaffeinateProcess] ✅ Started caffeinate -is (PID \(proc.processIdentifier))")
            return proc.processIdentifier
        } catch {
            print("[CaffeinateProcess] ⚠️ Failed to launch caffeinate: \(error)")
            return nil
        }
    }

    // ── Stop ────────────────────────────────────────────────────

    /// Terminates the caffeinate subprocess if running.
    public func stop() {
        guard let proc = process, proc.isRunning else {
            process = nil
            return
        }
        proc.terminate()
        proc.waitUntilExit()
        print("[CaffeinateProcess] 🛑 Stopped caffeinate (PID \(proc.processIdentifier))")
        process = nil
    }

    // ── Static Cleanup ──────────────────────────────────────────

    /// Kills a caffeinate process by PID (used by cleanup scripts / daemon recovery).
    public static func kill(pid: Int32) {
        let result = Foundation.kill(pid, SIGTERM)
        if result == 0 {
            print("[CaffeinateProcess] 🛑 Killed orphan caffeinate PID \(pid)")
        }
    }

    deinit { stop() }
}
