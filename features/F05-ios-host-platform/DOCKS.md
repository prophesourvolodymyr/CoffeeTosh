# F05 — iOS Host Platform

F05 defines the Mac-side half of Coffeetosh Remote. The existing Coffeetosh Mac app is the trusted host that an iPhone or iPad can pair with, view, and control.

This document is a product and experience definition. It defines what the user sees, what every host state means, and which safety promises must hold. It does not choose the transport, screen-capture, authentication, persistence, or remote-input implementation.

## What We Build

- A `Remote Control` destination inside the existing Mac Settings experience.
- A first-class `Remote Control` tab in the Dashboard sidebar, not only a nested Settings row.
- An `Add Device` action that starts the Mac-side pairing flow from that tab.
- A Mac host card showing this Mac's name, host model artwork, host state, and the iOS device currently connected to it.
- A plain-language explanation that this Mac can be viewed and controlled from an approved iPhone or iPad.
- A first-time pairing flow using a temporary QR code and a human-readable confirmation phrase.
- Explicit Mac approval before an iOS device becomes trusted or receives a remote view.
- A paired iOS-device list with real device artwork selected from its platform and model family, chosen name, connection state, and last-connected time.
- Actions to approve, reconnect, disconnect, rename, and remove paired iOS devices.
- Host states for setup, pairing, approval, readiness, connection, pause, permission, rejection, removal, and unavailability.
- A persistent but non-blocking indication whenever an iOS device is viewing or controlling the Mac.
- A Mac-side action that ends remote viewing without stopping Coffeetosh.
- Mac-side Coffeetosh controls that remain available while an iOS device is connected.
- Explicit handling for locked, sleeping, shutting-down, protected-screen, and Lid Closed conditions.

## Ownership Boundary

F05 owns the Mac host surface, trust approval, paired-device management, host availability, active-session visibility, and Mac-side session termination.

F06 owns the iPhone pairing entry point and iPhone-side device list. F07 owns the live Mac view and touch/gesture experience after a host session is available. F05 supplies the authority and state that those features consume; it does not redefine their iPhone navigation or remote-view gestures.

Ending a remote session is not the same as stopping a Coffeetosh session. A host-session end must leave Keep Awake or Lid Closed mode unchanged unless the user separately confirms a Coffeetosh action.

## Architecture

### Surface hierarchy

```text
Dashboard
└── Remote Control (first-class sidebar tab)
    ├── Header
    │   ├── Remote Control title and explanation
    │   └── Add Device action
    ├── This Mac
    │   ├── Mac name and MacBook artwork
    │   ├── host state
    │   ├── currently connected iOS device
    │   └── End Remote Viewing
    ├── Add Device
    │   ├── temporary QR code
    │   ├── confirmation phrase
    │   ├── waiting state
    │   └── approval request with real device artwork
    └── Devices connected to this Mac
        ├── iPhone/iPad artwork selected by platform
        ├── chosen name, model, and connection state
        ├── rename, disconnect, and remove actions
        └── remove-trust confirmation

Existing Mac Settings
└── Remote Control
    └── compact compatibility route into the same host state
```

The Dashboard tab is the primary destination because it has enough space to show the Mac host and device relationship at a glance. The existing Settings row remains a secondary route into the same store and pairing state. Pairing expands from `Add Device` within the Dashboard context; it is not an unrelated utility window.

### Product state model

The host keeps four concepts visibly distinct:

1. **Host availability** — whether this Mac can currently provide a remote view.
2. **Pairing session** — the temporary invitation currently shown by the Mac.
3. **Paired device** — an iPhone or iPad trusted by this Mac, whether connected or not.
4. **Remote session** — the one currently active viewing/control connection.

Approval creates trust; it does not silently start remote control. An iOS device must make a separate connection request after pairing, and the Mac must never approve that request implicitly.

Only one iOS device may control the Mac in the first version. Other trusted devices stay visible in the list and cannot silently take over an active remote session. A new device request never interrupts or replaces the current controller.

