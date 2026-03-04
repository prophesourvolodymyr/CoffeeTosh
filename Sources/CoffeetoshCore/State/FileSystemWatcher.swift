// FileSystemWatcher.swift
// Coffeetosh / Coffeetosh Core Engine
// Watches ~/.coffeetosh/status.json for changes via GCD + polling fallback.

import Foundation

// MARK: - FileSystemWatcher

/// Monitors `~/.coffeetosh/status.json` for modifications using
/// `DispatchSource.makeFileSystemObjectSource` (FSEvents underneath).
/// Includes a 10-second polling fallback for edge cases (SSH writes, etc.).
public final class FileSystemWatcher {

    // ── Callback ────────────────────────────────────────────────
    /// Fires whenever the status file changes on disk.
    public var onChange: ((CoffeetoshStatus) -> Void)?

    // ── Private State ───────────────────────────────────────────
    private var fileDescriptor: Int32 = -1
    private var dispatchSource: DispatchSourceFileSystemObject?
    private var pollTimer: DispatchSourceTimer?
    private let watchQueue = DispatchQueue(label: "com.coffeetosh.coffeetosh.fswatcher", qos: .utility)

    /// The last known content hash — avoids firing duplicate callbacks.
    private var lastKnownHash: Int = 0

    // ── Lifecycle ───────────────────────────────────────────────

    /// Start watching. Creates `~/.coffeetosh/` directory if missing.
    public init() {}

    public func start() {
        let dir = StatusFileManager.directoryURL
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        // Ensure the file exists so we can open a descriptor
        if !FileManager.default.fileExists(atPath: StatusFileManager.fileURL.path) {
            try? StatusFileManager.write(.inactive)
        }

        startFSWatch()
        startPollFallback()
    }

    /// Tear down all watchers and close the file descriptor.
    public func stop() {
        dispatchSource?.cancel()
        dispatchSource = nil

        pollTimer?.cancel()
        pollTimer = nil

        if fileDescriptor != -1 {
            close(fileDescriptor)
            fileDescriptor = -1
        }
    }

    deinit { stop() }

    // ── FSEvents (primary) ──────────────────────────────────────

    private func startFSWatch() {
        let path = StatusFileManager.fileURL.path
        fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("[FileSystemWatcher] ⚠️ Could not open \(path) — relying on poll fallback only.")
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .rename, .delete],
            queue: watchQueue
        )

        source.setEventHandler { [weak self] in
            self?.handleFileChange()
        }

        source.setCancelHandler { [weak self] in
            if let fd = self?.fileDescriptor, fd != -1 {
                close(fd)
                self?.fileDescriptor = -1
            }
        }

        source.resume()
        dispatchSource = source
    }

    // ── Polling fallback (every 10s) ────────────────────────────

    private func startPollFallback() {
        let timer = DispatchSource.makeTimerSource(queue: watchQueue)
        timer.schedule(deadline: .now() + 10, repeating: 10)
        timer.setEventHandler { [weak self] in
            self?.handleFileChange()
        }
        timer.resume()
        pollTimer = timer
    }

    // ── Shared handler ──────────────────────────────────────────

    private func handleFileChange() {
        guard let data = try? Data(contentsOf: StatusFileManager.fileURL) else { return }
        let hash = data.hashValue
        guard hash != lastKnownHash else { return } // No change
        lastKnownHash = hash

        guard let status = try? StatusFileManager.read() else { return }
        DispatchQueue.main.async { [weak self] in
            self?.onChange?(status)
        }
    }
}
