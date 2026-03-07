// FileSystemWatcher.swift
// Coffeetosh / Coffeetosh Core Engine
// Watches ~/.coffeetosh/status.json for changes via GCD + polling fallback.
//
// Atomic-write safety: StatusFileManager.write() uses .atomic which renames a
// temp file over the old path. This invalidates a file-descriptor watching the
// OLD inode. Fix: watch the DIRECTORY as a second source — the directory fires a
// .write event whenever any file inside is renamed/created. On receiving a
// .rename/.delete on the file source we also re-open the descriptor so the next
// write is caught directly as well.

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
    // File watcher
    private var fileDescriptor: Int32 = -1
    private var fileSource: DispatchSourceFileSystemObject?

    // Directory watcher — catches atomic renames that replace the file
    private var dirDescriptor: Int32 = -1
    private var dirSource: DispatchSourceFileSystemObject?

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

        startFileWatch()
        startDirWatch()
        startPollFallback()
    }

    /// Tear down all watchers and close the file descriptor.
    public func stop() {
        fileSource?.cancel()
        fileSource = nil

        dirSource?.cancel()
        dirSource = nil

        pollTimer?.cancel()
        pollTimer = nil

        if fileDescriptor != -1 { close(fileDescriptor); fileDescriptor = -1 }
        if dirDescriptor  != -1 { close(dirDescriptor);  dirDescriptor  = -1 }
    }

    deinit { stop() }

    // ── File watcher (primary — direct writes) ──────────────────

    private func startFileWatch() {
        let path = StatusFileManager.fileURL.path
        fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("[FileSystemWatcher] ⚠️ Could not open \(path) — relying on dir+poll watchers.")
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .rename, .delete],
            queue: watchQueue
        )

        source.setEventHandler { [weak self] in
            guard let self else { return }
            let flags = source.data
            // Atomic write (.atomic option) renames a temp file over the original —
            // the old fd sees a .rename event and is now stale. Re-open it so the
            // next direct write is also caught. The dir watcher already fired for
            // this rename, so the current change is handled; we just need the fd
            // to point at the new inode going forward.
            if flags.contains(.rename) || flags.contains(.delete) {
                self.reopenFileWatch()
            }
            self.handleFileChange()
        }

        source.setCancelHandler { [weak self] in
            if let fd = self?.fileDescriptor, fd != -1 {
                close(fd)
                self?.fileDescriptor = -1
            }
        }

        source.resume()
        fileSource = source
    }

    /// Cancels the stale file source and re-opens a fresh descriptor after a
    /// small delay (let the kernel finish the rename before we open).
    private func reopenFileWatch() {
        fileSource?.cancel()
        fileSource = nil

        watchQueue.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.startFileWatch()
        }
    }

    // ── Directory watcher (catches atomic renames immediately) ──

    private func startDirWatch() {
        let path = StatusFileManager.directoryURL.path
        dirDescriptor = open(path, O_EVTONLY)
        guard dirDescriptor != -1 else {
            print("[FileSystemWatcher] ⚠️ Could not open directory \(path)")
            return
        }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: dirDescriptor,
            eventMask: [.write],   // fires when any file is created/renamed inside
            queue: watchQueue
        )

        source.setEventHandler { [weak self] in
            // Any change inside the dir (including atomic rename of status.json)
            self?.handleFileChange()
        }

        source.setCancelHandler { [weak self] in
            if let fd = self?.dirDescriptor, fd != -1 {
                close(fd)
                self?.dirDescriptor = -1
            }
        }

        source.resume()
        dirSource = source
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
