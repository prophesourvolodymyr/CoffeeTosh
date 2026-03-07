// ShellHelper.swift
// Coffeetosh / Coffeetosh Core Engine
// Thin wrapper for synchronous shell execution.

import Foundation

// MARK: - ShellHelper

public enum ShellHelper {

    /// Runs a shell command synchronously and returns trimmed stdout.
    @discardableResult
    public static func run(_ command: String) -> String {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return ""
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    /// Runs a command requesting administrator privileges.
    /// First attempts a silent sudo (uses cached token — no dialog if token is fresh).
    /// Falls back to an `osascript` subprocess that shows the standard macOS
    /// authentication dialog. Using a subprocess is more reliable than
    /// NSAppleScript class — it works from any process context (GUI, daemon,
    /// LSUIElement apps) and does NOT require System Events accessibility access.
    @discardableResult
    public static func runWithAdmin(_ command: String) -> Bool {
        // Fast path: use cached sudo token (no dialog, instant)
        if runWithAdminNoPrompt(command) {
            print("[ShellHelper] Admin command succeeded via cached sudo token.")
            return true
        }

        // Slow path: show macOS authentication dialog via osascript subprocess.
        // `do shell script ... with administrator privileges` (no tell-block)
        // is the correct AppleScript for a self-contained admin prompt.
        let escaped = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let script = "do shell script \"\(escaped)\" with administrator privileges"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]
        process.standardOutput = FileHandle.nullDevice
        process.standardError  = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
            let ok = process.terminationStatus == 0
            if !ok { print("[ShellHelper] ⚠️ Admin command failed (osascript exit \(process.terminationStatus))") }
            return ok
        } catch {
            print("[ShellHelper] ⚠️ Admin command failed: \(error)")
            return false
        }
    }

    /// Attempts to run `command` via `sudo -n` (non-interactive).
    /// Succeeds silently if a valid sudo auth token is cached; fails immediately
    /// (no dialog, no block) if the token is expired or missing.
    @discardableResult
    public static func runWithAdminNoPrompt(_ command: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "sudo -n \(command) 2>/dev/null"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError  = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    /// Runs a command with `sudo` interactively in the terminal.
    /// Reads password with echo disabled (characters hidden), then pipes to `sudo -S`.
    /// Works from CLI apps where NSAppleScript admin dialogs may be blocked.
    @discardableResult
    public static func runWithSudo(_ command: String) -> Bool {
        // Flush stdout so our prompt appears before we disable echo
        fflush(stdout)

        // Read password with terminal echo disabled
        guard let password = readPassword() else {
            print("\n[ShellHelper] ⚠️ Could not read password.")
            return false
        }

        // Pipe password to sudo -S (read from stdin)
        let process = Process()
        let inputPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "echo '\(password.replacingOccurrences(of: "'", with: "'\\''"))' | sudo -S \(command) 2>/dev/null"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            process.waitUntilExit()
            print("") // Newline after hidden password input
            return process.terminationStatus == 0
        } catch {
            print("\n[ShellHelper] ⚠️ sudo command failed: \(error)")
            return false
        }
    }

    /// Reads a line from stdin with terminal echo disabled (password-safe).
    /// Returns nil if the terminal can't be configured.
    private static func readPassword() -> String? {
        // Get current terminal settings
        var oldTermios = termios()
        guard tcgetattr(STDIN_FILENO, &oldTermios) == 0 else { return nil }

        // Copy and disable echo
        var newTermios = oldTermios
        newTermios.c_lflag &= ~UInt(ECHO)

        // Apply no-echo settings
        guard tcsetattr(STDIN_FILENO, TCSANOW, &newTermios) == 0 else { return nil }

        // Read the password
        let password = readLine(strippingNewline: true)

        // Restore original terminal settings
        tcsetattr(STDIN_FILENO, TCSANOW, &oldTermios)

        return password
    }
}
