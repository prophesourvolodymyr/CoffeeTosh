# 🔍 Audit for R1 - Coffeetosh UI (LidCaf Menu Bar Interface)
**Date:** 2026-03-02
**Source:** N1 - Coffeetosh UI
**Classification:** UI Feature
**Status:** 🟡 Awaiting User Review (defaults filled — confirm or override)

---

## ❓ Questions
*Please answer the following to clarify your requirements:*

### Q1: Icon Design — SF Symbols or Custom Asset?
Should the menu bar icon use an **SF Symbol** (e.g., `cup.and.saucer.fill` / `bolt.slash.fill` / `moon.zzz.fill`) or a **custom pixel-art/vector asset** bundled with the app? SF Symbols are free, resolution-independent, and native-looking.
**Your Response:**
- ✅ **SF Symbols.** `cup.and.saucer.fill` (active) / `cup.and.saucer` (inactive). Native, resolution-independent, zero asset management. Coffee cup matches the Coffeetosh brand.

### Q2: Menu Bar Popover Style — Inline Menu or Window-Style Popover?
`MenuBarExtra` supports two styles: (a) a **simple inline menu** (like the Wi-Fi/Battery dropdown — flat list of items), or (b) a **window-style popover** (custom SwiftUI view with a card-like layout, more visual control). Which do you prefer?
**Your Response:**
- ✅ **Window-style popover.** We need custom layout for Mode A/B picker, duration selector, countdown display, restart prompt, and Settings panel. Inline menu is too limited. Note: test on macOS 13.x for the known arrow/dismiss bugs.

### Q3: Duration Picker Granularity — Fixed Presets or Free Input?
The N1 lists fixed presets (1, 2, 3, 4, 6, 8, 12, 24h, Indefinite). Should this be **fixed presets only** (simple Picker/menu), or should the user also be able to type a **custom duration** (e.g., "45 minutes", "2.5 hours")?
**Your Response:**
- ✅ **Fixed presets only.** Simple, fast, no input validation needed. Presets: 30min, 1h, 2h, 3h, 4h, 6h, 8h, 12h, 24h, Indefinite. Added 30min for quick tasks.

### Q4: Color Scheme — System Auto or Fixed Dark?
Should the popover follow the **system appearance** (light/dark mode automatically), or should it be **always dark** for a utilitarian "developer tool" vibe?
**Your Response:**
- ✅ **System auto.** Follows macOS light/dark mode. Feels native, respects user preferences.

### Q5: Quit Option in Menu?
Should the menu bar dropdown include a **"Quit LidCaf"** option at the bottom? And if sleep prevention is active when the user quits, should it (a) warn them first, or (b) silently restore settings and quit?
**Your Response:**
- ✅ **Yes, include "Quit LidCaf".** If active: **(a) warn first** — confirmation: "Sleep prevention is active. Quitting will restore normal sleep settings. Quit anyway?" with Cancel / Quit buttons.

---

## 💡 Ideas & Suggestions
*Optional enhancements not in your original request:*

1. **Live Countdown in Menu Bar Title:** Instead of just an icon, show the remaining time directly in the menu bar text (e.g., `☕ 2:34`). Toggleable — some users hate menu bar clutter.
   - **Complexity:** Low
   - **Approve?** [x] Yes / [ ] No
   - **Your Response:** 
     - ✅ Approved. Toggleable in Settings — default OFF. When enabled: `☕ 2:34` next to icon. When disabled: icon only.

2. **Keyboard Shortcut for Toggle:** Register a global hotkey (e.g., `⌘⇧L`) to start/stop sleep prevention without opening the menu.
   - **Complexity:** Medium
   - **Approve?** [x] Yes / [ ] No
   - **Your Response:** 
     - ✅ Approved. Default shortcut configurable in Settings. Uses last-used mode + duration.

3. **History / Log View:** A small section showing recent activations (e.g., "Started 2h ago, stopped manually"). Useful for debugging "was my Mac awake last night?"
   - **Complexity:** Medium
   - **Approve?** [ ] Yes / [x] No
   - **Your Response:** 
     - ❌ Deferred to v2. Logged in Future Ideas.

---

## ⚠️ Problems

- **Problem:** `MenuBarExtra` with `.window` style has known SwiftUI bugs in macOS 13.x where the popover dismisses unexpectedly or the arrow doesn't align. Fixed in macOS 14+.
  - **Suggested Solution:** If targeting macOS 13, test thoroughly and consider using `.menu` style as fallback, or accept macOS 14+ as minimum for the window-style popover.

---

## 📝 Other Notes
*Anything else you want to add? Additional context, changes, or clarifications:*

**Your Response:**
- ✅ **Mode selector UX:** The popover has a prominent Mode A / Mode B toggle at the top (segmented control: "Keep Awake" | "Headless SSH"). Switching modes changes the available options below.
- ✅ **Settings panel:** Opened via a gear icon in the popover footer. Shows as a separate view within the same popover (push navigation), not a separate window. Contains all toggles from the System Audit.
- ✅ **Restart popover:** When timer expires, popover auto-opens showing "Session ended" with Restart and Dismiss buttons.

---

**Next Step:** Review these defaults — override anything you disagree with, then say "Approved" to proceed to R1 + UIDR1 generation.
