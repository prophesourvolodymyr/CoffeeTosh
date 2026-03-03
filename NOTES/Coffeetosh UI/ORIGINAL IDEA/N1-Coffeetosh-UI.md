# N1 - Coffeetosh UI (LidCaf Menu Bar Interface)

**Date:** 2026-03-02
**Status:** 💡 Raw Idea

---

## 🎨 Style Vision

> *(Describe your visual style here — what does this app feel like? Reference other apps, moods, aesthetics, color vibes, anything. This drives the HTML mockup and eventually G1.)*
>
> **Your vision:**
So my primary vision os the Coffe colour pallete, with a logo resembline coffe cup with the makitosh slily face. And ofr the general style it must be minumalistically bold, if you know about focus pomo app, it is this symlar style put brght 0 i coffe colors. 
I wnat tyere to a a small onboarding animation with no initial borders. But the n the app shows Up. The onboarding wll have a quick guide. with a set up and workflow. 

It will not be the full app but on demand window app like explained here on option B: Menu bar is still primary. LSUIElement = true stays.
But a "Dashboard" or "Analytics" link in the popover/settings opens a standalone window (using NSWindow or WindowGroup with openWindow).
Onboarding shows as a window on first launch only, then never again.
The app still has no Dock icon unless the window is open (can toggle NSApp.setActivationPolicy dynamically).
Best for: keeping the utility feel while having room for analytics and onboarding.

> 

---

## The Idea

Menu bar app for LidCaf. No main window — everything lives in a popover from the menu bar icon. One-glance status, zero friction toggle.

---

## UI Elements

### Menu Bar Icon
- Active state: filled icon
- Inactive state: outline icon
- Updates in real-time from both GUI and CLI changes
- Optional: show countdown timer text next to icon (toggleable)

### Mode Picker
- Switch between Mode A (Keep Awake) and Mode B (Headless SSH)
- Locked/disabled while a session is running

### Duration Picker
- Presets: 30min, 1h, 2h, 3h, 4h, 6h, 8h, 12h, 24h, Indefinite
- Remembers last selection
- Hidden when session is active (replaced by countdown)

### Start / Stop Button
- Inactive → "Start" button
- Active → "Stop" button

### Status / Countdown Display
- Active: remaining time (e.g., "5h 42m") or "∞ Indefinite"
- Active: mode badge (which mode is running)
- Inactive: "Sleep prevention off"

### Settings Panel
- Opens within the same popover (push navigation, not a new window)
- Toggles: show timer in menu bar, launch at login, auto-activate on AC power, SSH session monitor, global hotkey configuration

### Session Expired Prompt
- Auto-opens popover when timer expires
- "Session Ended" message with Restart and Dismiss buttons

### Quit Confirmation
- Warning dialog if quitting while a session is active
- Cancel / Quit buttons

### Battery Warning
- Alert when battery is low and session is still active

### State Sync
- GUI reads `~/.lidcaf/status.json`
- Updates in real-time when CLI changes the file
- GUI writes to same file when user acts from menu bar

---

## On-Demand App Window (Option B)

### Window Behavior
- No permanent Dock icon — `LSUIElement = true` by default
- Window opens via "Dashboard" link in popover or Settings
- Dock icon appears only while window is open (`NSApp.setActivationPolicy(.regular)`)
- Dock icon disappears when window closes (back to `.accessory`)

### Onboarding Window (First Launch Only)
- Full-size window, borderless on entry, app fades/animates in
- Quick guide walkthrough:
  - What LidCaf does (lid close → Mac stays awake)
  - Mode A vs Mode B explanation (visual)
  - Admin privilege explanation (why pmset needs it, build trust)
  - "Install CLI?" offer (`lidcaf install-cli`)
  - Choose defaults: default mode, default duration, toggles
- After onboarding completes → window closes, menu bar icon appears, never shown again
- Can be re-triggered from Settings ("Show onboarding again")

### Analytics / Dashboard Window
- Session history: list of past sessions (start time, duration, mode, how it ended)
- Usage stats: total hours prevented, sessions this week/month
- Mode split: % time Mode A vs Mode B
- Power source breakdown: % time on AC vs battery while active
- SSH session log (if monitor was enabled): sessions detected, durations
- Calendar heatmap or bar chart of daily usage
- Data stored locally (append to `~/.lidcaf/history.json` or SQLite)

### About Section
- Version info, Coffeetosh branding, GitHub repo link
- Changelog / what's new (read from bundled file)
- Optional: check for updates (GitHub releases API)

---

## Technical Notes

- `MenuBarExtra` with window-style popover (macOS 13+)
- `LSUIElement = true` — no Dock icon by default
- `@main App` struct lifecycle
- `WindowGroup` or `Window` scene for on-demand app window
- `NSApp.setActivationPolicy` toggle for dynamic Dock icon
- `@AppStorage` or file flag for onboarding-completed state
