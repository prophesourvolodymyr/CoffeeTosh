// PrefsFileManager.swift
// Coffeetosh / CoffeetoshCore
// Reads & writes ~/.coffeetosh/prefs.json — shared preset store for GUI + CLI.

import Foundation

// MARK: - CoffeetoshPrefs

/// Persistent user preferences shared between the GUI app and the CLI tool.
/// Stored at `~/.coffeetosh/prefs.json` so both processes always read the same value.
public struct CoffeetoshPrefs: Codable {

    /// The preset mode stored as a raw string.
    /// GUI writes `"keepAwake"` or `"headless"`. CLI writes `"keep-awake"` or `"headless"`.
    /// Consumers should treat anything that isn't `"headless"` as Keep Awake.
    public var presetMode: String

    /// Preset duration in seconds. `0` = indefinite.
    public var presetDurationSeconds: Int

    /// `true` when a valid preset has been saved.
    public var hasPreset: Bool { !presetMode.isEmpty }

    public init(presetMode: String = "", presetDurationSeconds: Int = 0) {
        self.presetMode = presetMode
        self.presetDurationSeconds = presetDurationSeconds
    }
}

// MARK: - PrefsFileManager

/// Reads and writes `~/.coffeetosh/prefs.json`.
/// Mirrors the design of `StatusFileManager` — simple, atomic, shared by all processes.
public final class PrefsFileManager {

    // ── Path ────────────────────────────────────────────────────
    private static let fileURL: URL =
        StatusFileManager.directoryURL.appendingPathComponent("prefs.json")

    // ── JSON encoder ────────────────────────────────────────────
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    private init() {}

    // MARK: - Public API

    /// Returns the saved prefs.
    /// Returns an empty `CoffeetoshPrefs` (no preset) if the file is missing or corrupt.
    public static func read() -> CoffeetoshPrefs {
        guard let data = try? Data(contentsOf: fileURL),
              let prefs = try? JSONDecoder().decode(CoffeetoshPrefs.self, from: data)
        else { return CoffeetoshPrefs() }
        return prefs
    }

    /// Writes prefs atomically to `~/.coffeetosh/prefs.json`.
    /// Creates `~/.coffeetosh/` if it doesn't exist.
    public static func write(_ prefs: CoffeetoshPrefs) throws {
        let dir = StatusFileManager.directoryURL
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        let data = try encoder.encode(prefs)
        try data.write(to: fileURL, options: .atomic)
    }
}
