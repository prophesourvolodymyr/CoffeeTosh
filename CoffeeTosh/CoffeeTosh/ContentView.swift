//
//  ContentView.swift
//  CoffeeTosh
//
//  Created by Volodymur Vasualkiw on 3/3/26.
//

import SwiftUI
import CoffeetoshCore
import Combine

let warmAmber = Color(red: 212/255, green: 146/255, blue: 58/255)
let popoverBase = Color(red: 42/255, green: 32/255, blue: 25/255)
let cardSection = Color(red: 52/255, green: 41/255, blue: 32/255)
let textPrimary = Color(red: 240/255, green: 230/255, blue: 216/255)
let textSecondary = Color(red: 168/255, green: 150/255, blue: 128/255)

struct PresetDuration: Hashable {
    let label: String
    let seconds: Int
}

let durationPresets: [PresetDuration] = [
    PresetDuration(label: "30m", seconds: 30 * 60),
    PresetDuration(label: "1h", seconds: 60 * 60),
    PresetDuration(label: "2h", seconds: 120 * 60),
    PresetDuration(label: "3h", seconds: 180 * 60),
    PresetDuration(label: "4h", seconds: 240 * 60),
    PresetDuration(label: "6h", seconds: 360 * 60),
    PresetDuration(label: "8h", seconds: 480 * 60),
    PresetDuration(label: "12h", seconds: 720 * 60),
    PresetDuration(label: "24h", seconds: 1440 * 60),
    PresetDuration(label: "∞", seconds: 0)
]

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    @AppStorage("presetMode") private var savedPresetMode: String = ""

    @State private var selectedMode: CoffeetoshMode = .keepAwake
    @State private var selectedDuration: Int = 0
    @State private var showQuitAlert       = false
    @State private var showSettings         = false
    @State private var showExpiryPrompt     = false
    @State private var showLidOpenedPrompt  = false

    // Live timer string
    @State private var timerText: String = "00:00:00"
    // Timer block glow pulse
    @State private var timerPulse = false
    // CTA button press spring
    @State private var btnScale: CGFloat = 1.0

    let columns = Array(repeating: GridItem(.flexible()), count: 5)

    var body: some View {
        VStack(spacing: 16) {

            let isLocked = appState.status.active

            // ── No-Preset Tip ─────────────────────────────────────────────────
            // Shown only when no preset is saved and no session is running.
            // Explains why a plain click opens the popup instead of starting instantly.
            if !isLocked && savedPresetMode.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.slash")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(warmAmber.opacity(0.75))
                    Text("Set a Quick Preset in Settings for one-click activation.")
                        .font(.system(size: 11))
                        .foregroundStyle(textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Button(action: { showSettings = true }) {
                        Text("Set")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(warmAmber)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(warmAmber.opacity(0.12))
                            .cornerRadius(5)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(warmAmber.opacity(0.06))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(warmAmber.opacity(0.14), lineWidth: 1))
            }

            // ── Mode Selector ─────────────────────────────────────────────────
            Picker("Mode", selection: $selectedMode) {
                Text("Keep Awake").tag(CoffeetoshMode.keepAwake)
                Text("Lid Closed").tag(CoffeetoshMode.headless)
            }
            .pickerStyle(.segmented)
            .disabled(isLocked)
            .colorMultiply(isLocked ? textSecondary : .white)

            // ── Timer Block ───────────────────────────────────────────────────
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(cardSection)

                // Amber glow border when session is running
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isLocked ? warmAmber.opacity(timerPulse ? 0.55 : 0.18) : Color.clear,
                        lineWidth: 1.5
                    )
                    .animation(
                        isLocked
                            ? .easeInOut(duration: 1.4).repeatForever(autoreverses: true)
                            : .default,
                        value: timerPulse
                    )

                if showExpiryPrompt {
                    VStack(spacing: 4) {
                        Text("Session Ended")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(warmAmber)
                        Button("Restart?") { toggleSession() }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(popoverBase)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(warmAmber))
                            .buttonStyle(.plain)
                    }
                } else if showLidOpenedPrompt {
                    VStack(spacing: 6) {
                        Text("Lid Opened")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(warmAmber)
                        Text("Session is still running")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(textPrimary.opacity(0.7))
                        HStack(spacing: 8) {
                            Button("Stop") {
                                showLidOpenedPrompt = false
                                toggleSession()
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(popoverBase)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.red.opacity(0.8)))
                            .buttonStyle(.plain)

                            Button("Continue") {
                                // Consume the flag so we don't show again
                                if var s = try? StatusFileManager.read() {
                                    s.lidOpenedDuringSession = nil
                                    try? StatusFileManager.write(s)
                                }
                                showLidOpenedPrompt = false
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(popoverBase)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(warmAmber))
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    Text(timerText)
                        .font(.system(size: 34, weight: .bold, design: .monospaced))
                        .foregroundStyle(isLocked ? warmAmber : textPrimary)
                        // countsDown only when an active timed session is running.
                        // Hardcoding true causes the digit-flip to animate downward
                        // even when picking a *higher* preset (idle state), making
                        // the numbers appear to wipe through 0 to reach the target.
                        .contentTransition(.numericText(countsDown: isLocked && appState.status.durationSeconds > 0))
                        .animation(.linear(duration: isLocked ? 0.4 : 0.08), value: timerText)
                }
            }
            .frame(height: 80)

            // ── Duration Grid ─────────────────────────────────────────────────
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(durationPresets, id: \.self) { preset in
                    Button(action: { selectedDuration = preset.seconds }) {
                        Text(preset.label)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selectedDuration == preset.seconds ? popoverBase : textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedDuration == preset.seconds ? warmAmber : cardSection)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isLocked)
                    .opacity(isLocked && selectedDuration != preset.seconds ? 0.3 : 1.0)
                }
            }

            Spacer()

            // ── CTA Button ────────────────────────────────────────────────────
            Button(action: pressToggle) {
                Text(isLocked ? "Stop Session" : "Start Session")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(popoverBase)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isLocked ? Color.red : warmAmber)
                    )
            }
            .buttonStyle(.plain)
            .scaleEffect(btnScale)
            .animation(.spring(response: 0.2, dampingFraction: 0.55), value: btnScale)

            Divider().background(textSecondary.opacity(0.3))

            // ── Footer ────────────────────────────────────────────────────────
            HStack {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(textSecondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {
                    if let url = URL(string: "https://buymeacoffee.com/professorvolodymyr") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("☕ Buy a Coffee")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(red: 0.83, green: 0.57, blue: 0.23))
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Quit") {
                    if appState.status.active { showQuitAlert = true }
                    else { NSApplication.shared.terminate(nil) }
                }
                .buttonStyle(.plain)
                .foregroundStyle(textSecondary)
                .alert("Sleep prevention is active.", isPresented: $showQuitAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Quit anyway", role: .destructive) {
                        NSApplication.shared.terminate(nil)
                    }
                } message: {
                    Text("Quitting will restore normal sleep settings. Quit anyway?")
                }
            }
        }
        .padding(20)
        .frame(width: 280, height: 400)
        .background(popoverBase)
        .colorScheme(.dark)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            updateLiveTimer()
        }
        .onChange(of: appState.status.active) { newValue in
            if newValue {
                selectedMode     = appState.status.mode
                selectedDuration = appState.status.durationSeconds
                showExpiryPrompt    = false
                showLidOpenedPrompt = false
                timerPulse = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { timerPulse = true }
            } else {
                timerPulse = false
                if appState.status.expiredAt != nil { showExpiryPrompt = true }
            }
        }
        .onChange(of: appState.status.lidOpenedDuringSession) { flag in
            if flag == true { showLidOpenedPrompt = true }
        }
        .onAppear {
            if appState.status.active {
                selectedMode     = appState.status.mode
                selectedDuration = appState.status.durationSeconds
                timerPulse = true
                if appState.status.lidOpenedDuringSession == true {
                    showLidOpenedPrompt = true
                }
            } else if appState.status.expiredAt != nil {
                showExpiryPrompt = true
            }
            updateLiveTimer()
        }
        .overlay(
            Group {
                if showSettings {
                    SettingsView(onBack: {
                        withAnimation(.easeInOut(duration: 0.25)) { showSettings = false }
                    })
                    .transition(.move(edge: .trailing))
                }
            }
        )
        .animation(.easeInOut(duration: 0.25), value: showSettings)
    }

    // MARK: - Button press with spring bounce
    private func pressToggle() {
        btnScale = 0.92
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            btnScale = 1.0
            toggleSession()
        }
    }

    // MARK: - Timer string
    private func updateLiveTimer() {
        if appState.status.active {
            if let seconds = appState.status.remainingSeconds {
                let h = seconds / 3600
                let m = (seconds % 3600) / 60
                let s = seconds % 60
                timerText = String(format: "%02d:%02d:%02d", h, m, s)
            } else {
                timerText = "∞"
            }
        } else {
            if selectedDuration == 0 {
                timerText = "∞"
            } else {
                let h = selectedDuration / 3600
                let m = (selectedDuration % 3600) / 60
                let s = selectedDuration % 60
                timerText = String(format: "%02d:%02d:%02d", h, m, s)
            }
        }
    }

    // MARK: - Session toggle
    private func toggleSession() {
        if appState.status.active {
            // Immediately push inactive so the StatusBarManager Combine sink
            // fires updateIcon() now — don't wait 200ms+ for the FileSystemWatcher.
            DispatchQueue.main.async {
                self.appState.status = .inactive
            }
            // Run on background thread so NSAppleScript admin dialogs don't freeze the popover
            DispatchQueue.global(qos: .userInitiated).async {
                SleepManager.shared.restore()
            }
        } else {
            if selectedMode == .headless {
                // Mode B: run on a background thread so the admin dialog
                // (SecurityAgent) can appear and receive key events without
                // the main thread being blocked.  Do NOT set active
                // optimistically — if the user cancels the password prompt,
                // activate() returns false and we must not pretend the
                // session started.  The FileSystemWatcher will confirm the
                // real state once status.json is written on success.
                let dur = selectedDuration
                DispatchQueue.global(qos: .userInitiated).async {
                    SleepManager.shared.activate(
                        mode: .headless,
                        durationSeconds: dur,
                        skipAdmin: false
                    )
                }
            } else {
                SleepManager.shared.activate(
                    mode: selectedMode,
                    durationSeconds: selectedDuration,
                    skipAdmin: false
                )
                // Optimistic: flip the full status so the onChange handler reads
                // the correct mode + durationSeconds, not the stale inactive struct
                // (which has durationSeconds: 0).  Without this, onChange would
                // overwrite selectedDuration = 0 and the timer would flicker to ∞.
                let dur = selectedDuration
                let mod = selectedMode
                DispatchQueue.main.async {
                    var optimistic = self.appState.status
                    optimistic.active = true
                    optimistic.mode = mod
                    optimistic.durationSeconds = dur
                    optimistic.startTime = Date()
                    self.appState.status = optimistic
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
