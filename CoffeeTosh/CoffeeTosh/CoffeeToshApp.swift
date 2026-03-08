//
//  CoffeeToshApp.swift
//  CoffeeTosh
//
//  Created by Volodymur Vasualkiw on 3/3/26.
//

import SwiftUI
import CoffeetoshCore
import AppKit

// MARK: - AppDelegate
// Creates AppState and StatusBarManager early so NSStatusItem exists before
// any SwiftUI scene runs. This is required for ⌥+click detection.

class AppDelegate: NSObject, NSApplicationDelegate {
    let appState = AppState()
    private(set) var statusBarManager: StatusBarManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarManager = StatusBarManager(appState: appState)

        // Orphan cleanup: if a previous GUI session crashed without restoring system
        // state (no daemon means no crash recovery), clean it up now.
        if let stale = try? StatusFileManager.read(), stale.active, !DaemonLauncher.isRunning() {
            print("[AppDelegate] Orphaned session detected — running cleanup.")
            if stale.mode == .headless {
                // Try non-interactive sudo first (works if auth token cached <5 min).
                // Silent — no dialog, no user interruption on relaunch.
                ShellHelper.run("sudo -n pmset -a disablesleep 0 2>/dev/null")
            }
            // Record the crashed session in history so it shows in Analytics.
            if let start = stale.startTime {
                let actualSecs = max(1, Int(Date().timeIntervalSince(start)))
                let item = SessionHistoryItem(
                    startTime: start,
                    durationSeconds: stale.durationSeconds,
                    actualDurationSeconds: actualSecs,
                    mode: stale.mode,
                    endReason: "Crash Recovery"
                )
                HistoryManager.shared.appendSession(item)
            }
            try? StatusFileManager.markInactive()
        }

        // On first launch, before onboarding is completed, open the Dashboard window.
        let completed = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        if !completed {
            DispatchQueue.main.async {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows.first { $0.canBecomeKey }?.makeKeyAndOrderFront(nil)
            }
        }
    }

    // Intercept ALL quit paths (Cmd+Q, terminate(), Dock → Quit).
    // If a session is running, stop it first so pmset is restored and
    // history is written BEFORE the process dies.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard (try? StatusFileManager.read())?.active == true || SleepManager.shared.isActive else {
            return .terminateNow
        }
        // Pause quit, restore on background thread (NSAppleScript dialog may show
        // for headless pmset restore), then resume termination.
        DispatchQueue.global(qos: .userInitiated).async {
            SleepManager.shared.restore(reason: "App Quit")
            DispatchQueue.main.async {
                NSApp.reply(toApplicationShouldTerminate: true)
            }
        }
        return .terminateLater
    }

    // Keep the process alive after all windows close (menu bar app)
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

// MARK: - App Entry Point

@main
struct CoffeeToshApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // NSStatusItem in StatusBarManager handles the icon — no MenuBarExtra needed.
        WindowGroup(id: "Dashboard") {
            DashboardView()
                .environmentObject(appDelegate.appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)   // locks to exact content frame = non-resizable
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

class AppState: ObservableObject {
    @Published var status: CoffeetoshStatus = .inactive
    @Published var showInlineTimer: Bool = true // Can be toggled in F3 Phase 3 Settings
    
    private var watcher: FileSystemWatcher?
    private var localEventMonitor: Any?
    private var globalEventMonitor: Any?
    
    init() {
        self.status = (try? StatusFileManager.read()) ?? .inactive
        
        watcher = FileSystemWatcher()
        watcher?.onChange = { [weak self] newStatus in
            DispatchQueue.main.async {
                self?.status = newStatus
            }
        }
        watcher?.start()
        
        setupShortcut()
    }
    
    deinit {
        watcher?.stop()
        if let local = localEventMonitor { NSEvent.removeMonitor(local) }
        if let global = globalEventMonitor { NSEvent.removeMonitor(global) }
    }
    
    private func setupShortcut() {
        // Simple NSEvent monitor for CMD+SHIFT+L
        let handler: (NSEvent) -> Void = { [weak self] event in
            if event.modifierFlags.contains(.command) && event.modifierFlags.contains(.shift) {
                if event.charactersIgnoringModifiers?.lowercased() == "l" {
                    self?.toggleShortcutAction()
                }
            }
        }
        
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: handler)
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handler(event)
            return event
        }
    }
    
    private func toggleShortcutAction() {
        // Start or stop based on state directly via SleepManager
        if status.active {
            SleepManager.shared.restore()
        } else {
            // Read last mode/duration, fallback to keepAwake indefinite
            let lastStatus = (try? StatusFileManager.read()) ?? .inactive
            SleepManager.shared.activate(
                mode: lastStatus.mode == .headless ? .headless : .keepAwake,
                durationSeconds: lastStatus.durationSeconds,
                skipAdmin: false
            )
        }
    }
}

