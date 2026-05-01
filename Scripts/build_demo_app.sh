#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

cd Example || { echo "Directory not found: Example"; exit 1; }

SCHEME="Example"
PROJECT="Example.xcodeproj"
ARCHIVE_PATH="$PWD/build/ios/archive/Runner.xcarchive"

echo "📦 Archiving $SCHEME for iOS..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -sdk iphoneos \
  -archivePath "$ARCHIVE_PATH" \
  archive || { echo "❌ Build failed"; exit 1; }

open "$ARCHIVE_PATH"

echo "✅ Build completed and opened in Xcode Organizer"
