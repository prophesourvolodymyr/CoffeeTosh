import AppKit
import SwiftUI
import CoffeetoshCore
import Combine

// MARK: - StatusBarManager
// Owns the NSStatusItem so we can detect ⌥+click (impossible with SwiftUI MenuBarExtra).
// Click logic:
//   • No preset set     → open full popover immediately
//   • ⌥+click          → open full popover
//   • Normal click      → activate/stop the saved preset
//   • 3 rapid clicks    → show "Hold ⌥ + click to open timer" hint toast

final class StatusBarManager: NSObject {

    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()

    // Multi-click confusion detection
    private var rapidClickCount = 0
    private var lastClickTime: Date = .distantPast
    private var hintPanel: NSPanel?

    // Reliable ⌥ tracking: BOTH a global monitor (events in other apps) and a
    // local monitor (events while this app is active) so optionKeyHeld is correct
    // regardless of whether the popover is open. Reset to false after every read.
    private var flagsMonitor: Any?
    private var localFlagsMonitor: Any?
    private var optionKeyHeld = false

    // Per-second DispatchSourceTimer that refreshes the inline countdown text.
    private var iconTimer: DispatchSourceTimer?
    private let iconTimerQueue = DispatchQueue(label: "com.coffeetosh.icontimer", qos: .utility)

    private var presetMode: String {
        UserDefaults.standard.string(forKey: "presetMode") ?? ""
    }
    private var presetDurationSeconds: Int {
        // 0 = ∞  — exactly how SleepManager interprets it
        UserDefaults.standard.integer(forKey: "presetDurationSeconds")
    }
    private var hasPreset: Bool { !presetMode.isEmpty }

    // MARK: - Init

    init(appState: AppState) {
        self.appState = appState
        super.init()
        setupStatusItem()
        setupPopover()
        setupFlagsMonitor()
        updateIcon()

        // Keep icon in sync with session state changes and manage inline timer
        appState.$status
            .receive(on: RunLoop.main)
            .sink { [weak self] newStatus in
                self?.updateIcon()
                if newStatus.active && UserDefaults.standard.bool(forKey: "showInlineTimer") {
                    self?.startIconTimer()
                } else {
                    self?.stopIconTimer()
                }
                // Auto-open the popover when the daemon signals the lid was opened
                // during a session — user just unlocked and needs to see the prompt.
                if newStatus.lidOpenedDuringSession == true && !(self?.popover.isShown ?? false) {
                    self?.openPopover()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Status Item Setup

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(handleClick(_:))
        // .leftMouseDown fires on every tap regardless of cursor drift on release.
        // .leftMouseUp is NOT reliably delivered by NSStatusBarButton — if the
        // mouse moves a pixel before the user lifts, the hit-test fails and the
        // action is silently swallowed, which is why the preset click did nothing.
        button.sendAction(on: [.leftMouseDown, .rightMouseUp])
    }

    private func setupFlagsMonitor() {
        // Global monitor: fires for key changes while another app is focused.
        flagsMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.optionKeyHeld = event.modifierFlags.contains(.option)
        }
        // Local monitor: fires for key changes while THIS app/popover is focused.
        // Without this, releasing Option after the popover opens is never detected.
        localFlagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.optionKeyHeld = event.modifierFlags.contains(.option)
            return event
        }
    }

    deinit {
        if let m = flagsMonitor      { NSEvent.removeMonitor(m) }
        if let m = localFlagsMonitor { NSEvent.removeMonitor(m) }
        stopIconTimer()
    }

    private func setupPopover() {
        popover.behavior  = .transient
        popover.animates  = true
        popover.contentSize = NSSize(width: 280, height: 400)
        let content = ContentView().environmentObject(appState)
        popover.contentViewController = NSHostingController(rootView: content)
    }

    // MARK: - Click Handler

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        // Snapshot option state then immediately reset so it never bleeds into the next click.
        let isOption     = optionKeyHeld || (NSApp.currentEvent?.modifierFlags.contains(.option) ?? false)
        optionKeyHeld    = false
        let isRightClick = NSApp.currentEvent?.type == .rightMouseUp

        if isOption || isRightClick || !hasPreset {
            rapidClickCount = 0
            togglePopover(from: sender)
            return
        }

        // Preset is set — normal click toggles the preset session
        let now = Date()
        if now.timeIntervalSince(lastClickTime) < 1.4 {
            rapidClickCount += 1
        } else {
            rapidClickCount = 1
        }
        lastClickTime = now

        if rapidClickCount >= 3 {
            rapidClickCount = 0
            togglePopover(from: sender)
            return
        }

