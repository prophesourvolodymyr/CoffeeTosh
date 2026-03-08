// AppPrefsWriter.swift
// Writes ~/.coffeetosh/prefs.json directly from the GUI target,
// without importing CoffeetoshCore (avoids Xcode local-package index issues).
// The CLI reads the same file via PrefsFileManager in CoffeetoshCore.

import Foundation

enum AppPrefsWriter {

    private static var fileURL: URL {
        let dir = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".coffeetosh")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("prefs.json")
    }

    /// Save a preset. Pass empty strings / 0 to clear.
    static func savePreset(mode: String, durationSeconds: Int) {
        let dict: [String: Any] = [
            "presetMode": mode,
            "presetDurationSeconds": durationSeconds
        ]
        guard let data = try? JSONSerialization.data(
            withJSONObject: dict,
            options: [.prettyPrinted, .sortedKeys]
        ) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    /// Clear the saved preset.
    static func clearPreset() {
        savePreset(mode: "", durationSeconds: 0)
    }
}
