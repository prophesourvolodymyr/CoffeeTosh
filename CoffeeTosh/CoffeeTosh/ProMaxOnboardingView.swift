import SwiftUI

struct ProMaxOnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    let totalPages = 4

    // Trackpad / mouse-drag panning
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging:  Bool   = false

    private let navBarHeight: CGFloat = 58

    var body: some View {
        GeometryReader { geometry in
            let W = geometry.size.width
            let H = geometry.size.height
            let pageH = currentPage == 3 ? H : H - navBarHeight

            VStack(spacing: 0) {
                // ── Page viewport ──────────────────────────────────────────
                ZStack {
                    HStack(spacing: 0) {
                        OnboardingPageHook(isActive: currentPage == 0)
                            .frame(width: W, height: pageH)

                        OnboardingPageArsenal(isActive: currentPage == 1)
                            .frame(width: W, height: pageH)

                        OnboardingPageBouncer(isActive: currentPage == 2)
                            .frame(width: W, height: pageH)

                        OnboardingPageSplash(
                            hasCompletedOnboarding: $hasCompletedOnboarding,
                            isActive: currentPage == 3
                        )
                        .frame(width: W, height: pageH)
                    }
                    .frame(width: W, alignment: .leading)
                    .offset(x: -(W * CGFloat(currentPage)) + dragOffset)
                    .animation(isDragging ? nil
                               : .interactiveSpring(response: 0.5, dampingFraction: 0.78,
                                                    blendDuration: 0.4),
                               value: currentPage)
                }
                .frame(width: W, height: pageH)
                .clipped()
                // Trackpad swipe gesture
                .gesture(
                    DragGesture(minimumDistance: 15, coordinateSpace: .local)
                        .onChanged { v in
                            isDragging = true
                            let t = v.translation.width
                            // Rubber-band at the edges
                            if (currentPage == 0 && t > 0) ||
                               (currentPage == totalPages - 1 && t < 0) {
                                dragOffset = t * 0.18
                            } else {
                                dragOffset = t
                            }
                        }
                        .onEnded { v in
                            isDragging = false
                            let threshold = W * 0.22
                            if v.translation.width < -threshold, currentPage < totalPages - 1 {
                                currentPage += 1
                            } else if v.translation.width > threshold, currentPage > 0 {
                                currentPage -= 1
                            }
                            withAnimation(.interactiveSpring(response: 0.4,
                                                             dampingFraction: 0.82)) {
                                dragOffset = 0
                            }
                        }
                )

                // ── Bottom nav bar ─────────────────────────────────────────
                Group {
                    if currentPage == 3 {
                        // Page 4 — no nav chrome at all; clean borderless canvas
                        EmptyView()
                    } else if currentPage == 0 {
                        // Page 1 — only a centred "Start" pill, no dots, no back
                        HStack {
                            Spacer()
                            Button(action: { currentPage = 1 }) {
                                Text("Start")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 36)
                                    .padding(.vertical, 11)
                                    .background(warmAmber)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                    } else {
                        // Pages 2-4 — dots + back + next
                        HStack(alignment: .center) {
                            Button(action: { currentPage -= 1 }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(warmAmber)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 80, alignment: .leading)
                            .padding(.leading, 20)

                            Spacer()

                            // 3 dots representing pages 2-4 (indices 1-3)
                            HStack(spacing: 8) {
                                ForEach(1..<totalPages, id: \.self) { index in
                                    Circle()
                                        .fill(currentPage == index
                                              ? warmAmber
                                              : Color.white.opacity(0.28))
                                        .frame(width: 8, height: 8)
                                        .animation(.spring(), value: currentPage)
                                }
                            }

                            Spacer()

                            if currentPage < totalPages - 1 {
                                Button(action: { currentPage += 1 }) {
                                    Text("Next")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 22)
                                        .padding(.vertical, 9)
                                        .background(warmAmber)
                                        .cornerRadius(20)
                                }
                                .buttonStyle(.plain)
                                .frame(width: 80, alignment: .trailing)
                                .padding(.trailing, 20)
                            } else {
                                Color.clear.frame(width: 80).padding(.trailing, 20)
                            }
                        }
                    }
                }
                .frame(width: W, height: currentPage == 3 ? 0 : navBarHeight)
                .background(currentPage == 3 ? textPrimary : popoverBase)
            }
        }
        .background(currentPage == 3 ? textPrimary : popoverBase)
        .animation(.easeInOut(duration: 0.2), value: currentPage)
    }
}

