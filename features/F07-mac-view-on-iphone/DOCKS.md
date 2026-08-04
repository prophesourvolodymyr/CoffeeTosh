# F07 - Mac View On iPhone

F07 is the main remote experience: the user sees the Mac screen on the iPhone and navigates it with touch, gestures, a compact keyboard, and a small set of Coffeetosh controls.

The goal is not to create a list of Mac commands. The goal is to make the iPhone feel like a small, direct window into the Mac.

## What We Build

- A live Mac screen that fills the iPhone as naturally as possible.
- Tap, click, drag, scroll, and pointer movement.
- Pinch-to-zoom and two-finger movement while zoomed.
- Focus mode for one Mac window.
- Three-finger workspace and window gestures.
- A compact floating keyboard.
- Four-finger access to Coffeetosh controls.
- Portrait and landscape viewing.
- Clear unavailable, reconnecting, locked, and interrupted states.

## Entering Mac View

When the user taps Connect on a Mac card:

1. The device card gives a short press response.
2. The screen transitions from the card into the Mac View.
3. The Mac image expands behind the interface instead of being replaced by a blank loading page.
4. A small connection status appears while the view becomes live.
5. Once the Mac is visible, controls fade back so the Mac screen has priority.

The first visible frame should feel intentional. If the connection takes time, the user sees the selected Mac image and a useful message rather than a black screen.

## Default View

The default view shows the whole Mac screen with the least amount of interface over it.

The screen contains:

- The Mac view as the main surface.
- A small top status area that can be revealed with a light tap.
- A subtle connection indicator.
- A discreet gesture hint the first time the user enters.
- A way to reveal the Coffeetosh controls without permanently covering the Mac.

The controls disappear after a short period of inactivity. A tap near the edge reveals them again. The Mac screen should never feel trapped inside a dashboard frame.

## Pointer And Touch

The iPhone screen acts as a touch surface for the Mac.

- A single tap moves the pointer to the chosen location and clicks.
- A press and hold begins a drag.
- Moving one finger moves the pointer without clicking when the user is in pointer mode.
- A two-finger movement scrolls the Mac content.
- A two-finger press and movement can pan the Mac view when zoomed.
- A short visual pointer ring confirms where the last click happened.
- The pointer ring is brief and quiet. It must not cover text or become a permanent cursor.

The user can choose between direct touch mode and trackpad-like pointer mode from the in-app controls. Direct touch is the default because it is easiest to understand on first use.

If the user touches a control while a gesture is being recognized, the app favors the gesture that has already clearly begun. It must not turn an intentional two-finger pan into two accidental clicks.

## Gesture System

The gesture language comes directly from the original Coffeetosh Remote idea. Every gesture has a visible result and a small optional teaching hint the first time it is used.

### Three-Finger Swipe Left Or Right

This moves between Mac workspaces.

- The gesture must travel far enough to feel intentional.
- A short directional preview appears while the swipe is happening.
- The Mac View moves with the gesture rather than waiting until the finger lifts.
- The final workspace settles with a short, confident movement.
- A failed or too-short swipe returns smoothly without changing workspace.

### Three-Finger Swipe Down

This opens the Mac's window overview.

- The Mac View slightly pulls back as the overview begins.
- The gesture feels like opening a larger space, not dragging the screen away.
- The user can tap a visible window to focus it.
- Swiping back up returns to the previous view.
- If the Mac cannot show the overview, the app gives a small explanation and leaves the user in the current view.

### Two-Finger Pinch

This zooms the Mac view.

- Pinching in makes text and controls larger.
- Pinching out returns toward the full-screen view.
- The zoom is centered on the place between the fingers.
- The app keeps the user's chosen point under their fingers instead of jumping to the center.
- A small zoom level indicator appears during the gesture and fades after release.

### Two-Finger Pan While Zoomed

When zoomed in, two fingers move around the Mac screen.

- The movement is direct and follows the fingers.
- The view has a soft edge resistance so the user knows when they reach the edge.
- Releasing the fingers lets the view settle without drifting.
- The user can still tap and drag inside the zoomed view.

### Four-Finger Swipe Down

This opens the Coffeetosh control surface.

- The Mac View stays visible behind the sheet.
- The sheet rises as a floating glass panel.
- The gesture never turns into a Mac window action.
- The sheet can be dismissed by swiping down, tapping outside, or using the close control.

## Compact Keyboard

The keyboard appears in the middle of the iPhone rather than permanently occupying the bottom edge.

It is a compact floating glass keyboard designed for short commands and navigation, not for replacing a full physical keyboard.

The keyboard includes:

- Letters and numbers in a tight but comfortable layout.
- A visible space key.
- Delete and return.
- Modifier keys such as Command, Option, Control, and Shift.
- Arrow keys.
- Escape.
- A way to dismiss the keyboard without losing the Mac View.

The keyboard opens when the user taps the keyboard control or uses a text-focused action. It can also be opened from the four-finger control sheet.

The keyboard must not hide the area where the user is typing. If the current Mac window is near the center, the keyboard moves slightly so the important area remains visible.

The keyboard has three states:

- Resting: compact, translucent, and easy to dismiss.
- Active: slightly brighter glass with clear key feedback.
- Expanded: temporarily larger when the user needs modifier keys or navigation keys.

