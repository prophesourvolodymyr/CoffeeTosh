# F06 - iOS App UI/UX And Basic Connections

F06 introduces the iPhone app experience and the first connection between the iPhone and Coffeetosh on a Mac.

The app should feel like Coffeetosh immediately. It uses the Mac app's Warm Amber and Espresso personality, then expresses that personality through a calm iPhone layout with depth, translucency, and touch-responsive Liquid Glass.

## What We Build

- The first iPhone launch experience.
- An immediate connected-device list as the main entry screen.
- Multiple Mac devices in one account or local device list.
- MacBook and Mac mini cards with real device images.
- Pairing, approval, connection, disconnection, and reconnection flows.
- A clear path from device selection into the Mac view.
- Empty, loading, unavailable, offline, and permission states.
- A consistent iOS visual language for iOS 26 and older supported iOS versions.

## First Launch

When the user opens the iPhone app, the connected-device list appears immediately. The user should not be forced through a long introduction before seeing whether a Mac is available.

The first screen contains:

- A compact Coffeetosh header.
- A short line such as "Choose a Mac to connect.".
- The device cards.
- A visible Add Mac action.
- A quiet privacy note explaining that a Mac must approve the first connection.

If no Mac has been added, the empty screen shows one friendly explanation and one main action. It should not look like an error or an unfinished dashboard.

## Device Cards

Every card represents one Mac and is visually easy to recognize before the user reads the text.

Each card includes:

- A real PNG image of the connected device.
- The device name chosen by the user.
- The model family, such as MacBook Pro or Mac mini.
- A small connection state.
- A Coffeetosh session state when relevant.
- The last known activity time when the Mac is offline.
- A clear Connect action when the Mac is ready.

MacBook cards use the correct MacBook image when the model is known. Mac mini cards use a real Mac mini image. The app must not use a generic laptop silhouette when a real project asset is available.

The device image is decorative but important. It gives the device list personality and helps the user choose the correct Mac when several devices are present.

Cards must remain readable when the user has many Macs. The image should reduce in size before the text becomes cramped.

## Device List States

| State | What the user sees | Behavior |
|---|---|---|
| Loading | Warm, quiet placeholder cards | The list settles into place when devices are found |
| Empty | Coffeetosh mark, explanation, Add Mac button | The user starts pairing |
| Ready | Real device cards with Connect actions | Tapping a card opens its connection flow |
| Connecting | Selected card enlarges slightly and shows a calm progress state | Repeated taps do nothing |
| Connected | Card shows an active connection and a View Mac action | The user enters the remote view |
| Offline | Card remains visible with a muted state | The user can retry or remove it |
| Mac asleep | Card says the Mac is asleep or unavailable | The user can wait or return later |
| Permission needed | Card explains that the Mac needs approval | The user can retry after approving on the Mac |
| Connection rejected | Card returns to its ready state with a short explanation | The user can try again |
| Connection lost | Card stays visible and changes to Reconnecting | The app retries gently without trapping the user |
| Removed | Card leaves after confirmation | The device can be paired again |

## Add Mac Flow

The Add Mac action opens a focused pairing screen. It offers:

- Scan the Mac's pairing image.
- Choose a Mac found nearby.
- Enter a short pairing phrase if scanning is not possible.

The screen explains each step in plain language. It never asks the user to understand networking terms.

After the phone finds a Mac, it shows:

- The Mac's real device image.
- The Mac name.
- The request to connect.
- A short reminder that the Mac must approve the request.

After approval, the Mac card appears in the device list with a clear success moment. The user should be able to connect immediately without returning through several screens.

## Navigation

The first version has three primary places:

- Devices: the connected Mac list.
- Mac View: the live view of the selected Mac.
- App Controls: Coffeetosh controls for the selected Mac.

The user should always know which Mac is selected. The selected Mac name stays available in the top bar or in the return path.

Leaving Mac View does not disconnect the Mac. It returns the user to the device list while keeping the connection available.

The app should never hide the device list behind a decorative welcome screen. The list is the home of the app.

## Liquid Glass Direction

On iOS 26, the app uses Apple's Liquid Glass language for navigation surfaces, floating controls, toolbars, sheets, and interactive buttons.

On iOS 13 through iOS 18, the app uses the visual behavior of LiquidGlassKit so the older experience still has translucent depth, soft reflections, and touch-responsive surfaces.

The two versions must feel like the same Coffeetosh app:

- Warm Amber remains the action color.
- Espresso Dark remains the main mood.
- Text hierarchy remains the same.
- Glass is used to create depth, not to cover every surface.
- Cards, controls, and navigation surfaces may use glass.
- Large reading areas remain calm and clear.
- Glass must never reduce text contrast.

Interactive glass reacts only where the user can act. A static device image should not look like a button unless the entire card is tappable.

When glass elements appear together, they feel like one family. Nearby controls may visually join, while unrelated controls remain separate.

## Device Images And Personalization

The app starts with real project-provided PNG images for supported Mac families. The images should be consistent in angle, lighting, and visual weight.

The user may rename a Mac. Renaming changes the card title but does not change the model image.

If the exact Mac model is unknown, the app uses the closest honest family image and says the family name instead of pretending to know the exact model.

## Motion And Touch Feel

- Device cards enter with a soft upward movement and a small fade.
- Selecting a card gives a short press response, then expands into connection progress.
- A successful connection lets the selected card visually lead into Mac View.
- A failed connection returns the card to its original place instead of throwing the user into an error page.
- Sheets rise from the bottom with a glass surface and a clear dismissal gesture.
- Reconnecting uses a slow breathing indicator, not a spinning emergency symbol.
- All movement remains understandable with Reduce Motion enabled.

## Dependencies

- F01 provides the Mac app's visual language and assets.
- F05 provides the Mac-side host and approval experience.
- F07 provides the connected Mac View.

## Reference

- `genesis/legacy-notes/4-NOTES/ISSUES.md` - original idea for immediate device selection, multiple Macs, real device images, and no Linux support in the first version.
- `features/F03-coffeetosh-ui/F3-Doc.md` - current Coffeetosh interaction and visual behavior.
- `STYLES.md` - Warm Amber, Espresso Dark, breathing room, and brand asset rules.
- [LiquidGlassKit](https://github.com/ThijsMussig/LiquidGlassKit) - visual reference for keeping the Liquid Glass experience available on older iOS versions.
