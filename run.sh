#!/bin/bash
# Fast build→install→launch→screenshot loop for the iPhone 16 simulator (no Xcode GUI needed).
set -e
cd "$(dirname "$0")"
SIM="iPhone 16"
BUNDLE="com.tranquilwaters.aiphotostyles"
APP="build/Build/Products/Debug-iphonesimulator/AIPhotoStyles.app"

echo "▸ xcodegen…"; xcodegen generate >/dev/null
echo "▸ build…"
xcodebuild -project AIPhotoStyles.xcodeproj -scheme AIPhotoStyles \
  -sdk iphonesimulator -configuration Debug \
  -destination "platform=iOS Simulator,name=$SIM" \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO 2>&1 | tail -1

echo "▸ boot + install…"
xcrun simctl boot "$SIM" 2>/dev/null || true
open -a Simulator
xcrun simctl install booted "$APP"
echo "▸ launch…"
xcrun simctl terminate booted "$BUNDLE" 2>/dev/null || true
xcrun simctl launch booted "$BUNDLE"
sleep 2
xcrun simctl io booted screenshot "/tmp/aiphotostyles.png" >/dev/null 2>&1 && echo "▸ shot: /tmp/aiphotostyles.png"