## Entry Point And Visual Composition

The primary Remote Control tab uses the existing Dashboard shell, Espresso Dark background, Warm Amber accent, typography, spacing, corner radii, and breathing room from F01 and F03. The Settings row remains a compact secondary route into the same experience.

The first Dashboard screen contains:

- The title `Remote Control` and a plain explanation that this Mac can be viewed from an approved iPhone or iPad.
- A real MacBook image and the Mac host name.
- The current host status in words, not only color or an icon.
- A visible `Connected to` line naming the iOS device currently viewing the Mac, or an explicit no-device state.
- A primary `Add Device` action.
- A device list with real iPhone or iPad artwork selected by platform and model family.
- A quiet privacy statement: remote viewing begins only after the user approves the connection.

The host summary remains readable when there are no paired devices, when the host is unavailable, and when a remote session is active. Status color supports the label; it never carries the meaning alone.

## Host States

| State | What the Mac app shows | What the user can do | Safety meaning |
|---|---|---|---|
| Not set up | Remote Control explanation, Mac host card, and no-device empty state | Choose Add Device or read the explanation | No iOS device is trusted and no remote view is possible |
| Waiting for device | Large calm pairing panel, QR code, confirmation phrase, and waiting message | Cancel pairing or leave the tab | The temporary invitation exists; the Mac is not visible or controllable yet |
| Pairing request | Requesting device name, real device artwork, phrase comparison, and `Allow` / `Not Now` actions | Explicitly allow or reject | The request has no access until Allow is chosen |
| Ready | Mac host card, paired-device rows, and a calm ready indicator | Add a device, rename, disconnect an inactive connection, or remove trust | The host is available and no device is controlling it |
| Connected | Mac host card names the connected iOS device, with session duration, remote indicator, and End Remote Viewing | End remote viewing or open device management | The named device may view/control; the Mac makes this visible everywhere relevant |
| Paused | Trusted device remains listed with a paused/unavailable explanation | Wait, retry/reconnect, open management, or end the session | The host does not send stale frames or accept misleading input |
| Permission needed | Plain explanation of the missing Mac permission and the affected capability | Open the relevant Mac permission screen or cancel | No remote session begins while required permission is unresolved |
| Host unavailable | Specific reason such as locked, sleeping, shutting down, or protected system screen | Read the reason, retry, or return to Settings | The Mac is not presented as live; a frozen image is never treated as current |
| Rejected | Short explanation that the last request was denied and a ready-to-try-again state | Start a new pairing | The denied device is not trusted and receives no remote access |
| Disconnected (trust retained) | The paired row stays in place and changes to Disconnected with last-connected time | Reconnect, rename, disconnect, or remove trust | The session ended, but pairing remains valid |
| Removed | The removed device leaves the trusted list after confirmation and a short result message | Start a new pairing if the device should return | The device is no longer trusted and must pair again |

The state label, supporting sentence, and available actions must agree. The Mac must not show `Connected` while the device is paused, locked out, or waiting for permission.

## Pairing Flow

### Start and waiting

1. The user chooses `Add Device` from the Remote Control tab.
2. The pairing panel grows from that action inside the Dashboard context.
3. The Mac presents a large, quiet QR code and a short human-readable confirmation phrase.
4. The instructions say to open Coffeetosh Remote on the iPhone or iPad and choose this Mac.
5. The privacy statement remains visible: the Mac is not being viewed or controlled before approval.
6. The Mac shows a waiting state until a valid iOS-device request arrives or the user cancels.

The QR code and phrase belong only to this temporary pairing session. Leaving the pairing surface, using Cancel, completing the request, or expiration invalidates them. The previous host state is restored, and the user may start a fresh pairing at any time.

### Approval request

When an iOS device requests connection through the active pairing session, the Mac replaces the waiting message with:

- The device's chosen name.
- The real iPhone or iPad image selected from the request's platform.
- The model family and confirmation phrase for a human cross-check.
- A plain statement that approval will trust this device.
- `Allow` and `Not Now` actions with equal clarity and no preselected approval.

