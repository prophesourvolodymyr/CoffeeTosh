# 📊 F3 - Coffeetosh UI Progress Tracker
**Status:** � Complete
**Last Updated:** 2026-03-04
**Source:** R1-Coffeetosh-UI-Documentation.md + G1-Styles.md

---

## 🧑 USER TODOS (Manual Setup Required)
*Tasks the user must complete before development can proceed.*
- [x] **Asset Pipeline Pipeline:** Add `logo-outline`, `logo-filled`, and app icons into the Xcode `Assets.xcassets` catalog and configure them as Template Images where applicable.
- [x] **Xcode Target Settings:** Ensure `LSUIElement` is set to `YES` in `Info.plist` to disable the Dock icon completely and operate entirely from the Menu Bar.

---

## 📋 PHASE 1: Menu Bar Core Hook (`MenuBarExtra`)
*Setting up the macOS GUI entry point.*

- [x] Initialize `MenuBarExtra` targeting the `.window` popup style (macOS 13+).
- [x] Hook `FileSystemWatcher` / Global state (from F2) into the `MenuBarExtra` image tag.
- [x] Wire inactive states to render `logo-outline`.
- [x] Wire active states to render `logo-filled` + Warm Amber color injection.
- [x] Build global `⌘⇧L` shortcut listener to trigger Start/Stop globally.
- [x] Build toggle logic to show/hide the live countdown inline with the icon.

---

## 🎨 PHASE 2: Popover Main Interface Layer
*Building the visual components with heavy "iOS 16 Breathing Room".*

- [x] **Mode Selector:** Create a Segmented Picker (`Keep Awake` vs `Headless SSH`) using fully filled Accent geometry for active states.
- [x] **Status Block:** Create the central timer digits (34pt, heavily weighted SF Pro) displaying remaining operational time.
- [x] **Duration Picker Grid:** Configure a structured grid of pill buttons (30m, 1h, 2h... Indefinite). Disable unselected presets elegantly.
- [x] **Primary CTA:** Create the primary Start/Stop button linked to Warm Amber / Red danger variants.
- [x] **Footer:** Build the lower control bar hosting the Settings "Gear" Icon and the standard "Quit" text.

---

## ⚙️ PHASE 3: Settings Panel & Push Navigation
*Architecting deep linking within the popup.*

- [x] Implement `NavigationStack` or custom slide transitions to transition from Main Popover to Settings without closing the popup entirely.
- [x] Scaffold grouped list layers (iOS 16 style) inside Settings.
- [x] Wire "Auto-activate on AC Power" toggle.
- [x] Wire "SSH Session Monitor" toggle.
- [x] Wire "Hide Menu Bar Timer" toggle.
- [x] Build "Back" button routing back to the main popover interface.

---

## 🛑 PHASE 4: Safety Dialogs & Event Popups
*Catching expiry thresholds and accidental exits.*

- [x] **Quit Dialog:** Build conditional alert capturing Quit: "Sleep prevention is active. Quitting will restore normal sleep settings. Quit anyway?".
- [x] **Expiry Prompt:** Build UI view that conditionally replaces to the active timer stating: "Session ended — Restart?". Wait for F2 engine's `expiredAt` flag to drop the popover open contextually.

---

## 🔗 PHASE 5: F2 Engine IPC Handshake Integration
*Sewing the Engine to the Visuals.*

- [x] Connect "Start Button" press ➔ Trigger `SleepManager.start(...)` with current selected Segment + Duration.
- [x] Connect "Stop Button" press ➔ Trigger `SleepManager.stop()`.
- [x] Invert component interactivity (e.g., locking the duration buttons or mode picker) when `SleepManager` broadcasts `isActive == true`.

---

## 🪟 PHASE 6: On-Demand Window Architecture & Dock Rules
*Breaking out of the Menu Bar constraints.*

- [x] Scaffold `WindowGroup("Dashboard")` in `CoffeeToshApp.swift`.
- [x] Implement dynamic Dock icon toggling (`NSApp.setActivationPolicy(.regular)` / `.accessory`).
- [x] Wire the "Dashboard" and "About" links from the F3 Menu Bar Settings into the `openWindow` environment action.

---

## 🚀 PHASE 7: First-Launch Onboarding
*Building trust and explaining admin privileges.*

