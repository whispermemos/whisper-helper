#!/bin/bash
# Builds a release of the helper and, with --publish, ships it.
# Makes a Developer ID-signed, notarized WhisperMemosHelper.dmg, adds it to the Sparkle
# feed from the gh-pages branch, then publishes the DMG as a GitHub release and pushes
# the feed to GitHub Pages. The version comes from Info.plist.
#
# One-time setup on the release Mac (nothing secret lives in this repository):
#   - a "Developer ID Application" certificate in the Keychain
#   - notarytool credentials in the Keychain:
#       xcrun notarytool store-credentials whispertype-notary --key AuthKey_XXX.p8 --key-id XXX --issuer XXX
#   - the Sparkle private key in the Keychain, under the account "whisper-helper"
#   - a signed-in gh CLI
set -euo pipefail
cd "$(dirname "$0")/.."

REPOSITORY="whispermemos/whisper-helper"
KEY_ACCOUNT="whisper-helper"
NOTARY_PROFILE="${NOTARY_PROFILE:-whispertype-notary}"
TOOLS=".build/artifacts/sparkle/Sparkle/bin"
OUT="build/release"
SITE="build/update-site"
APP="build/Whisper Memos Helper.app"
DMG="$OUT/WhisperMemosHelper.dmg"

IS_PUBLISHING=false
if [ "${1:-}" = "--publish" ]; then
  IS_PUBLISHING=true
fi

if $IS_PUBLISHING; then
  [ -z "$(git status --porcelain)" ] || { echo "Commit your changes before publishing."; exit 1; }
  git fetch origin main
  [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ] || { echo "Publish from main, pushed to origin."; exit 1; }
fi

VERSION="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" Info.plist)"
TAG="v$VERSION"
if gh release view "$TAG" --repo "$REPOSITORY" >/dev/null 2>&1; then
  echo "$TAG is already released. Bump CFBundleShortVersionString and CFBundleVersion in Info.plist first."
  exit 1
fi

echo "==> Building"
SIGN_IDENTITY="Developer ID Application" scripts/build-app.sh

PUBLIC_KEY="$(/usr/libexec/PlistBuddy -c "Print :SUPublicEDKey" Info.plist)"
[ "$("$TOOLS/generate_keys" --account "$KEY_ACCOUNT" -p)" = "$PUBLIC_KEY" ] || { echo "The Keychain's Sparkle key doesn't match SUPublicEDKey."; exit 1; }

rm -rf "$OUT" "$SITE"
mkdir -p "$OUT"

echo "==> Notarizing app"
ditto -c -k --keepParent "$APP" "$OUT/app.zip"
xcrun notarytool submit "$OUT/app.zip" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$APP"

echo "==> Creating DMG"
mkdir "$OUT/dmg"
cp -R "$APP" "$OUT/dmg/"
ln -s /Applications "$OUT/dmg/Applications"
hdiutil create -volname "Whisper Memos Helper" -srcfolder "$OUT/dmg" -format UDZO -ov "$DMG"
codesign --sign "Developer ID Application" --timestamp "$DMG"

echo "==> Notarizing DMG"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG"

echo "==> Verifying"
spctl --assess --type open --context context:primary-signature --verbose "$DMG"
spctl --assess --type execute --verbose "$APP"

echo "==> Updating the feed"
# Start from the published feed so older versions stay listed.
REMOTE="$(git remote get-url origin)"
if git ls-remote --exit-code --heads "$REMOTE" gh-pages >/dev/null; then
  git clone --depth=1 --branch=gh-pages "$REMOTE" "$SITE"
else
  git init -b gh-pages "$SITE"
  git -C "$SITE" remote add origin "$REMOTE"
fi
cp "$DMG" "$SITE/"
"$TOOLS/generate_appcast" --account "$KEY_ACCOUNT" \
  --download-url-prefix "https://github.com/$REPOSITORY/releases/download/$TAG/" \
  --maximum-deltas 0 --maximum-versions 3 "$SITE"
rm "$SITE/WhisperMemosHelper.dmg"

if ! $IS_PUBLISHING; then
  echo "Built $DMG and $SITE/appcast.xml. Publish with: scripts/release.sh --publish"
  exit
fi

# Release the DMG before the feed points at it.
gh release create "$TAG" "$DMG" --repo "$REPOSITORY" --title "Whisper Memos Helper $VERSION" --generate-notes
git -C "$SITE" add appcast.xml
git -C "$SITE" commit -m "Publish $TAG"
# GitHub turns on Pages by itself the first time gh-pages is pushed.
git -C "$SITE" push origin gh-pages

echo "Published $TAG."