The Mac never shows a live Mac view, sends remote input, or describes the device as connected before `Allow`. A request that arrives without a valid active pairing session does not create trust or start a session; the user is directed to begin pairing again.

Only one approval request is presented at a time. Additional requests cannot replace the visible request or bypass the user's decision.

### Result

After `Allow`:

1. The temporary pairing presentation expires.
2. Both devices show the same paired/confirmed result.
3. The Mac returns to the Remote Control tab.
4. The new device row grows into the connected-devices list.
5. The device is trusted but remote viewing does not start without an explicit connection request.

After `Not Now`:

- No trust is created.
- The Mac shows the Rejected result briefly, then returns to the previous ready or not-set-up state.
- The device can try again through a new pairing session.

If the Mac app closes, the Settings surface is dismissed, the system enters an unavailable state, or the user navigates away, the pairing invitation expires rather than remaining valid in the background.

## Paired Device Management

### Device row

Each paired iOS-device row contains:

- The user's chosen display name.
- A real iPhone or iPad image selected by platform and model family when known; otherwise an honest, accessible fallback.
- Current connection state in text.
- Last-connected time.
- A small remote-control indicator when that device is active.
- An explicit action area for rename, disconnect, and remove.

The image helps recognition but is not the trust decision. The name, state, and actions remain understandable without the image.

### Rename

Rename changes only the Mac-side display name. It does not change the device identity, pairing trust, or iOS-side name. The edit preserves the old name on Cancel, rejects an empty result by keeping the previous name, and confirms the new name in the row. Duplicate names are allowed; the device image and connection metadata remain available to distinguish them.

### Disconnect and remove

Disconnect ends the current remote session while retaining pairing trust. The row remains visible and becomes Disconnected rather than disappearing.

Remove changes trust and therefore requires a confirmation that names the device and says it must pair again before connecting. Removing an active device also states that its current remote session will end; it never ends silently. After confirmation, the device leaves the trusted list and cannot reconnect without a new pairing flow.

While another device is Connected, other paired rows remain visible but show that the host is occupied. They cannot silently take control. The current controller must be ended first.

## Remote Session Safety

Remote control is always visible on the Mac:

- The menu-bar item changes to show an active remote connection.
- The Remote Control tab names the connected iOS device.
- A small, non-blocking remote indicator remains available while the session is active.
- End Remote Viewing is available from the Mac without navigating through destructive Coffeetosh controls.

Ending remote viewing:

1. Clearly identifies the device that will be disconnected.
2. Ends the remote session on both sides.
3. Leaves Coffeetosh Keep Awake or Lid Closed state unchanged.
4. Leaves the device paired and visible as Disconnected.

Remote control never starts merely because Coffeetosh launches. Pairing and explicit approval are required every time a new device becomes trusted. Existing trust may support reconnection, but it must still produce a visible connection state and may not bypass the one-controller rule.

When the Mac is locked, sleeping, shutting down, or showing a protected system screen, the host reports unavailable or locked status. It does not stream a misleading frozen frame, accept remote input that cannot be applied, or claim that the device is controlling the Mac. Recovery returns through a clear retry/reconnect action.

## Relationship With Lid Closed Mode

The host and the connected iOS device use the existing F02 session truth rather than inventing a second Coffeetosh timer.

| Mac/Coffeetosh condition | Remote experience | Required confirmation or restriction |
|---|---|---|
| Lid Closed inactive and Mac available | The connected iOS device may view and control the available Mac | No Coffeetosh action is implied by connecting |
| Lid Closed active | The iOS device shows the active mode and remaining time when available | Session controls remain separate from End Remote Viewing |
| iOS device chooses Stop Lid Closed session | The iOS device shows the existing session ending result | Intentional confirmation explains that normal Mac sleep behavior returns |
| iOS device chooses Shut Down | The iOS device shows a separate shutdown confirmation | Confirmation explains that the Coffeetosh session ends before shutdown; it is not combined with Stop |
| Lid opens during an active Lid Closed session | The iOS device shows that the Mac is locked/unavailable | No touch input appears successful while the Mac is protected |
| Mac sleeps, shuts down, or becomes protected | The remote view enters Paused or Host unavailable with a reason | Retry/reconnect and disconnect remain available; stale content is not presented as live |