- [x] Build the full-size, borderless Onboarding Window view.
- [x] Create the visual walkthrough (What LidCaf does, Mode A vs Mode B, why `pmset` needs admin).
- [x] Implement an "Install CLI" helper button.
- [x] Wire `@AppStorage("hasCompletedOnboarding")` to auto-trigger this window on launch.
- [x] Fix buggs On the onboardong & polish it
- [ ] Make SWIFT logo animation on Page 1 or someghow make SVG taht we ahve already have with animated logo taht I want, Diplay on the page 1. The animation of taht SVG on the SWFT must be identical(If we choose SWIFT option. )

---

## 📊 PHASE 8: Analytics & Dashboard Core
*Visualizing usage data.*

- [x] Build the "Session History" list view (start time, duration, mode, end reason).
- [x] Build the "Usage Stats" overview (total hours prevented, Mode A vs B split, AC vs Battery split).
- [x] Scaffold the local data append logic (writing completed sessions to `~/.lidcaf/history.json`).

---

## ℹ️ PHASE 9: About & Navigation
*The final polish.*

- [x] Build the structured sidebar navigation or tab view (Analytics vs About).
- [x] Build the About section with Coffeetosh branding, version info, and GitHub repository links.

---

## ☕ PHASE 10: Page 4 Coffee Drip Rework
*Replacing static splash with ambient drip + flood transition.*

- [x] ~~Add auto-drip system in `CoffeeSplashScene.update()` (SpriteKit metaball approach)~~ — **SUPERSEDED by Phase 13.**
- [x] ~~Add droplet cap (~70) with oldest-first removal~~ — **SUPERSEDED by Phase 13.**
- [x] ~~Add `triggerFlood()` method~~ — **SUPERSEDED by Phase 13.**
- [x] ~~Add `onFloodComplete` callback~~ — **SUPERSEDED by Phase 13.**
- [x] Rework `OnboardingPageSplash` button: zoom-in + fade animation on tap, then flood + transition.
- [x] Hide bottom nav bar (back arrow, dots, next) on page 4 — full borderless canvas.
- [x] Expand page 4 viewport to full height when nav bar is hidden.

---

## 🌊 PHASE 10: Pro Max Onboarding Engine
*A 4-page interactive physics-based setup experience.*

- [x] Build `WebView` wrapper to natively host CSS-animated `logo-animated.svg`.
- [x] Scaffold the 4-page bouncy generic view structure (The Hook, The Arsenal, The Bouncer, The Splash).
- [x] Build Page 1 ("The Hook"): Animated logo + "Give your Mac a shot of this."
- [x] Build Page 2 ("The Arsenal"): GUI/CLI side-by-side mockup UI.
- [x] Build Page 3 ("The Bouncer"): macOS lock icon + VIP bouncer copy.
- [x] Build Page 4 ("The Splash"): White contrast background + Interactive Coffee Pool Button.
- [x] Implement `SpriteKit` 2D Physics layer over Page 4 to simulate a massive interactive water/coffee splash explosion (drops stay inside bounds, bounce, and are draggable).
- [x] Implement "Lego Stacking" transition: Staggered entry of Dashboard cards upon successful onboarding completion.

---

## 🔴 PHASE 11: Bug Fix Sprint (Post-Handoff)
*Fixing two critical visual regressions blocking the onboarding experience.*

- [x] Replace `AnimatedLogoView` WKWebView with pure SwiftUI `TimelineView`+`Canvas` animated coffee cup logo (Page 1 fix).
- [x] Rebuild `OnboardingPageArsenal` (Page 2) with staggered spring entry animations, GUI mockup card, and terminal typing-animation card.
- [x] Implement "Lego Stacking" reveal animation in `MainDashboardView` (sidebar + stat cards + history rows stagger in on appear).
- [x] Fix `TerminalMockupCard` Combine crash — replaced with async `Task` + `Task.isCancelled` guards, auto-loop after 2.5s.
- [x] Fix Metal/SpriteKit UINT_MAX crash — `isActive: currentPage == 3` gate + `realSize > 1` double-gate on `SpriteView`.
- [x] `didChangeSize` zero-size guard in `CoffeeSplashScene` to prevent unsigned underflow on resize.
- [x] Restore `SKEffectNode` metaball liquid-combining effect (`CIGaussianBlur` + `CIColorMatrix` alpha threshold) — now safe behind `isActive` gate.
- [x] Pure coffee-only drop palette in `CoffeeSplashScene` (darkest espresso / button brown / medium roast — no cream).

## 🔴 PHASE 12: Layout Polish Sprint

