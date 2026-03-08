# 🧪 R1 - Coffeetosh UI (MenuBar Interface) Research Documentation
**Date:** 2026-03-02
**Status:** 🟢 Finalized Research (Precursor to F2)
**Classification:** UI Feature
**Source:** N1 + Audit-R1 + Global `G1-Styles` overrides

---

## 1. 👁️ The Vision
The Coffeetosh UI is a sleek, menu-bar-first application designed to control sleep prevention and headless connection states. It serves as a utilitarian "developer tool" that rests quietly in the Mac Menu Bar but opens into a structured, iOS 16-inspired card layout (popover). Adhering to the newly established Visual Law, the UI prioritizes a default "Espresso Dark" appearance and utilizes bespoke SVG assets over generic SF Symbols.

---

## 2. 🎛️ The Menu Bar Control (Entry Point)
*How the app lives in the macOS ecosystem.*

- **Iconography System (SVG Overrides):** 
  - The menu bar icon MUST use the custom assets stored in `ASSETS/` (not SF Symbols).
  - **Inactive:** `logo-outline.svg`
  - **Active:** `logo-filled.svg`
  - **Transitions/Loading:** `logo-animated.svg`
- **Live Countdown Display:** 
  - Alongside the icon, the app can optionally display the remaining time directly in the menu bar text (e.g., `☕ 2:34`).
  - This is **toggleable** in Settings (Default: OFF, to prevent menu bar clutter).
- **Popover Style:** 
  - Implements a **Window-style popover** using `MenuBarExtra` for full visual control over custom layouts (cards, pickers, settings), replacing the simple dropdown list.
- **Global Hotkey:** 
  - Supports a system-wide keyboard shortcut (e.g., `⌘⇧L`) to instantly start/stop sleep prevention using the last-used mode and duration.

---

## 3. ⏱️ Core Layout: Modes & Durations
*The primary interactive elements inside the window-style popover.*

- **Mode Selector (iOS 16 Paradigm):** 
  - A prominent segmented control at the top of the popover.
  - Active segments use the bold **Filled Accent (Warm Amber)**.
  - **Mode A:** "Keep Awake" (Standard sleep prevention).
  - **Mode B:** "Headless SSH" (Advanced sleep prevention with network continuity).
- **Duration Picker (Fixed Presets):**
  - Uses preset duration chips to ensure fast, zero-validation user input.
  - **Available Presets:** 30min, 1h, 2h, 3h, 4h, 6h, 8h, 12h, 24h, and Indefinite.
  - Spacing must follow the "Breathing Room" constraint—do not aggressively squash the grid.

---

## 4. ⚙️ Settings & Configuration
*Managing app behavior and user preferences.*

- **Theme Engine:** 
  - Enforced by the `G1` Style Audit: The UI ignores "System Auto" defaults in favor of an **Always Dark (Espresso)** primary state, reinforcing the heavy, professional tool vibe.
- **Settings Panel Navigation:** 
  - Opened via a gear icon located in the popover footer.
  - Operates via **Push Navigation** (slides in as a view within the existing popover) rather than launching an entirely separate detached floating window.
  - Contains toggles for the System rules (Auto-activate on AC, Hide countdown, etc.).

---

## 5. 🛑 Expiry & App Termination
*Graceful handling of end-states and safety guards.*

- **Session Expiry (Restart Prompt):**
  - When a timed session naturally hits `0:00`, the popover auto-opens (if permitted by focus settings) displaying a "Session Ended" prompt.
  - Prominent "Restart" (Warm Amber button) and "Dismiss" options. Space out these elements clearly per the new style rules.
- **Quit Protection:**
  - Standard "Quit Coffeetosh" button exists at the bottom/footer of the main popover.
  - **If inactive:** Quits silently.
  - **If active:** Triggers a confirmation dialogue warning the user: *"Sleep prevention is active. Quitting will restore normal sleep settings. Quit anyway?"* with Cancel/Quit targets.

---
*Next Steps: This document serves as the absolute blueprint for developing the Coffeetosh UI (`F2` or appropriate active feature tier) alongside the visual laws established in `G1`.*