// MARK: - Page 1: The Hook
struct OnboardingPageHook: View {
    let isActive: Bool
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image("logo-filled")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(warmAmber)
                .frame(width: 180, height: 180)
                .shadow(color: warmAmber.opacity(0.35), radius: 28, x: 0, y: 8)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.55)
                .animation(.spring(response: 0.55, dampingFraction: 0.58).delay(0.04), value: appeared)

            VStack(spacing: 12) {
                Text("Give your Mac a shot of this.")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundColor(textPrimary)

                Text("Caffeine Drip. Close your lid, go grab coffee, come back—your downloads and music are still running.")
                    .font(.system(size: 16))
                    .foregroundColor(textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 26)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.22), value: appeared)

            Spacer()
        }
        .onAppear {
            // Page 1 is the launch page — fire immediately on first appear
            if isActive {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { appeared = true }
            }
        }
        .onChange(of: isActive) { active in
            if active {
                appeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { appeared = true }
            } else {
                appeared = false
            }
        }
    }
}

// MARK: - Page 2: The Arsenal
struct OnboardingPageArsenal: View {
    /// True only while this page is the visible current page.
    /// Triggers entrance animation exactly when the user arrives — not at launch.
    let isActive: Bool
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ─────────────────────────────────────────────────────
            VStack(spacing: 8) {
                Text("The Arsenal")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(textPrimary)
                Text("Keep Awake for everyday use. Lid Closed for remote work.")
                    .font(.system(size: 14))
                    .foregroundColor(textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 40)
            .padding(.bottom, 28)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.05), value: appeared)

            // ── Cards ──────────────────────────────────────────────────────
            HStack(alignment: .center, spacing: 24) {
                GuiMockupCard(isActive: appeared)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 60)
                    .animation(.spring(response: 0.55, dampingFraction: 0.62).delay(0.15), value: appeared)

                TerminalMockupCard(isActive: appeared)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 60)
                    .animation(.spring(response: 0.55, dampingFraction: 0.62).delay(0.28), value: appeared)
            }
            .padding(.horizontal, 30)

            Spacer()
        }
        // Use onChange so animations fire when the user *arrives* on this page,
        // not at app launch when all HStack pages initialise simultaneously.
        .onChange(of: isActive) { active in
            if active {
                appeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    appeared = true
                }
            } else {
                appeared = false  // reset so the animation replays on revisit
            }
        }
    }
}

// MARK: - Left card: mini CoffeeTosh popover mockup
private struct GuiMockupCard: View {
    let isActive: Bool
    @State private var timerActive = false
    @State private var totalSeconds = 9000 // 02:30:00 — "2h" preset selected
    @State private var btnScale: CGFloat = 1.0
    @State private var tickTask: Task<Void, Never>? = nil

    // Zero-padded exactly like the real ContentView
    private var timerText: String {
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    // Mirrored from durationPresets in ContentView (truncated to 5 to fit card)
    private let pills = ["30m", "1h", "2h", "8h", "∞"]

    var body: some View {
        VStack(spacing: 0) {
            // Card label badge
            Text("MENU BAR UI")
                .font(.system(size: 9, weight: .black))
                .tracking(1.5)
                .foregroundColor(warmAmber)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(warmAmber.opacity(0.12))
                .cornerRadius(4)
                .padding(.top, 14)

            VStack(spacing: 8) {
                // ── Real segmented mode picker ──────────────────────────────
                HStack(spacing: 0) {
                    // "Keep Awake" — active tab
                    Text("Keep Awake")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(popoverBase)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(warmAmber)
                        .cornerRadius(5)
                    // "Lid Closed" — inactive tab
                    Text("Lid Closed")
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundColor(textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color.clear)
                        .cornerRadius(5)
                }
                .padding(2)
                .background(cardSection)
                .cornerRadius(7)
                .padding(.top, 4)

                // ── Real timer block (cardSection rect, same as ContentView) ─
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(cardSection)
                    Text(timerText)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(timerActive ? warmAmber : textPrimary)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.linear(duration: 0.18), value: totalSeconds)
                }
                .frame(height: 52)

                // ── Real duration grid (5 columns matching ContentView) ──────
                HStack(spacing: 4) {
                    ForEach(pills, id: \.self) { label in
                        Text(label)
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(label == "2h" ? popoverBase : (timerActive ? textSecondary.opacity(0.4) : textPrimary))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(label == "2h" ? warmAmber : cardSection)
                            )
                    }
                }

                // ── Real CTA button ("Start Session" / "Stop Session") ───────
                Text(timerActive ? "Stop Session" : "Start Session")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(popoverBase)           // ← real uses popoverBase text
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(timerActive ? Color.red : warmAmber)
                    )
                    .scaleEffect(btnScale)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 10)
            .padding(.top, 6)
        }
        .frame(width: 190)
        .background(popoverBase)          // ← real popover background
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(warmAmber.opacity(0.18), lineWidth: 1)
        )
        .onAppear {}
        .onChange(of: isActive) { active in
            if active {
                timerActive  = false
                totalSeconds = 9000
                tickTask?.cancel()

                // Animate a real button press at 0.8s, then start ticking
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.12, dampingFraction: 0.6)) { btnScale = 0.88 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { btnScale = 1.0 }
                        timerActive = true
                        startTicking()
                    }
                }
            } else {
                timerActive  = false
                btnScale     = 1.0
                tickTask?.cancel()
                tickTask     = nil
                totalSeconds = 9000
            }
        }
    }

    private func startTicking() {
        tickTask?.cancel()
        tickTask = Task {
            while !Task.isCancelled && totalSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                await MainActor.run { totalSeconds -= 1 }
            }
        }
    }
}