- [x] Nav bar — changed from ZStack overlay to VStack row; pages constrained to `height - 62` so nav never covers content.
- [x] Dot indicators — changed from `.gray.opacity(0.3)` to `Color.white.opacity(0.28)` (visible on dark bg).
- [x] Back/Next buttons — fixed-width (.frame(width:80)) so dots always stay centred regardless of which button is shown.
- [x] Page 2 cards — removed fixed `height: 240` and inner `Spacer()`; cards now size to content; terminal window has `minHeight: 130`. No more dead empty space at bottom.
- [x] Page 3 lock icon — bounce animation moved to whole ZStack (circle + icon together); symmetric -7/+7 offset so icon stays centred inside circle at all times.

---

## 🧪 PHASE 13: Metal Ray-Marched Liquid (Page 4 Upgrade)
*Replacing SpriteKit 2D blur hack with true GPU metaball rendering.*

- [x] Create `CoffeeLiquid.metal` shader — per-pixel scalar field evaluation, analytical gradient normals, dual-light Phong + fresnel.
- [x] Create `MetalLiquidView.swift` — `LiquidController` + `MetalLiquidRenderer` (MTKViewDelegate) + `MetalLiquidView` (NSViewRepresentable).
- [x] CPU-side particle physics: gravity, floor/wall bounce, damping.
- [x] Auto-drip system: 1-2 drops every 0.25s from top edge, capped at 50 ambient drops.
- [x] `triggerFlood()`: 120 large drops burst across full width with downward impulse.
- [x] Retina-aware: content scale factor applied to all radii and physics values.
- [x] Replace `OnboardingPageSplash` SpriteKit usage with Metal-based `MetalLiquidView`.
- [x] Remove `import SpriteKit` from `ProMaxOnboardingView.swift` (dead import).
- [x] Page 4 crash on re-entry — `setupMetaball()` now guards `thresholdNode.parent == nil` so node tree is only built once; calling `didMove(to:)` a second time (when `isActive` toggles back to true) no longer crashes SpriteKit with "node already has a parent".

## 🟡 PHASE 13: Dashboard Polish + Status Bar Fix

- [x] **Popup focus fix** — added `NSApp.activate(ignoringOtherApps: true)` before `popover.show` in `StatusBarManager.togglePopover`. Without this the popover never received keyboard focus when the process runs as `.accessory` (no preset set path).
- [x] **Tab notification badges** — `SidebarButton` gains `showBadge: Bool = false`; red pulsing dot appears on Preset and Settings tabs until the user visits them once. `@AppStorage("seenPresetTab")` / `@AppStorage("seenSettingsTab")` persist the "seen" state across launches. Badge animates out on first visit.
- [x] **About section logo** — redesigned `AboutView` with radial amber glow ring (pulsing via `glowPulse` state), subtle circle border, amber version pill, cleaner tagline, and a styled GitHub link button replacing the plain `Link`.
- [x] **No-preset CTA card** — replaced the plain `exclamationmark` row in `DashboardPresetView` with a centred card: amber `bolt.slash.fill` icon in a glowing circle, "No preset configured" headline, description copy, and a downward arrow hint pointing toward the mode/duration pickers below.

## 🟡 PHASE 14: Window + UX Fixes

- [x] **Window locked to 820×540** — changed `frame(minWidth:700, minHeight:500)` to `frame(width:820, height:540)` + switched scene to `.windowResizability(.contentSize)` so the window is a fixed, non-resizable size.
- [x] **Settings back button fixed** — `SettingsView` is shown as a SwiftUI overlay in `ContentView`, so `@Environment(\.dismiss)` was a no-op. Added `var onBack: (() -> Void)? = nil` to `SettingsView`; back button now calls `onBack?()` when provided, otherwise falls back to `dismiss()`. `ContentView` passes `SettingsView(onBack: { withAnimation { showSettings = false } })`.
- [x] **Settings sync confirmed** — both the popover `SettingsView` and `DashboardSettingsView` use identical `@AppStorage` keys (`autoActivateOnACPower`, `sshSessionMonitor`, `hideMenuBarTimer`); `UserDefaults` propagates changes automatically between them.
- [x] **About logo fallback** — added `logoImage` computed property to `AboutView`; checks `NSImage(named: "logo-filled") != nil` at runtime and falls back to `NSApp.applicationIconImage` (the `.icns` app icon, always present) so the About section never shows a blank icon.

## 🟢 PHASE 15: Polish Sprint — About, Preset, Analytics, Animations

