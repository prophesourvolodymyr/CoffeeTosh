# INS-01-NEW: Design System Initialization Protocol

**System ID:** `INS-01-NEW`
**Trigger:** User says "Create Design System", "Initialize General Styles", "Make F1", or "Create Global Styles"
**Target Feature:** `F1` (Reserved for Design System)
**Input Requirement:** `GENERAL/` G-Files (G0) + User preferences
**Output Target:** `GENERAL/G1-Styles.md` & `FEATURES/F1 - General Styles/`

---

## 🎯 STRATEGIC INTENT

This protocol establishes the **Visual Foundation** (F1) and the **Visual Law** (G1).
It builds the *language* (typography, colors, components) that all other features speak.

**Key Definition:**
- **G1 (The Law):** The permanent documentation of "How things should look."
- **F1 (The Tool):** The actual code (Tailwind, CSS) and components.

> **⚠️ GM1 OVERRIDE RULE:** If `GM/GM1-[Brand]-Styles.md` already exists, **G1 is an override file — not a full design system.**
> Do NOT re-document the master palette, base typography, spacing scale, radius scale, or shadow system in G1. Those live in GM1.
> G1 only captures:
> - Project-specific color overrides (e.g. a darker primary for better contrast on this app's dark background)
> - Additional component variants unique to this project
> - Layout patterns specific to this project type (e.g. dashboard grid vs marketing hero)
>
> **At the top of G1, always include:**
> ```
> ## 🔗 Inherits From
> GM1: `GM/GM1-[BrandName]-Styles.md` — all base tokens apply unless overridden below.
> ```

---

## 🎨 PHASE 1: NOTES INITIALIZATION

**Action:** Create `NOTES/General Styles/`

1. **Check G0:** Read `GENERAL/G0-Idea.md` to understand the project vibe.
2. **Create Structure:**
   ```
   NOTES/General Styles/
   ├── ORIGINAL IDEA/
   │   └── N1-General Styles.md  (User's style preferences)
   ├── AUDIT/
   ├── UI/
   └── EXAMPLES/
   ```

3. **Analysis Prompt:**
   Ask user: "I've created the folder. Please update N1 with your style preferences. Shall I scan existing Notes for component requirements?"

---

## 👁️ PHASE 2: THE AUDIT (Requirements Gathering)

**Trigger:** User confirms N1 is ready.

**Cognitive Steps:**
1. **Global Scan:** Read `N1` and any existing `UIDR` files.
2. **Conflict Detection:** Check if N1 contradicts `G0-Idea.md`.

**Action:** Create `NOTES/General Styles/AUDIT/Init-Questions.md`.
- **Content:** List all contradictions or clarifications needed.
  *   "G0 says 'Playful', but N1 says 'Corporate'. Clarify?"
  *   "AI has to ask about design of all of the components here is the list:"
  *   "Design questions: lets say user havent clarified something, AI has to ask for it."
  *   "AI has to ask about design of all of the components here is the list:
``` 
 Button
Card
Input
Modal
Nav
Header
Footer
Table
List
Grid
Avatar
Badge
Tag
Checkbox
Radio
Switch
Toggle
Dropdown
Menu
Alert
Toast
Tooltip
Dialog
Spinner
Loader
Sidebar
Container
Wrapper
Row
Form Components:

Select
TextArea
Label
FormGroup
FileUpload
DatePicker
TimePicker
SearchBar
Navigation Components:

Breadcrumb
Tabs
Pagination
Stepper
Layout Variations:

Drawer
Popover
Accordion
Carousel
Data Entry:

Combobox
MultiSelect
Slider
RangeSlider
Status/Feedback Extensions:

SnackBar
Banner
Message
Notification
ProgressBar
Rating
Skeleton
Content Components:

Link
Divider
Icon
Image
Code
Blockquote
Enterprise/Complex:

Calendar
TimePicker
Kanban
Tree
Chart
Graph
Map
Commerce/Specific:

ProductCard
PricingCard
CartItem
WishlistItem
ReviewCard
RatingComponent
Social/Engagement:

SocialLinks
ShareButtons
LikeButton
FollowButton
Comment
Media:

VideoPlayer
AudioPlayer
Lightbox
Gallery
ImageCarousel
Utility:

Skeleton
Loader
EmptyState
ErrorBoundary
Tooltip
ContextMenu

```

**Hold:** Wait for user to answer inside the file.
**COmprehensive** There must not be just 2 questions and forget, there must be alot of it, its the general style goddamit.
**Use only those components taht you 100% think gonna be in our codebase by IDEA**

---

## 🖼️ PHASE 2B: HTML VISUAL AUDIT

**Trigger:** Immediately after creating `AUDIT/Init-Questions.md` in Phase 2. Created ALONGSIDE it — not instead of it.

**Rule:** Markdown is useless for visual decisions. For anything where "describe it" is inferior to "show it", create a companion HTML file. The HTML audit goes FIRST — the markdown file gets populated with answers from it.

**Action:** Create `NOTES/General Styles/AUDIT/Visual-Audit.html` alongside the markdown.

**Structure:**
- One `<section>` per visual question
- Each section renders the actual options as live CSS components side-by-side (not described — rendered)
- Dark/light toggle if the project supports both themes
- Accent color swapper if the project uses a user-swappable accent
- **Each option is a clickable card.** Clicking it marks it as selected (accent border + checkmark). Selected state persists via JS `localStorage` so refreshing the page keeps selections.
- A **"Copy Answers"** button at the top generates a plain-text summary of all selections (e.g. `Q1: Option B — Rounded buttons`) that the user can paste back into chat or into the markdown file.
- User never has to type descriptions — they click, then copy the output.

**What goes in the HTML (visual questions only):**
- Button styles: shape, weight, hover treatment, pressed state
- Input fields: outlined vs filled vs underline, focus ring style
- Card depth: flat vs 3D shadow vs glass
- Border radius: sharp vs subtle vs rounded vs pill — rendered at real sizes
- Typography: actual fonts at actual sizes, not font names in a list
- Modal styles: center dialog vs bottom sheet, backdrop treatment
- List items: separator lines vs card-based vs floating
- Any other component where a picture beats a paragraph

**What stays in markdown only (non-visual):**
- Behavior questions ("What happens on swipe right?")
- Architecture decisions ("Persist to local DB?")
- Content/copy questions

**After user answers the HTML audit:**
- Parse answers and populate `Init-Questions.md` with confirmed decisions
- Update N1 with a Round 2 section containing all component decisions locked in

**STOP:** Present both file paths. Wait for user to review the HTML first, then confirm markdown.

---

## 🎨 PHASE 3: THE SYNTHESIS (The HTML Canvas)

**Trigger:** User says "Audit Complete".

**Action:** Create `NOTES/General Styles/UI/Design-System.html`.

**Logic:** Combine N1 + Audit Answers + Global Needs.

**HTML Structure Architecture (The "Modular Gallery"):**
*The goal is **Extraction Ready** code. We are not just making a picture; we are making a library.*

1.  **Single File Containment:** Use internal `<style>` tags so the file works instantly in any browser.
2.  **Section Isolation (The "Copy-Paste" Rule):**
    - Every component group (e.g., "Buttons") must be wrapped in a `<section id="buttons" class="component-group">`.
    - Use clear comment blocks: `<!-- === BUTTONS START === -->` / `<!-- === BUTTONS END === -->`.
    - CSS for specific components should be grouped or named clearly (e.g., `.btn-primary`, `.btn-secondary`) to allow easy finding.
3.  **State Visualization:**
    - Do NOT rely only on `:hover` or `:focus`.
    - Create "Forced State" elements so the user sees the style immediately without interaction.
    - Example: Render a button with `.hover` class applied alongside the normal button.
4.  **The "Kitchen Sink" Layout:**
    - **Sidebar Nav:** Fixed position table of contents to jump to sections.
    - **Main Canvas:** Vertical scroll of all components.
    - **Dark/xLight Toggle:** A JS toggle to switch `body` class to test themes instantly.

**Content Requirements:**
- **Global Layout:** Navbar, Footer, Sidebar (responsive behavior).
- **Typography:** Headings (H1-H6), Body, Captions, Labels.
- **Color Palette:** Primary, Secondary, Backgrounds, Surfaces, Alerts.
- **Core Components:** Buttons (all variants), Inputs, Cards, Modals.
- **Reusable Sections (Organisms):** Generic Hero, CTA, Feature Grids (for marketing).
- **Complex Capabilities:** (e.g., if F2 needs charts, include chart style placeholders).

---

## 📖 PHASE 4: DOCUMENTATION FINALIZATION

**Trigger:** User approves the HTML Design System.

**Action:** Rewrite `NOTES/General Styles/UI/UIDR-General Styles.md`

**Content:**
- **Methodology:** (e.g., Atomic Design, mobile-first).
- **Token Dictionary:** Define CSS variable names (`--color-primary`, `--spacing-md`).
- **Component Catalog:** List of all components defined in Phase 2 with usage rules.
- **Layout Rules:** Z-index layers, container widths, breakpoint definitions.

---

## 🚀 PHASE 5: CONVERSION TO FEATURES (F1)

**Trigger:** "Convert to F1" or "Initialize F1"

**Step 1: Create G-File (The Law)**
- **Create:** `GENERAL/G1-Styles.md`.
- **Content:** Copy the final `UIDR-General Styles.md`. This is now the Source of Truth.
- **Action:** Move `Design-System.html` to `GENERAL/G1-Design-System.html`.

**Step 2: Initialize Folder (The Tool)**
- Create `FEATURES/F1 - General Styles/`.
- Check conflicts (F1 slot must be free).

**Step 3: Create F1-Doc.md**
- **Type:** Technical Build Spec.
- **Content:**
  - **Vision:** Link to `GENERAL/G1-Styles.md` (The source of truth).
  - Tech Stack (Tailwind/Schadcn/CSS Modules).
  - Theme Configuration (font families, radius, animations).
  - Directory Structure (where components live).
  - Global Layout implementation plan.

**Step 4: Create F1-Progress.md**
- **CRITICAL:** NO Page-specific todos (P1, P2...).
- **Structure:**
  ```markdown
  # 📊 F1 - Design System Progress
  
  ## 🏗️ Phase 1: Foundation Setup
  - [ ] Install dependencies (fonts, icon libs, utils)
  - [ ] Configure Tailwind/Theme variables
  - [ ] Set up global CSS (reset, base styles)
  - [ ] Implement Global Layout (Layout.tsx, Navbar, Footer)
  
  ## 🧩 Phase 2: Core Primitives (Atoms)
  - [ ] Build Typography components
  - [ ] Build Button variants
  - [ ] Build Input/Form elements
  - [ ] Build Cards/Containers
  
  ## 🧱 Phase 3: Complex Components (Molecules)
  - [ ] Build [Component identified in Phase 2 scan]
  - [ ] Build [Component identified in Phase 2 scan]
  
  ## 🛡️ Phase 4: Integration Check
  - [ ] Verify responsiveness of global layout
  - [ ] Test dark/light mode switching
  - [ ] Accessibility Audit (Contrast, Focus states)
  ```

---

## 🛑 EXECUTION CONSTRAINTS

1. **ALWAYS F1:** This protocol ONLY targets F1.
2. **G1 IS LAW:** `F1-Doc.md` must link to `GENERAL/G1-Styles.md` as the visual authority.
3. **NO PAGE TODOS:** This feature builds *tools* for pages, not the pages themselves.
4. **GLOBAL AWARENESS:** Must analyze other features to ensure the design system isn't missing critical pieces.