// MARK: - Right card: terminal typing mockup
private struct TerminalMockupCard: View {
    let isActive: Bool
    private let fullCommand = "coffeetosh start --headless 6h"
    private let responseLines = [
        "  session started",
        "  mode: headless",
        "  duration: 6h",
        "  ☕ enjoy.",
    ]

    @State private var typedCommand = ""
    @State private var visibleResponseLines: Int = 0
    @State private var cursorVisible = true
    @State private var typingDone = false
    @State private var animTask: Task<Void, Never>? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Card label badge
            Text("CLI TOOL")
                .font(.system(size: 9, weight: .black))
                .tracking(1.5)
                .foregroundColor(warmAmber)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(warmAmber.opacity(0.12))
                .cornerRadius(4)
                .padding(.top, 14)

            // Terminal window
            VStack(alignment: .leading, spacing: 0) {
                // Traffic lights
                HStack(spacing: 5) {
                    Circle().fill(Color(red:1, green:0.37, blue:0.34)).frame(width: 7, height: 7)
                    Circle().fill(Color(red:1, green:0.73, blue:0.16)).frame(width: 7, height: 7)
                    Circle().fill(Color(red:0.18, green:0.78, blue:0.35)).frame(width: 7, height: 7)
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 6)

                // Prompt row
                HStack(alignment: .top, spacing: 0) {
                    Text("❯ ")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(warmAmber)
                    Text(typedCommand)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(textPrimary)
                    if !typingDone {
                        Rectangle()
                            .fill(cursorVisible ? textPrimary : Color.clear)
                            .frame(width: 6, height: 11)
                            .offset(y: 1)
                    }
                }
                .padding(.horizontal, 10)

                // Response lines
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(responseLines.prefix(visibleResponseLines), id: \.self) { line in
                        Text(line)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(line.contains("☕") ? warmAmber : textSecondary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 4)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
            .background(Color.black.opacity(0.55))
            .cornerRadius(10)
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .frame(width: 190)
        .background(cardSection)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(warmAmber.opacity(0.18), lineWidth: 1)
        )
        .onAppear {}
        .onDisappear {
            animTask?.cancel()
            animTask = nil
        }
        .onChange(of: isActive) { active in
            if active {
                startAnimation()
            } else {
                animTask?.cancel()
                animTask = nil
                typedCommand = ""
                visibleResponseLines = 0
                typingDone = false
                cursorVisible = true
            }
        }
    }

    private func startAnimation() {
        // Cancel any previous run (e.g. page revisit)
        animTask?.cancel()

        // Reset state
        typedCommand = ""
        visibleResponseLines = 0
        typingDone = false
        cursorVisible = true

        animTask = Task {
            // Blink cursor + type simultaneously
            async let blink: Void = blinkCursor()
            async let type: Void = typeCommand()
            _ = await (blink, type)
        }
    }

    @MainActor
    private func blinkCursor() async {
        // Blink until typing is done, then stop
        while !typingDone {
            guard !Task.isCancelled else { return }
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            guard !Task.isCancelled else { return }
            cursorVisible.toggle()
        }
    }

