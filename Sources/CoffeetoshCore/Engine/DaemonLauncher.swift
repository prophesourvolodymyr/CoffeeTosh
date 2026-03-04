// DaemonLauncher.swift
// Coffeetosh / Coffeetosh Core Engine
// Spawns and detaches the coffeetosh-daemon process from the GUI / CLI parent.

import Foundation

// MARK: - DaemonLauncher

/// Handles spawning the `coffeetosh-daemon` executable as a fully detached
/// background process that survives parent app termination.
public enum DaemonLauncher {

    // MARK: - Launch

    /// Spawns `coffeetosh-daemon` detached from the calling process.
    ///
    /// The daemon binary is expected to live alongside the main executable:
    /// - App bundle: `Coffeetosh.app/Contents/MacOS/coffeetosh-daemon`
    /// - Dev (SPM): resolved via `Bundle.main.executableURL` sibling
    ///
    /// - Returns: The PID of the daemon process, or `nil` on failure.
    @discardableResult
    public static func launch() -> Int32? {
        guard let daemonURL = resolveDaemonURL() else {
            print("[DaemonLauncher] ⚠️ Could not locate coffeetosh-daemon binary.")
            return nil
        }

        let process = Process()
        process.executableURL = daemonURL

        // Detach stdout/stderr so the daemon doesn't hold the parent's pipes
        process.standardOutput = FileHandle.nullDevice
        process.standardError  = FileHandle.nullDevice
        process.standardInput  = FileHandle.nullDevice

        // Set environment so the daemon inherits the user's HOME
        process.environment = ProcessInfo.processInfo.environment

        do {
            try process.run()
            // DO NOT call process.waitUntilExit() — that's the detachment.
            // The daemon is now a child process but we drop all references.
            let pid = process.processIdentifier
            print("[DaemonLauncher] ✅ Launched coffeetosh-daemon (PID \(pid))")
            return pid
        } catch {
            print("[DaemonLauncher] ⚠️ Failed to launch daemon: \(error)")
            return nil
        }
    }

    // MARK: - Stop

    /// Sends SIGTERM to a running daemon by PID read from status.json.
    public static func stop() {
        guard let status = try? StatusFileManager.read(),
              let pid = status.daemonPid else {
            print("[DaemonLauncher] ℹ️ No daemon PID found in status.json.")
            return
        }

        let result = kill(Int32(pid), SIGTERM)
        if result == 0 {
            print("[DaemonLauncher] 🛑 Sent SIGTERM to daemon PID \(pid)")
        } else {
            print("[DaemonLauncher] ⚠️ kill(\(pid)) failed (errno \(errno)) — daemon may already be dead.")
        }
    }

    /// Returns `true` if the daemon PID in status.json is still alive.
    public static func isRunning() -> Bool {
        guard let status = try? StatusFileManager.read(),
              let pid = status.daemonPid else { return false }
        // kill(pid, 0) checks existence without sending a signal
        return kill(Int32(pid), 0) == 0
    }

    // MARK: - Resolve Binary Path

    private static func resolveDaemonURL() -> URL? {
        // 1. App bundle sibling: .app/Contents/MacOS/coffeetosh-daemon
        if let execURL = Bundle.main.executableURL {
            let sibling = execURL.deletingLastPathComponent()
                .appendingPathComponent("coffeetosh-daemon")
            if FileManager.default.isExecutableFile(atPath: sibling.path) {
                return sibling
            }
        }

        // 2. Resolve symlinks in the CLI path.
        // If `coffeetosh` is installed via `install-cli` as a symlink in /usr/local/bin,
        // CommandLine.arguments[0] points to the symlink. We resolve it to find the real
        // .build/debug/ directory where coffeetosh-daemon sits alongside.
        let rawCLIURL = URL(fileURLWithPath: CommandLine.arguments[0])
        let resolvedCLIURL = rawCLIURL.resolvingSymlinksInPath()
        let resolvedDir = resolvedCLIURL.deletingLastPathComponent()
        let resolvedDaemon = resolvedDir.appendingPathComponent("coffeetosh-daemon")
        if FileManager.default.isExecutableFile(atPath: resolvedDaemon.path) {
            return resolvedDaemon
        }

        // 3. Same directory as the running CLI binary (unresolved — direct invocation)
        let cliSibling = rawCLIURL
            .deletingLastPathComponent()
            .appendingPathComponent("coffeetosh-daemon")
        if FileManager.default.isExecutableFile(atPath: cliSibling.path) {
            return cliSibling
        }

        return nil
    }
}
