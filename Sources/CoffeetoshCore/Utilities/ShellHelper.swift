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

    /// Runs a command via NSAppleScript requesting administrator privileges.
    /// Returns `true` on success. Works from GUI apps with a password dialog.
    @discardableResult
    public static func runWithAdmin(_ command: String) -> Bool {
        let source = """
        do shell script "\(command)" with administrator privileges
        """
        var error: NSDictionary?
        if let script = NSAppleScript(source: source) {
            script.executeAndReturnError(&error)
            if let error = error {
                print("[ShellHelper] ⚠️ Admin command failed: \(error)")
                return false
            }
            return true
        }
        return false
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
