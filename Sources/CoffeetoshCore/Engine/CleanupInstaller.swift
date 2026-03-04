// CleanupInstaller.swift
// Coffeetosh Core Engine
// Installs/uninstalls the LaunchAgent plist for boot-time crash recovery.

import Foundation

// MARK: - CleanupInstaller

/// Manages the `com.coffeetosh.cleanup.plist` LaunchAgent that runs
/// `coffeetosh-cleanup` at login to catch ghosted pmset states.
public enum CleanupInstaller {

    private static let plistName = "com.coffeetosh.cleanup.plist"

    private static var launchAgentsDir: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents", isDirectory: true)
    }

    private static var installedPlistURL: URL {
        launchAgentsDir.appendingPathComponent(plistName)
    }

    // MARK: - Install

    /// Installs the LaunchAgent plist, pointing it at the cleanup binary.
    /// - Parameter cleanupBinaryPath: Absolute path to the `coffeetosh-cleanup` binary.
    /// - Returns: `true` if installation succeeded.
    @discardableResult
    public static func install(cleanupBinaryPath: String) -> Bool {
        // 1. Ensure ~/Library/LaunchAgents exists
        let dir = launchAgentsDir
        if !FileManager.default.fileExists(atPath: dir.path) {
            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            } catch {
                print("[CleanupInstaller] ⚠️ Could not create LaunchAgents dir: \(error)")
                return false
            }
        }

        // 2. Generate plist content with the real binary path
        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.coffeetosh.cleanup</string>
            <key>ProgramArguments</key>
            <array>
                <string>\(cleanupBinaryPath)</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <false/>
            <key>StandardOutPath</key>
            <string>/tmp/coffeetosh-cleanup.log</string>
            <key>StandardErrorPath</key>
            <string>/tmp/coffeetosh-cleanup.log</string>
        </dict>
        </plist>
        """

        // 3. Write plist
        do {
            try plistContent.write(to: installedPlistURL, atomically: true, encoding: .utf8)
            print("[CleanupInstaller] ✅ Installed LaunchAgent at \(installedPlistURL.path)")
            return true
        } catch {
            print("[CleanupInstaller] ⚠️ Failed to write plist: \(error)")
            return false
        }
    }

    // MARK: - Uninstall

    /// Removes the LaunchAgent plist.
    public static func uninstall() {
        let path = installedPlistURL.path
        guard FileManager.default.fileExists(atPath: path) else {
            print("[CleanupInstaller] ℹ️ No LaunchAgent installed.")
            return
        }
        do {
            // Unload first (ignore errors if not loaded)
            ShellHelper.run("launchctl unload \"\(path)\" 2>/dev/null")
            try FileManager.default.removeItem(atPath: path)
            print("[CleanupInstaller] 🛑 Uninstalled LaunchAgent.")
        } catch {
            print("[CleanupInstaller] ⚠️ Failed to remove plist: \(error)")
        }
    }

    // MARK: - Status

    /// Whether the LaunchAgent plist is installed.
    public static var isInstalled: Bool {
        FileManager.default.fileExists(atPath: installedPlistURL.path)
    }
}
