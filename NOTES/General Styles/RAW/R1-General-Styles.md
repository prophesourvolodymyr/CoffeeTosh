# 🧪 R1 - Coffeetosh General Styles Documentation
**Date:** 2026-03-02
**Status:** 🟢 Finalized Research (Precursor to F1 / G1)
**Classification:** Style & UI System
**Source:** Audit-Styles.md

---

## 1. 👁️ The Vision
The UI for **Coffeetosh** (formerly LidCaf) is designed as a sophisticated, system-native developer tool. It merges deep, utilitarian "espresso" dark modes with warm, rich amber accents to reflect its coffee-themed brand. The core ethos is "breathing room"—interfaces should not feel cramped. Layouts must provide ample space around objects and rely on Apple’s modern **iOS 16 UI paradigm** for organization.

## 2. 🎨 Core Design Mechanics
This section defines how UI components must visually respond to user interaction and system states.

### 2.1 The Theme Engine
- **Default Appearance:** The app defaults strictly to **Dark Mode (Espresso)**. This ensures a heavy, focus-oriented developer aesthetic.
- **Sidebar Behavior:** The Dashboard sidebar matches the theme. While dark mode is default, if a user system overrides into light mode, the sidebar must seamlessly adapt to a light finish (rather than staying persistently dark). 

### 2.2 Accent & Active States
- **Primary Accent:** **Warm Amber** (`#D4923A` in dark mode, `#C47A2D` in light mode).
- **Semantics:** 
  - The Warm Amber is used exclusively for active states, running timers, and prominent call-to-actions.
  - Using green for "active" is explicitly forbidden; Coffeetosh uses its brand amber.
- **Segmented Controls:** Active segments must use a fully **Filled Accent** background to boldly indicate the current operation mode.

### 2.3 Geometry & Layout
- **Border Radius:** Popovers and floating elements are anchored at a **14px** corner radius. This is balanced—neither dangerously sharp nor overly playful.
- **Spatial Concept ("Breathing Room"):** 
  - Never squeeze components together (especially in the "Active / Indefinite" states).
  - Adopt iOS 16 grouped list styles: heavily padded cells, distinct section groupings, and clear visual hierarchy.

## 3. 🖼️ SVG Asset Pipeline

### 3.1 Strict Source of Truth
The HTML mockups contained "rough" approximations of the logo. These are completely discarded. Code generation must strictly synthesize UI using the standalone SVG files extracted to the `ASSETS` pipeline:
- `NOTES/Coffeetosh UI/ASSETS/logo-animated.svg`
- `NOTES/Coffeetosh UI/ASSETS/logo-outline.svg`
- `NOTES/Coffeetosh UI/ASSETS/logo-filled.svg`

### 3.2 Menubar Rendering Constraints
Because macOS enforces "Template Image" rules on the menu bar, the icons are purely structured with Alpha/Black/White values. App-level coloring (like injecting Warm Amber) will happen dynamically in code via `.foregroundColor()` or `currentColor`, rather than maintaining duplicate tinted SVG files.

---
*Proceed to F-Cycle F1 / G1 implementation based on these specifications.*