- [x] **About redesign** — removed blur blob, glow ring, and circle decorations. Logo now renders clean at 96×96 (was 56×56). Added "Report a Bug" button (`ladybug.fill`, links to GitHub Issues) alongside the GitHub button. Full lego stagger animation (logo scale-in + sequential offset/fade for each element).
- [x] **No-preset notice shrunk** — replaced the large icon-cluster CTA card in `DashboardPresetView` with a single unobtrusive notification row: small `bolt.slash` icon + one-liner copy "No preset configured — pick a mode and duration below", very low opacity, almost invisible.
- [x] **Analytics font unification** — fixed all `.foregroundColor(.gray)` in `StatCard` and `HistoryRow` to use `textSecondary`. Added `.foregroundColor(textPrimary)` to session date/mode/duration text in `HistoryRow`. "No sessions recorded yet" also uses `textSecondary` + explicit size 14. Tag pill bg tightened to `0.08` opacity.
- [x] **Lego animation extended to Preset + About** — `DashboardPresetView` and `AboutView` both gain `@State private var appeared = false` + `.onAppear` trigger + staggered `.spring` animations on each content block (header → status pill → mode picker → duration grid → save CTA in Preset; logo scale → name → version → tagline → divider → buttons in About).

---

## ☕ PHASE 16: Page 4 — Real Coffee Liquid Physics & Interaction
*Making the onboarding Page 4 liquid feel like actual coffee poured into a glass, not jelly.*

**What this is:**
Page 4 ("The Splash") renders a real-time GPU liquid simulation using Metal. Hundreds of coffee-coloured particles drop from the top, settle at the bottom as a rising pool, and the user can push them around with their cursor. Tapping "ADDICT YOUR MAC" triggers a massive flood that fills the entire screen, then transitions to the Dashboard.

**How it works (technical):**
- **Shader** (`CoffeeLiquid.metal`): A full-screen fragment shader evaluates a scalar metaball field — each pixel sums Gaussian contributions `exp(-3d²/R²)` from every particle. Where the total field exceeds a threshold, the pixel is coloured as liquid. In-flight drops are velocity-stretched (elongated in their travel direction) to look like falling teardrops. Edge is softened with a 2px smoothstep.
- **Physics** (`MetalLiquidView.swift`): CPU-side particle simulation runs every frame — gravity pulls drops down, floor/wall bounce, inter-particle collisions with soft push-apart, velocity exchange, lateral pressure (stacked particles push sideways like real fluid under pressure), and impact splash (fast drops kick slow neighbours sideways on hit). Smoothed render positions (lerped toward physics) keep the surface silky.
- **Mouse Interaction**: `PassthroughMTKView` tracks cursor via `NSTrackingArea`. Particles within 80pt of the cursor get a radial repulsion force (quadratic falloff) + directional push from cursor velocity (swiping flings particles). Clicks still pass through to the button.
- **Auto-drip**: Drops spawn every 0.22s from random positions at the top until the liquid pile reaches within 15% of the top edge — unlimited dripping based on actual canvas coverage, not fixed count.
- **Flood**: `triggerFlood()` fires 5 waves of 30 large fast particles at 0.3s intervals, filling the entire canvas. After 2.8s, `onFloodComplete` fires and the app transitions to the Dashboard.

**Tasks:**
- [x] **Gaussian kernel rewrite** — replaced polynomial `(1-d²/R²)²` with `exp(-3d²/R²)` Gaussian — eliminates hard jelly edges, gives organic smooth falloff.
- [x] **Velocity stretching** — in-flight drops elongated via `radius * (1 + speed * stretch)` along velocity direction in the shader — looks like falling teardrops, not balls.
- [x] **Anti-jelly package** — velocity damping (`globalDamping 0.94`), smoothed render positions (renderPos lerped toward physics), settled damping (`0.88`) for floor-touching particles.
- [x] **Real fluid physics** — lateral pressure (stacked particles push sideways, `120.0`), impact splash (fast drops kick slow neighbours, `0.4` force), replaces artificial pool flattening.
- [x] **Unlimited dripping** — fill detection measures highest settled particle position instead of fixed count; drips until liquid is within 15% of top edge.
- [x] **Speed & size tuning** — gravity `1800`, ambient drops `8–14` radius, initial pour `10–18`, flood `20–34`. Fast-falling small drops that accumulate into a thick body.
- [x] **Mouse interaction** — `NSTrackingArea` on `PassthroughMTKView`, radial repulsion force (`3000` strength, `80pt` radius), directional cursor-velocity push, `mouseDown`/`mouseUp` forwarded so button still works.
- [ ] **Final feel tuning** — continue adjusting physics/visual parameters until the liquid feels perfect (fluidity, speed, merge behavior, mouse responsiveness).