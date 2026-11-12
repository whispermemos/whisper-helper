#!/bin/bash
# Builds the helper for Apple silicon and Intel and wraps it in
# "build/Whisper Memos Helper.app", with the Sparkle framework inside.
# Signs ad-hoc by default. For a build other people can open, pass a Developer ID:
#   SIGN_IDENTITY="Developer ID Application" scripts/build-app.sh
# scripts/release.sh uses this to make the notarized download.
set -euo pipefail
cd "$(dirname "$0")/.."

APP="build/Whisper Memos Helper.app"
BINARY="$APP/Contents/MacOS/Whisper Memos Helper"
SPARKLE="$APP/Contents/Frameworks/Sparkle.framework"
IDENTITY="${SIGN_IDENTITY:--}"

sign() {
  if [ "$IDENTITY" = "-" ]; then
    # no hardened runtime: with it, macOS refuses to load an ad-hoc signed Sparkle
    codesign --force --sign - "$@"
  else
    codesign --force --options runtime --timestamp --sign "$IDENTITY" "$@"
  fi
}

BUILD_FLAGS=(-c release --arch arm64 --arch x86_64)
swift build "${BUILD_FLAGS[@]}"
PRODUCTS="$(swift build "${BUILD_FLAGS[@]}" --show-bin-path)"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$APP/Contents/Frameworks"
# the binary carries the app's name, so that is what Activity Monitor and keychain prompts show
cp "$PRODUCTS/WhisperMemosHelper" "$BINARY"
# swift build stamps the binary as built with the macOS 15 SDK, and macOS then draws
# the app in the old look. Stamp the SDK it was really built with, to get Liquid Glass.
SDK_VERSION="$(xcrun --show-sdk-version)"
vtool -arch arm64 -set-build-version macos 15.0 "$SDK_VERSION" -replace -output "$BINARY" "$BINARY"
vtool -arch x86_64 -set-build-version macos 15.0 "$SDK_VERSION" -replace -output "$BINARY" "$BINARY"
# so the binary finds Sparkle in Contents/Frameworks
install_name_tool -add_rpath @executable_path/../Frameworks "$BINARY"
cp Info.plist "$APP/Contents/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"
# the Settings tab icons
cp Resources/settings-*.png "$APP/Contents/Resources/"
ditto .build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework "$SPARKLE"

# Sparkle's helpers are signed one by one, inside out, then the app itself.
sign "$SPARKLE/Versions/B/XPCServices/Installer.xpc"
sign --preserve-metadata=entitlements "$SPARKLE/Versions/B/XPCServices/Downloader.xpc"
sign "$SPARKLE/Versions/B/Autoupdate"
sign "$SPARKLE/Versions/B/Updater.app"
sign "$SPARKLE"
sign "$APP"

echo "Built $APP"