Keys give immediate visual feedback and a light haptic response. The keyboard closes after an explicit dismiss action or when the user returns to direct touch mode. It does not disappear unexpectedly after every key.

## Focus Mode For One Window

The user can focus on one Mac window instead of seeing the whole desktop.

Focus begins when the user taps a window from the overview or uses the focus action on a visible window.

When focus mode begins:

- The chosen window grows toward the iPhone edges.
- Other windows recede into a soft, quiet background.
- The title of the focused window appears briefly.
- The app keeps the focused window aligned as the user moves around it.
- The user can return to the whole desktop with a clear exit action or a two-finger pinch outward.

The original idea describes moving the phone around to focus and explore one window. The experience should support this as a natural exploration mode: moving the phone can reveal more of the focused area, while two-finger pan remains available for users who prefer direct touch control.

The app must never make the user wonder whether the whole Mac or only one window is being controlled. Focus mode always shows a small Focused Window label when the controls are visible.

## Four-Finger Coffeetosh Controls

The control sheet belongs to Coffeetosh, not to the Mac desktop. It contains:

- Current Mac name and connection state.
- Current Coffeetosh session state.
- Lid Closed or Keep Awake status.
- Remaining session time when available.
- Stop session.
- Start or continue a Coffeetosh session when allowed.
- Low Power Mode toggle when supported by the current Mac state.
- Shut down Mac.
- Disconnect.
- Return to Mac View.

High-impact actions use separate confirmations:

- Stop Session explains that the Coffeetosh session will end and normal sleep behavior will return.
- Shut Down explains that all active work may stop and the Mac will power off.
- Disconnect explains that the phone will leave Mac View but will not shut down or stop Coffeetosh unless the user chose that action separately.

The controls sheet must not place Stop and Shut Down next to each other without visual separation. Destructive actions use red only for the destructive label or confirmation, never as the main product color.

## Screen Fit And Zoom

The Mac view tries to use the full iPhone display.

- The default view fills the available screen while keeping the Mac screen proportions understandable.
- Black bars are avoided when cropping can be done without hiding important content.
- A Fit option shows the whole Mac screen.
- A Fill option uses more of the iPhone display and allows the edges to be cropped.
- Zoom preserves the user's location when changing between Fit and Fill.
- Landscape gives the Mac view more horizontal room.
- Portrait remains useful for focused windows and quick controls.

The first version should improve readability through intelligent fitting and zooming rather than changing the Mac's own display settings behind the user's back.

## Remote View States

| State | What the user sees | Behavior |
|---|---|---|
| Connecting | Selected Mac image with a calm connection message | The user can cancel |
| Live | Full Mac view with minimal controls | Touch and gestures work |
| Reconnecting | Last view softens with a reconnecting message | The app retries without accepting confusing input |
| Slow connection | View remains visible with a subtle quality notice | The user may choose Fit, Fill, or disconnect |
| Mac locked | A clear locked message and no false touch feedback | The user waits or returns to device list |
| Mac asleep | Mac image and a sleep message | The user can wait or disconnect |
| Session stopped | Coffeetosh confirmation and return option | Remote view remains available if the Mac is still awake |
| Mac unavailable | Device name, reason, Retry, and Back | No blank permanent screen |
| Disconnected | A short explanation and Reconnect action | The user returns to the device card if desired |
| Permission interrupted | Plain explanation and a way to return to the Mac | The app does not pretend the view is live |

## Motion And Liquid Glass

- The Mac view transition feels like entering the selected device, not opening a generic page.
- Floating controls use Liquid Glass and respond gently to touch.
- The control sheet morphs from the four-finger gesture into a stable panel.
- The keyboard grows from its button into the center of the screen.
- Focus mode uses a smooth zoom and keeps the chosen window visually anchored.
- Workspace changes follow the three-finger movement with a physical, interruptible feel.
- Glass reflections and highlights remain restrained so the remote screen remains the visual priority.
- iOS 26 uses the native Liquid Glass character.
- Older supported iOS versions use the LiquidGlassKit reference direction so the experience remains visually related.
- Reduced Motion keeps the same hierarchy and state changes without large zooms or sliding surfaces.

## Accessibility And Comfort

- Every gesture has a visible alternative in the controls.
- The user can disable motion-based focus and use two-finger panning instead.
- Text remains readable at larger accessibility sizes.
- Controls have clear labels that do not rely on color alone.
- Haptic feedback can be disabled.
- The app warns before long remote sessions if the phone may become warm or low on battery.

## Dependencies

- F05 provides the trusted Mac host and remote session state.
- F06 provides device selection and the connection entry point.
- F08 refines and tests all gestures, connection behavior, and visual states.

## Reference

- `genesis/legacy-notes/4-NOTES/ISSUES.md` - original gesture, keyboard, zoom, focus, control-sheet, screen-fill, and Mac mini ideas.
- `features/F03-coffeetosh-ui/F3-Doc.md` - current Coffeetosh motion and visual language.
- `STYLES.md` - Warm Amber, Espresso Dark, breathing room, and asset rules.
- [LiquidGlassKit](https://github.com/ThijsMussig/LiquidGlassKit) - reference for the older-iOS glass experience.
