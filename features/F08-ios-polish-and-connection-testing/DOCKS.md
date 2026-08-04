# F08 - iOS UI/UX Improvements And Connection Testing

F08 is the refinement layer for the iPhone app and the Mac connection. It makes the experience feel finished, predictable, and comfortable before the feature is considered ready.

This feature is about the user's confidence. The user should always know which Mac is selected, whether the view is live, what a gesture will do, and whether a dangerous action has happened.

## What We Improve

- Visual consistency between the Mac app and iPhone app.
- The feel of Liquid Glass surfaces on iOS 26 and older supported iOS versions.
- Spacing, readability, touch sizes, and one-handed use.
- Connection speed feedback and reconnect behavior.
- Gesture recognition and accidental-action prevention.
- Keyboard placement and comfort.
- Focus mode clarity.
- Device list clarity with several Macs.
- Error, offline, locked, sleeping, and interrupted states.
- Accessibility, Reduce Motion, haptics, and dark/light appearance.

## Quality Bar

The experience is ready only when:

- A new user can pair a Mac without being told to understand network settings.
- The user can identify the correct Mac from the device image and name.
- The user can enter Mac View without losing context.
- A tap produces one predictable action.
- A drag never becomes an accidental click.
- Three-finger gestures do not trigger while the user is simply scrolling the Mac view.
- Four-finger controls never appear by surprise during normal interaction.
- The keyboard does not cover the important part of the Mac screen.
- A lost connection is obvious but not frightening.
- A failed action explains what happened and offers a useful next action.
- Stop and Shut Down cannot be triggered accidentally.
- The app remains usable with motion disabled and larger text enabled.

## Connection Journey To Test

The complete journey is tested from both sides:

1. Open the iPhone app and see the device list immediately.
2. Add a Mac.
3. Approve the phone on the Mac.
4. See the real device image and connected state.
5. Enter Mac View.
6. Tap, click, drag, scroll, and type.
7. Switch a workspace with three fingers.
8. Open the window overview.
9. Focus one window and return to the full desktop.
10. Open Coffeetosh controls.
11. Check the current Lid Closed session.
12. Stop or leave the session according to the chosen action.
13. Disconnect and reconnect.
14. Close and reopen the iPhone app.
15. Confirm that the Mac remains safe and the phone explains the current state.

## Connection Conditions

The experience must be checked under normal and difficult conditions:

- Mac and iPhone nearby on a strong connection.
- Mac and iPhone farther apart with slower response.
- The phone briefly loses connection.
- The Mac changes between Wi-Fi and another network.
- The Mac goes to sleep.
- The Mac wakes while the phone is still open.
- The Mac lid closes during an active Coffeetosh session.
- The Mac lid opens during an active Coffeetosh session.
- The Mac is locked.
- Coffeetosh is running with a timer.
- Coffeetosh is running indefinitely.
- The Coffeetosh Mac app is closed while the host remains available.
- The user quits the iPhone app and returns later.
- A second paired phone tries to connect while the first phone is active.
- Several Macs appear in the device list at the same time.

Every condition needs a visible state, a safe result, and a way back. A frozen frame without an explanation is not an acceptable state.

## Gesture Refinement

Each gesture is tuned until it feels intentional:

- One-finger touch is immediate and accurate.
- Two-finger scrolling is smooth and does not cause clicks.
- Pinch zoom stays centered on the user's fingers.
- Two-finger panning reaches the edge without losing the user's place.
- Three-finger workspace swipes need clear direction and distance.
- Three-finger window overview opens only after a deliberate downward movement.
- Four-finger controls require a distinct downward gesture.
- Gestures remain usable in both portrait and landscape.
- The user can always perform the same actions from visible controls.

The app should teach gestures lightly. A short hint can appear on first use, but the app must not interrupt the remote experience with a tutorial every time.

## Visual Refinement

The Mac and iPhone versions share:

- Warm Amber for active and primary actions.
- Espresso Dark as the main mood.
- Cream-colored primary text and softer secondary text.
- Generous spacing.
- Familiar Coffeetosh logo states.
- Quiet, purposeful motion.

The iPhone version adds Liquid Glass for depth, but it must not become a different brand. Glass is reserved for surfaces the user touches or opens. The Mac screen remains clear and dominant.

On iOS 26, native Liquid Glass behavior is preferred. On iOS 13 through iOS 18, LiquidGlassKit provides the visual reference for the same feeling. The final experience should be reviewed on both ranges so the older version does not feel like a broken fallback.

## Accessibility And Comfort Review

- Large text does not cut off device names or controls.
- VoiceOver can identify the Mac name, connection state, and every action.
- Haptics confirm actions but are never required to understand them.
- Reduce Motion removes large zooms and sliding transitions without removing state feedback.
- High contrast keeps text readable over every glass surface.
- One-handed use remains possible for the device list and main controls.
- The user can avoid motion-based focus.
- The screen does not flash during reconnecting or state changes.

## Completion Review

Before this feature is accepted, the user should be able to answer these questions at every moment:

- Which Mac am I controlling?
- Is the connection live?
- Is the whole desktop or one window in focus?
- What will this gesture do?
- Is the keyboard open?
- Is Coffeetosh currently keeping the Mac awake?
- What happens if I stop or shut down?
- How do I return to the device list?

If any answer is unclear, the screen needs another UI refinement pass.

## Dependencies

- F05 provides the Mac host states.
- F06 provides the iPhone device list and connection flow.
- F07 provides the remote Mac View and gestures.

## Reference

- `genesis/legacy-notes/4-NOTES/ISSUES.md` - original product idea and gesture list.
- `features/F01-design-system/DOCKS.md` - shared brand and visual direction.
- `features/F03-coffeetosh-ui/F3-Doc.md` - existing Mac app interaction language.
- `STYLES.md` - Warm Amber, Espresso Dark, spacing, and visual asset rules.
- [LiquidGlassKit](https://github.com/ThijsMussig/LiquidGlassKit) - reference for Liquid Glass on older iOS versions.
