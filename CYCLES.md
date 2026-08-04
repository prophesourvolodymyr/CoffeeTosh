# CYCLES.md — Coffeetosh

Feature planning and implementation are tracked below; human review remains explicit.

## Cycle 0 — Documentation
- [x] Install the F-Cycle project structure with `projinit`
- [x] Migrate the project vision, architecture, and style documents into `genesis/` and `STYLES.md`
- [x] Migrate existing feature documentation into `features/F01` through `features/F04`
- [x] Move legacy notes into `genesis/legacy-notes/`
- [x] Move obsolete project-management and scratch folders into `junk/legacy/`
- [x] Create the feature index and feature-level DOCKS.md files

## Cycle 1 — Product Direction
- [x] Define F05 — iOS Host Platform (Mac host behavior, pairing, device trust, and session safety)
- [x] Define F06 — iOS App UI/UX and basic connections
- [x] Define F07 — Mac View on iPhone
- [x] Define F08 — iOS UI/UX improvements and connection testing
- [ ] Review and approve the F05-F08 feature direction with the user

## Cycle 2 — F05 Mac Host Surface
- [x] Add Remote Control entry to menu-bar Settings
- [x] Add Remote Control entry to Dashboard Settings
- [x] Add host state, pairing invitation, trust persistence, and approval boundary
- [x] Add paired-device management and remote-session safety indicator
- [x] Add first-class Remote Control Dashboard tab with Add Device flow
- [x] Add Mac host card showing the currently connected iOS device
- [x] Bundle official Apple iPhone, iPad, and MacBook artwork with platform-based selection
- [x] Add host pairing, platform persistence, and Remote Control UI smoke coverage
- [ ] Connect live transport and F06 iPhone pairing requests
- [ ] Human review the F05 Mac host surface
