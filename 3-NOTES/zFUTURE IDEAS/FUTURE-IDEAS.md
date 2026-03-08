# 💡 Future Ideas

---

## LidCaf — General

- **2026-03-02** — Cross-platform version of LidCaf for Windows and Linux
  - *Context:* During LidCaf system audit — discussing whether to use Swift or a cross-platform framework (Electron, Tauri, Flutter).
  - *Why deferred:* Sleep prevention is 100% OS-specific. macOS uses `pmset`/`caffeinate`/`IOPMAssertion`, Windows uses `SetThreadExecutionState()`, Linux uses `systemd-inhibit`/`xdg-screensaver`/`dbus`. No shared abstraction exists — cross-platform frameworks would require 3 completely separate backend implementations anyway, with zero reuse on the core logic. Swift + SwiftUI is the right call for the macOS version now. Windows/Linux variants are separate future apps that could share the CLI interface design and `status.json` format only.
  - *Suggested approach when revisited:* Tauri (Rust backend, smaller than Electron) for a unified shell, with platform-specific sleep inhibitor backends per OS. Or 3 native apps sharing no code but sharing the same CLI spec.
