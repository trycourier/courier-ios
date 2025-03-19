#!/bin/bash

# 1) Change to the repository root directory
cd "$(dirname "$0")/.." || exit 1

# 2) Change to the directory containing your iOS project
PROJECT_DIR="Example"
cd "$PROJECT_DIR" || { echo "Directory not found: $PROJECT_DIR"; exit 1; }

# 3) Retrieve the current build number and increment it
echo "Retrieving current build number..."
CURRENT_BUILD=$(agvtool what-version -terse 2>/dev/null | tail -1)
if [[ ! "$CURRENT_BUILD" =~ ^[0-9]+$ ]]; then
  echo "Error: Current build number \"$CURRENT_BUILD\" is not numeric."
  exit 1
fi

NEW_BUILD=$((CURRENT_BUILD + 1))
echo "Incrementing build number from $CURRENT_BUILD to $NEW_BUILD..."
agvtool new-version -all "$NEW_BUILD"

# 4) Define variables for the build
SCHEME="Example"
PROJECT="Example.xcodeproj"
ARCHIVE_PATH="$PWD/build/ios/archive/Runner.xcarchive"

# 5) Build the app and create an archive
echo "Archiving for iOS..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -sdk iphoneos \
  -archivePath "$ARCHIVE_PATH" \
  archive || { echo "Build failed"; exit 1; }

# 6) Open the archive in Xcode Organizer
open "$ARCHIVE_PATH"

echo "Build completed and opened in Xcode Organizer"