    @MainActor
    private func typeCommand() async {
        // Initial pause before typing starts
        try? await Task.sleep(nanoseconds: 400_000_000)
        guard !Task.isCancelled else { return }

        for char in fullCommand {
            guard !Task.isCancelled else { return }
            typedCommand.append(char)
            try? await Task.sleep(nanoseconds: 65_000_000) // ~65 ms per char
        }

        guard !Task.isCancelled else { return }
        typingDone = true

        // Reveal response lines one by one
        for i in 0..<responseLines.count {
            guard !Task.isCancelled else { return }
            try? await Task.sleep(nanoseconds: 220_000_000) // 0.22s between lines
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.15)) {
                visibleResponseLines = i + 1
            }
        }

        // Loop: restart after a pause so the card keeps playing on long page views
        try? await Task.sleep(nanoseconds: 2_500_000_000) // 2.5s pause
        guard !Task.isCancelled else { return }
        startAnimation()
    }
}

// MARK: - Page 3: The Bouncer
struct OnboardingPageBouncer: View {
    let isActive: Bool
    @State private var appeared = false

    // Three honest feature bullets
    private let bullets: [(String, String, String)] = [
        ("eye.slash.fill",          "Invisible by default",    "Lives only in the menu bar. No Dock icon, no windows unless you want them."),
        ("bolt.fill",               "One click awake",         "Single click activates your preset. Hold ⌥ to open the full timer panel."),
        ("lock.open.fill",          "You're always in control","Stop anytime. Close the app and macOS goes back to its normal sleep schedule."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Shield icon — no circle, no float
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 44))
                .foregroundColor(warmAmber)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.5)
                .animation(.spring(response: 0.52, dampingFraction: 0.58).delay(0.05), value: appeared)

            // Title
            Text("Minimal. Honest. Yours.")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(textPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 6)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 22)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.20), value: appeared)

            Text("CoffeeTosh keeps your Mac awake using native macOS power assertions — no kernel extensions, no background agents, nothing hidden.")
                .font(.system(size: 14))
                .foregroundColor(textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 56)
                .padding(.bottom, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 18)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.30), value: appeared)

            // Bullet rows — each staggers in
            VStack(spacing: 10) {
                ForEach(Array(bullets.enumerated()), id: \.element.0) { index, bullet in
                    let (icon, title, desc) = bullet
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(warmAmber)
                            .frame(width: 32, height: 32)
                            .background(warmAmber.opacity(0.10))
                            .cornerRadius(8)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(textPrimary)
                            Text(desc)
                                .font(.system(size: 12))
                                .foregroundColor(textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(2)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 52)
                    .opacity(appeared ? 1 : 0)
                    .offset(x: appeared ? 0 : -28)
                    .animation(
                        .spring(response: 0.48, dampingFraction: 0.68)
                            .delay(0.40 + Double(index) * 0.10),
                        value: appeared
                    )
                }
            }

            Spacer()
        }
        .onChange(of: isActive) { active in
            if active {
                appeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    appeared = true
                }
            } else {
                appeared = false
            }
        }
    }
}

// MARK: - Page 4: The Splash (Metal ray-marched metaball liquid)
struct OnboardingPageSplash: View {
    @Binding var hasCompletedOnboarding: Bool
    /// Only true when this page is the current page in the pager.
    let isActive: Bool

    @State private var controller = LiquidController()
    @State private var buttonTapped = false       // triggers zoom-in + fade
    @State private var buttonVisible = true       // controls opacity

    var body: some View {
        ZStack {
            // Cream fallback while Metal renders first frame
            textPrimary.edgesIgnoringSafeArea(.all)

            // Metal metaball liquid renderer
            MetalLiquidView(controller: controller, isActive: isActive)
                .ignoresSafeArea()

            // "ADDICT YOUR MAC" button — floats above the liquid
            if buttonVisible {
                VStack {
                    Spacer()
                    Button(action: handleButtonTap) {
                        Text("ADDICT YOUR MAC")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                            .background(Color(red: 60/255, green: 40/255, blue: 20/255))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(buttonTapped ? 1.35 : 1.0)
                    .opacity(buttonTapped ? 0 : 1)
                    .animation(.spring(response: 0.6, dampingFraction: 0.55), value: buttonTapped)
                    .disabled(buttonTapped)
                    Spacer()
                }
            }
        }
        .onAppear {
            controller.onFloodComplete = {
                withAnimation(.easeInOut(duration: 0.4)) {
                    hasCompletedOnboarding = true
                }
            }
        }
    }

    private func handleButtonTap() {
        // 1. Zoom-in + fade the button
        withAnimation { buttonTapped = true }

        // 2. Tell the renderer to flood the canvas (shorter delay → feels snappier)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            controller.triggerFlood()
        }

        // 3. Hide button from tree after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            buttonVisible = false
        }
    }
}
