#!/bin/bash
# Builds the helper and wraps it in "build/Whisper Memos Helper.app".
# Signs ad-hoc by default. For a build other people can open, pass a Developer ID:
#   SIGN_IDENTITY="Developer ID Application: ..." scripts/build-app.sh
set -euo pipefail
cd "$(dirname "$0")/.."

APP="build/Whisper Memos Helper.app"

swift build -c release
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
# the binary carries the app's name, so that is what Activity Monitor and keychain prompts show
cp .build/release/WhisperMemosHelper "$APP/Contents/MacOS/Whisper Memos Helper"
# swift build stamps the binary as built with the macOS 15 SDK, and macOS then draws
# the app in the old look. Stamp the SDK it was really built with, to get Liquid Glass.
vtool -set-build-version macos 15.0 "$(xcrun --show-sdk-version)" -replace \
  -output "$APP/Contents/MacOS/Whisper Memos Helper" "$APP/Contents/MacOS/Whisper Memos Helper"
cp Info.plist "$APP/Contents/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"
# the Settings tab icons
cp Resources/settings-*.png "$APP/Contents/Resources/"
codesign --force --options runtime --sign "${SIGN_IDENTITY:--}" "$APP"

echo "Built $APP"
