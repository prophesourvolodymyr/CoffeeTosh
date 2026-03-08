# 🔍 Audit for R2 - Coffeetosh Style & Brand UI
**Date:** 2026-03-02
**Source:** Style-Mockup-Coffee.html
**Classification:** Style & UI System
**Status:** ✅ Approved by User

*Note: The app is officially named **Coffeetosh**. References to "LidCaf" from earlier drafts are deprecated and to be ignored.*

---

## 🎨 User Style Decisions (Resolved)

### Q1: Accent Color — Warm Amber or Richer Brown?
- **User Selection:** A) Warm Amber (#C47A2D light / #D4923A dark)
- *Rationale:* Stands out against brown surfaces. Good contrast, matching the coffee theme perfectly without blending in too much.

### Q2: Active State Color — Accent or Green?
- **User Selection:** A) Accent (amber/coffee)
- *Rationale:* Keeps the active state closely tied to the brand.

### Q3: Segment Active Style — Filled Accent or Subtle?
- **User Selection:** A) Filled accent (current)
- *Rationale:* Bold, clearly indicates which mode is active.

### Q4: Default Theme — Auto, Light, or Dark?
- **User Selection:** B) Always dark (espresso)
- *Rationale:* Enforces the rich, deep developer-tool aesthetic entirely. The app should default to Dark Mode.

### Q5: Dashboard Sidebar — Dark Espresso or Match Theme?
- **User Selection:** B) Match theme
- *Rationale:* Though the app will default to dark, in the event light mode is used, the sidebar should match the light theme rather than staying dark espresso.

### Q6: Corner Radius — Current (14px popover) or Rounder?
- **User Selection:** A) Current (14px)
- *Rationale:* Balanced, not overly playful.

---

## ⚠️ Additional Constraints & Notes Added by User

1. **Space & Layout:** 
   - *User Note:* "Give space for an object, don't try to squeeze things in like in State: Active — Indefinite." Let the UI breathe.
2. **SVG Source of Truth:** 
   - Do **NOT** use the rough SVGs embedded in the HTML mockup. We are exclusively using the finalized vector assets generated and stored in `NOTES/Coffeetosh UI/ASSETS/` (`logo-animated.svg`, `logo-outline.svg`, `logo-filled.svg`).
3. **iOS 16 UI Paradigm:** 
   - Where needed across the interface, implement styling that mirrors **iOS 16 UI** conventions (clear grouping, modern lists, specific toggle aesthetics, and typography weights).
