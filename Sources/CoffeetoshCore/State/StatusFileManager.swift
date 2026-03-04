// StatusFileManager.swift
// Coffeetosh / Coffeetosh Core Engine
// Reads & writes ~/.coffeetosh/status.json atomically.

import Foundation

// MARK: - StatusFileManager

/// Single-responsibility manager for the `~/.coffeetosh/status.json` file.
/// Used by GUI, Daemon, and CLI to read/write the shared state.
public final class StatusFileManager {

    // ── Paths ───────────────────────────────────────────────────
    public static let directoryURL: URL = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".coffeetosh", isDirectory: true)
    }()

    public static let fileURL: URL = {
        directoryURL.appendingPathComponent("status.json")
    }()

    // ── JSON Configuration ──────────────────────────────────────
    private static let encoder: JSONEncoder = {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        enc.dateEncodingStrategy = .iso8601
        return enc
    }()

    private static let decoder: JSONDecoder = {
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        return dec
    }()

    // ── Public API ──────────────────────────────────────────────

    /// Reads `status.json` and decodes it.  Returns `.inactive` if file is missing.
    public static func read() throws -> CoffeetoshStatus {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            return .inactive
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode(CoffeetoshStatus.self, from: data)
    }

    /// Encodes and writes `status.json` atomically.
    /// Creates the `~/.coffeetosh/` directory if it doesn't exist.
    public static func write(_ status: CoffeetoshStatus) throws {
        let dir = directoryURL
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        let data = try encoder.encode(status)
        try data.write(to: fileURL, options: .atomic)
    }

    /// Convenience: set `active = false` and clear session-only fields.
    public static func markInactive() throws {
        var status = try read()
        status.active = false
        status.daemonPid = nil
        status.caffeinatePid = nil
        status.consecutiveZeroCount = nil
        try write(status)
    }
}
