# 🧪 F2-Doc: Coffeetosh System Engine (Logic Spec)
**Date:** 2026-03-02
**Status:** 🟢 Active Structure
**Classification:** Logic Feature
**Source:** `NOTES/Coffeetosh System/RAW/R1-Coffeetosh-System-Documentation.md`

---

## 1. 👁️ The Vision
The Coffeetosh System Engine is the core background brain dictating macOS sleep mechanics without requiring the UI to remain open. It leverages an elegant Dual-Mode architecture—Mode A uses `IOPMAssertion` to easily block display-idle sleep, while Mode B executes an escalated `pmset disablesleep 1` command to forcibly permit headless, lid-closed operations safe for remote SSH sessions.

## 2. ⚙️ Core Mechanics
- **State System:** Strictly relies on a local `~/.lidcaf/status.json` file for atomic source-of-truth syncing between the Menu Bar UI and Background Daemon.
- **Daemon Architecture:** Detaches entirely from the GUI parent process. If the GUI crashes or is closed, the daemon lives on to count down the clock and restore system state, securing the user against permanently ruined battery logic.
- **Crash Recovery:** A 3-layer net (Daemon Signal traps `SIGTERM/SIGINT`, GUI `willTerminate`, and LaunchD boot `lidcaf-cleanup` script).

## 3. 🎯 Definition of Done
1. **Mode Switching:** Both Mode A (`keep-awake`) and Mode B (`headless ssh`) reliably prevent sleep without crossing privilege boundaries incorrectly.
2. **Persistence:** The background daemon successfully adopts orphaned states when the parent application is killed and effectively restores original default macOS power settings when completed.
3. **External Sync:** The `status.json` seamlessly communicates bi-directionally between the Daemon's state and the `FileSystemWatcher` informing the GUI's views.
4. **Resilience:** The Boot-Time Cleanup plist accurately identifies any stuck `pmset disablesleep 1` parameters and reverts them safely if a panic crash occurred.