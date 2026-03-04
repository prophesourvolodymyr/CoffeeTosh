// swift-tools-version: 5.9
// Coffeetosh — Swift Package Manifest

import PackageDescription

let package = Package(
    name: "Coffeetosh",
    platforms: [
        .macOS(.v13)   // Minimum: macOS 13 Ventura
    ],
    products: [
        // Shared core library (Models, Engine, State)
        .library(
            name: "CoffeetoshCore",
            targets: ["CoffeetoshCore"]
        ),
        // Background daemon executable
        .executable(
            name: "coffeetosh-daemon",
            targets: ["CoffeetoshDaemon"]
        ),
        // CLI tool executable
        .executable(
            name: "coffeetosh",
            targets: ["CoffeetoshCLI"]
        ),
        // Boot-time cleanup executable
        .executable(
            name: "coffeetosh-cleanup",
            targets: ["CoffeetoshCleanup"]
        ),
    ],
    targets: [
        // ── Core Library ────────────────────────────────────────
        .target(
            name: "CoffeetoshCore",
            path: "Sources/CoffeetoshCore"
        ),
        // ── Background Daemon ───────────────────────────────────
        .executableTarget(
            name: "CoffeetoshDaemon",
            dependencies: ["CoffeetoshCore"],
            path: "Sources/CoffeetoshDaemon"
        ),
        // ── CLI Tool ────────────────────────────────────────────
        .executableTarget(
            name: "CoffeetoshCLI",
            dependencies: ["CoffeetoshCore"],
            path: "Sources/CoffeetoshCLI"
        ),
        // ── Boot-Time Cleanup ───────────────────────────────────
        .executableTarget(
            name: "CoffeetoshCleanup",
            dependencies: ["CoffeetoshCore"],
            path: "Sources/CoffeetoshCleanup"
        ),
    ]
)
