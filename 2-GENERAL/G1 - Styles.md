# 🏛️ G1 - Coffeetosh Style System (Visual Law)
**Date:** 2026-03-02
**Status:** 🟢 Active Source of Truth

*Note: Coffeetosh operates as an independent app. This G1 file assumes full authority over the visual design system.*

---

## 1. 🎨 Token Dictionary

### 1.1 Brand Colors
- **Warm Amber (Primary Accent):** 
  - Dark Mode: `#D4923A`
  - Light Mode: `#C47A2D`
  - *Usage:* Active app states, countdown timers, selected segment controls, and primary buttons. Replaces standard "system green."

### 1.2 Espresso Dark Theme (Default)
The application defaults to Dark Mode to maintain a heavy, developer-tool presence.
- **Backgrounds:**
  - Page/Window Base: `#1A1310`
  - Popover Base: `#2A2019`
  - Section/Card: `#342920`
  - Sidebar: `#171110` (Adapts in Light Mode)
- **Text:**
  - Primary: `#F0E6D8`
  - Secondary: `#A89680`
  - Tertiary: `#7A6655`

### 1.3 Laté Light Theme (Fallback)
If explicitly forced by system metrics, the application will fallback to the Light palette.
- **Backgrounds:**
  - Page/Window Base: `#F5EDE3`
  - Popover Base: `#FFFBF5`
  - Section/Card: `#F0E6D8`
  - Sidebar: `#3B2E24` (Matches theme logic)
- **Text:**
  - Primary: `#2C1E12`
  - Secondary: `#7A6655`
  - Tertiary: `#A89680`

---

## 2. 📐 Form & Geometry

### 2.1 Spatial Paradigms
- **iOS 16 Architectural Influence:**
  - Implement grouping lists prominently.
  - Toggles and switches must use modern, thick pill styles.
  - Text scales must utilize dynamic SF Pro weight variations.
- **"Breathing Room" Rule:** Elements MUST heavily favor space. Do not artificially compress inputs, stats, or text (especially in Indefinite loops or popovers) to save vertical pixels. Add padding.

### 2.2 Component Radii
- **Base Popover Radius:** `14px`
- **Inner Component Radius:** `10px` (Cards, Panels)
- **Small Element Radius:** `6px` (Status badges)
- **Buttons / Segmented Controls:** Inherit iOS 16 capsule or tightly rounded rectangular radii depending on the container context, anchored largely to `14px` parent constraints.

---

## 3. 🖼️ Visual Assets Data Dictionary

**Rule of Law:** Do not generate or accept inline raw SVG approximations of the logo. All UI implementations must consume the dedicated production assets located in the internal bundle.

### 3.1 Core Motif Asset Paths
All implementations must path to the respective files located at:
`NOTES/Coffeetosh UI/ASSETS/`

1. **`logo-outline.svg`**: Unfilled, transparent inner-cup lines. Used for "OFF" / Inactive states.
2. **`logo-filled.svg`**: Solid inner cup acting as a physical mask for the Macintosh face cutout. Used for "ON" / Active states.
3. **`logo-animated.svg`**: Standalone F-Cycle tested vector wrapping `transform: scale()` cubic-bezier animations. Used for App loading states, Dashboard hero sections, or About screens.

### 3.2 Dynamic Color Injections
Menu bar graphics respect macOS Template definitions (pure alpha/black/white).
When displaying assets in-app (like the Onboarding or Dashboard screens), developers must colorize the SVG dynamically using framework tools (`.foregroundColor(.accentColor)` in SwiftUI) to inject the **Warm Amber** hue. No duplicated colored SVGs are to be baked into the codebase.