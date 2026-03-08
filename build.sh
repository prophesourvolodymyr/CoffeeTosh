#!/bin/bash
# build.sh — Coffeetosh Build Script
# Compiles all binaries, assembles .app bundle, and creates .dmg installer.
set -euo pipefail

# ── Config ───────────────────────────────────────────────────────
APP_NAME="Coffeetosh"
BUNDLE_ID="com.coffeetosh"
MIN_MACOS="13.0"
BUILD_DIR="build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS}/MacOS"
RESOURCES_DIR="${CONTENTS}/Resources"

echo "☕ Building ${APP_NAME}…"
echo ""

# ── Clean ────────────────────────────────────────────────────────
rm -rf "${BUILD_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

# ── Compile via Swift Package Manager ────────────────────────────
echo "📦 Compiling Swift Package (release)…"
swift build -c release 2>&1 | tail -5

# ── Copy Binaries ───────────────────────────────────────────────
echo "📋 Assembling app bundle…"
cp .build/release/coffeetosh          "${MACOS_DIR}/coffeetosh"
cp .build/release/coffeetosh-daemon   "${MACOS_DIR}/coffeetosh-daemon"
cp .build/release/coffeetosh-cleanup  "${MACOS_DIR}/coffeetosh-cleanup"

# Make the main binary the app's executable
ln -sf coffeetosh "${MACOS_DIR}/${APP_NAME}"

# ── Copy Resources ──────────────────────────────────────────────
cp Resources/com.coffeetosh.cleanup.plist "${RESOURCES_DIR}/"
cp ASSETS/Coffeetosh.icns "${RESOURCES_DIR}/Coffeetosh.icns"

# ── Generate Info.plist ─────────────────────────────────────────
cat > "${CONTENTS}/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleVersion</key>
    <string>1.2.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.2.0</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>${MIN_MACOS}</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>Coffeetosh</string>
</dict>
</plist>
PLIST

# ── Ad-Hoc Code Sign ───────────────────────────────────────────
echo "🔑 Ad-hoc signing…"
codesign --force --deep --sign - "${APP_BUNDLE}"
# [FUTURE] Replace with: codesign --force --deep --sign "Developer ID Application: Your Name (TEAMID)" "${APP_BUNDLE}"

# ── Create DMG ──────────────────────────────────────────────────
echo "💿 Creating DMG…"
DMG_PATH="${BUILD_DIR}/${APP_NAME}.dmg"

# Add Applications symlink so users can drag-and-drop to install
ln -sf /Applications "${BUILD_DIR}/Applications"

hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "${BUILD_DIR}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}" 2>&1 | tail -3

# Clean up symlink
rm -f "${BUILD_DIR}/Applications"

# ── Summary ─────────────────────────────────────────────────────
echo ""
echo "✅ Build complete!"
echo ""
echo "📁 App Bundle: ${APP_BUNDLE}"
echo "💿 DMG:        ${DMG_PATH}"
echo ""
echo "🧪 To test without installing:"
echo "   open ${APP_BUNDLE}"
echo ""
echo "📦 To distribute:"
echo "   1. Copy ${DMG_PATH} to your releases"
echo "   2. Users: xattr -cr ${APP_NAME}.app  (clear quarantine)"
echo "   3. Users: coffeetosh install-cli     (symlink to /usr/local/bin)"
