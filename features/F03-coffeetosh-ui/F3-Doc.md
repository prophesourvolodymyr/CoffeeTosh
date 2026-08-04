# 🧪 F3-Doc: Coffeetosh UI (MenuBar Interface)
**Date:** 2026-03-02
**Status:** 🟢 Active Structure
**Classification:** UI Feature
**Source:** `NOTES/Coffeetosh UI/RAW/R1-Coffeetosh-UI-Documentation.md`

---

## 1. 👁️ The Vision
The Menu Bar UI translates the invisible power of the `F2` Engine into an elegant, tactile experience. Utilizing a high-fidelity `.window` style popover, it embraces the "Espresso Dark" aesthetic to feel like a premium, native developer tool. It employs precise padding (the "Breathing Room" rule) and heavily heavily leans on modern iOS 16 grouped component design for an uncluttered interactions.

## 2. 🎨 Visual System (Override Protection)
*Adhere strictly to `GENERAL/G1 - Styles.md`.*
- DO NOT use uncertified SF Symbols for the main logo instances. You must strictly import `logo-outline.svg`, `logo-filled.svg`, and `logo-animated.svg` directly from the UI Assets folder.
- Always implement the UI wrapped in forced Dark Mode unless explicitly matching a local macOS fallback override as per G1.

## 3. 🎯 Definition of Done
1. **Entry Point:** The Menu Bar perfectly toggles between empty/outline vs. filled states syncing 1:1 with Daemon `active` signals.
2. **Main Layout:** The popover renders a primary grid featuring Mode Segmented Controls and a zero-validation fixed-preset Duration Picker.
3. **Settings Navigation:** The user can hit the Gear icon to intuitively Push-Navigate (slide in contextually) into the Settings view without causing popover window dismissal.
4. **Safety Prompts:** Clicking quit while a session is running triggers the explicit standard warning dialog preventing accidental sleep state drops.
5. **Dashboard & Analytics:** A standalone, on-demand window without a permanent Dock icon unless opened. Accommodates the unified Settings, About, and Session History stats.
6. **Pro Max Onboarding:** A fast, bouncy 4-page interactive experience on first launch featuring animated web-views, 2D fluid physics for coffee droplets interactive within screen bounds, and staggered "Lego Stacking" transition to the main dashboard.