Stopping a Lid Closed session and ending remote viewing are separate actions on both the Mac and iOS device. A remote disconnect must never restore normal sleep behavior by accident.

## Motion And Transitions

All motion inherits the existing F01/F03 motion language and uses no feature-specific visual effect that competes with the Mac app. Motion remains interruptible and has a reduced-motion alternative.

| Trigger | Full-motion behavior | Reduced-motion behavior |
|---|---|---|
| Enter Remote Control | The Dashboard tab slides in with the existing gentle navigation motion and keeps the host card as the visual anchor | Replace the slide with an immediate content change and preserve focus |
| Choose Add Device | The pairing panel expands from the Add Device action while the Mac host card stays stable | Replace expansion with a direct state change and clear heading update |
| Press Allow or Not Now | The selected action gives a short physical press response, then resolves to the result state | Use a brief highlight or immediate result state without scale movement |
| New device becomes paired | The new row grows into place and receives a soft Warm Amber confirmation glow | Insert the row directly with a static confirmation label |
| Device disconnects | The row stays in place and crossfades to its new state | Update the state label without crossfade |
| Remote activity | The active indicator uses a slow breathing pulse and never flashes aggressively | Keep a steady indicator and text label |
| Remove after confirmation | The row leaves only after trust removal succeeds, with a restrained collapse and result message | Remove the row directly after success and keep the result message |
| Error, permission, or unavailable transition | Supporting content changes without throwing the user into an unrelated error screen | Replace content directly while preserving the same action order |

No animation may imply approval, connection, or successful control before that state is true. Outside click, back navigation, Cancel, and system interruption resolve to a real state; they do not leave an orphaned pairing surface.

## Accessibility, Input, And Responsive Behavior

- VoiceOver announces the host state, paired-device name, platform/model, current connection state, last-connected time, and every action with a meaningful label.
- The QR code always has the confirmation phrase as readable text; the phrase is not the only way to complete pairing.
- Warm Amber, muted text, and indicator pulses never carry state meaning without a textual label.
- Keyboard focus begins on the Remote Control heading or the first available primary action and follows the visible order.
- Escape and the Back action leave the pairing surface safely; they never approve a request. A visible `Not Now` action remains available for an approval request.
- Rename supports keyboard entry, visible Cancel, and an explicit Save/Done action.
- Touch targets retain the existing Settings minimum and breathing room. Layout uses available space rather than fixed screen coordinates.
- The pairing surface remains readable at supported macOS text sizes and adapts when the Settings presentation is resized.
- The device artwork is decorative unless the row action makes the whole row interactive; its accessibility label describes the device when needed.
- Reduce Motion removes expansion, row growth, glow movement, and pulses while preserving state order and feedback.
- Permission, locked, sleeping, and protected-screen messages state what the user can do next. They never rely on an unexplained spinner.

## Files And Ownership

This feature's product behavior is implemented across the Mac Settings surfaces and the shared host state boundary. The expected ownership is:

- `features/F05-ios-host-platform/DOCKS.md` — product behavior and host-side source of truth.
- `CoffeeTosh/CoffeeTosh/SettingsView.swift` — existing Settings surface that receives the Remote Control destination and its paired-device management UI.
- `CoffeeTosh/CoffeeTosh/RemoteControlStore.swift` — pairing invitation, trust state, device persistence, and remote-session state boundary.
- `CoffeeTosh/CoffeeTosh/RemoteControlView.swift` — host summary, pairing surface, approval request, device management, and session safety UI.
- `CoffeeTosh/CoffeeTosh/DashboardView.swift` — Dashboard sidebar navigation and Settings compatibility route.
- `CoffeeTosh/CoffeeTosh/RemoteDevicesView.swift` — first-class Remote Control tab, Mac host card, Add Device panel, and connected-device list.
- `CoffeeTosh/CoffeeTosh/RemoteDeviceArtwork.swift` — platform-based selection of bundled real device images.
- `CoffeeTosh/CoffeeTosh/RemotePairingQRCode.swift` — shared QR renderer for the full-size Add Device panel.
- `CoffeeTosh/CoffeeTosh/ContentView.swift` — existing Settings entry and slide transition that must remain consistent.
- `CoffeeTosh/CoffeeTosh/StatusBarManager.swift` — menu-bar remote-activity indication alongside existing Coffeetosh status.
- `CoffeeTosh/CoffeeTosh/CoffeeToshApp.swift` — app lifecycle and host availability integration.
- `CoffeeTosh/CoffeeTosh/Assets.xcassets/` — approved Coffeetosh mark and any supported device imagery; assets follow F01 rather than being recreated inline.
- `CoffeeTosh/CoffeeTosh/Assets.xcassets/device-iphone-17.imageset/` — official Apple iPhone artwork.
- `CoffeeTosh/CoffeeTosh/Assets.xcassets/device-ipad-pro-m5.imageset/` — official Apple iPad Pro artwork.
- `CoffeeTosh/CoffeeTosh/Assets.xcassets/device-macbook-pro-m5.imageset/` — official Apple MacBook Pro artwork for the host card.
- `CoffeeTosh/CoffeeToshTests/CoffeeToshTests.swift` — pairing approval, trust persistence, and remote-session termination behavior tests.
- `CoffeeTosh/CoffeeToshUITests/CoffeeToshUITests.swift` — Dashboard Remote Control tab launch and host-surface smoke test.
- `features/F06-ios-connection-ui/DOCKS.md` — iPhone-side pairing and device-list contract consumed by the host flow.
- `features/F02-coffeetosh-system/F2-Doc.md` — existing session, lid, lock, and restoration behavior that remote controls must observe.

The final transport and storage files are intentionally not prescribed by this product document. Any implementation must preserve the state distinctions, approval gate, one-controller rule, and session-safety behavior above.

## Dependencies

- F01 — visual language, brand assets, colors, typography, spacing, radii, and motion conventions.
- F02 — existing Keep Awake, Lid Closed, lid-open lock, timer, and system-restoration truth.
- F03 — existing Mac Settings entry, navigation, layout, and Mac app interaction language.
- F06 — iPhone-side pairing request, confirmation, paired-device list, and reconnection experience.

F07 depends on F05 for the trusted host and active-session state. F08 depends on F05 for connection-state and interruption cases that require end-to-end testing.

## Reference

- `../../genesis/legacy-notes/4-NOTES/ISSUES.md` — original idea for controlling the whole Mac screen from an iPhone and the gesture-driven remote experience.
- `../../genesis/INITIAL IDEA.md` — Coffeetosh purpose, macOS boundary, and safety principles.
- `../F03-coffeetosh-ui/F3-Doc.md` — current Mac UI behavior and visual direction.
- `../../STYLES.md` — Warm Amber, Espresso Dark, breathing room, radii, and approved brand assets.
- Apple Newsroom iPhone 17 artwork: `https://www.apple.com/newsroom/images/2025/09/apple-debuts-iphone-17/article/Apple-iPhone-17-hero-250909_inline.jpg.large.jpg`
- Apple Newsroom iPad Pro M5 artwork: `https://www.apple.com/newsroom/images/2025/10/apple-introduces-the-powerful-new-ipad-pro-with-the-m5-chip/article/Apple-iPad-Pro-hero-251015_big.jpg.large.jpg`
- Apple Newsroom MacBook Pro M5 artwork: `https://www.apple.com/newsroom/images/2026/03/apple-introduces-macbook-pro-with-all-new-m5-pro-and-m5-max/article/Apple-MacBook-Pro-M5-Pro-and-M5-Max-Capture-One-260303_big.jpg.large.jpg`