        if appState.status.active {
            // ── STOP ──────────────────────────────────────────────────────────
            // Optimistic immediate update so the icon flips without waiting
            // for the FileSystemWatcher round-trip (~200 ms).
            appState.status = .inactive
            updateIconForActiveState(false)
            // Restore runs on a background thread — SleepManager.restore() may
            // call ShellHelper.run() which blocks via Process.waitUntilExit().
            DispatchQueue.global(qos: .userInitiated).async {
                SleepManager.shared.restore()
            }
        } else {
            // ── START ─────────────────────────────────────────────────────────
            let mode: CoffeetoshMode = presetMode == "headless" ? .headless : .keepAwake
            let dur  = presetDurationSeconds

            if mode == .keepAwake {
                // Mode A (IOKit): no dialog, safe to call synchronously on
                // .leftMouseDown — no event-loop conflict whatsoever.
                let activated = SleepManager.shared.activate(mode: mode,
                                                              durationSeconds: dur,
                                                              skipAdmin: false)
                if activated {
                    appState.status.active = true
                    updateIconForActiveState(true)
                }
            } else {
                // Mode B (Headless): dispatch to a background thread so the
                // admin authentication dialog (SecurityAgent) can be shown and
                // interacted with.  Blocking the main thread prevents the dialog
                // from receiving key events, so the password prompt never works.
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self else { return }
                    let activated = SleepManager.shared.activate(mode: mode,
                                                                  durationSeconds: dur,
                                                                  skipAdmin: false)
                    if activated {
                        DispatchQueue.main.async {
                            self.appState.status.active = true
                            self.updateIconForActiveState(true)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Popover

    private func togglePopover(from button: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            // Must activate app first — without this the popover never receives focus
            // when the process runs as .accessory (no Dock icon).
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    func closePopover() {
        popover.performClose(nil)
    }

    func openPopover() {
        guard !popover.isShown, let button = statusItem.button else { return }
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }

    // MARK: - Icon

    func updateIcon() {
        updateIconForActiveState(appState.status.active)
    }

    private func updateIconForActiveState(_ isActive: Bool) {
        guard let button = statusItem.button else { return }
        statusItem.isVisible = true

        let catalogName = isActive ? "logo-filled" : "logo-outline"
        let symbolName  = isActive ? "cup.and.saucer.fill" : "cup.and.saucer"

        // Use .copy() so we never mutate the shared NSImage name-cache entry.
        // Without copy(), setting isTemplate on the cached image can corrupt
        // subsequent lookups by the same name.
        if let img = NSImage(named: catalogName)?.copy() as? NSImage {
            img.isTemplate = true
            img.size = NSSize(width: 18, height: 18)
            button.image   = img
        } else if let sym = NSImage(systemSymbolName: symbolName,
                                    accessibilityDescription: catalogName) {
            sym.isTemplate = true
            button.image   = sym
        } else {
            let fallback = NSApp.applicationIconImage.copy() as! NSImage
            fallback.isTemplate = true
            button.image = fallback
        }

        // Bug #11: inline countdown text — only shown when active + user enabled it.
        let showTimer = isActive && UserDefaults.standard.bool(forKey: "showInlineTimer")
        if showTimer, let secs = appState.status.remainingSeconds {
            let h = secs / 3600
            let m = (secs % 3600) / 60
            button.title = h > 0 ? " \(h)h\(m > 0 ? "\(m)m" : "")" : " \(m)m"
            button.imagePosition = .imageLeft
        } else if showTimer && appState.status.durationSeconds == 0 {
            button.title = " ∞"
            button.imagePosition = .imageLeft
        } else {
            button.title = ""
        }
    }

    // MARK: - Inline Icon Timer

    /// Starts a 1-second repeating timer that refreshes the countdown text in the menu bar.
    func startIconTimer() {
        guard iconTimer == nil else { return }  // already running
        let t = DispatchSource.makeTimerSource(queue: iconTimerQueue)
        t.schedule(deadline: .now() + 1, repeating: 1)
        t.setEventHandler { [weak self] in
            DispatchQueue.main.async { self?.updateIcon() }
        }
        t.resume()
        iconTimer = t
    }

    /// Cancels the countdown timer (called when session stops or timer display is toggled off).
    func stopIconTimer() {
        iconTimer?.cancel()
        iconTimer = nil
    }

    // MARK: - Confusion Hint Panel

    private func showHint(near button: NSStatusBarButton) {
        hintPanel?.close()

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 248, height: 46),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.backgroundColor = .clear
        panel.isOpaque        = false
        panel.hasShadow       = true
        panel.level           = .statusBar
        panel.contentView     = NSHostingView(rootView: HintTooltipView())

        // Position below the status icon
        if let buttonWindow = button.window {
            let buttonRect = button.convert(button.bounds, to: nil)
            let screenRect = buttonWindow.convertToScreen(buttonRect)
            panel.setFrameOrigin(NSPoint(x: screenRect.midX - 124,
                                          y: screenRect.minY - 58))
        }

        panel.orderFront(nil)
        hintPanel = panel

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.hintPanel?.close()
            self?.hintPanel = nil
        }
    }
}

// MARK: - Hint Tooltip View

private struct HintTooltipView: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "option.key")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(warmAmber)
            Text("Right-click or hold ⌥ to open timer")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(cardSection)
                .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
        )
    }
}
