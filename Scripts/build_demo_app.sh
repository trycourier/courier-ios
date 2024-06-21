#!/bin/bash

# Change to the root directory
cd "$(dirname "$0")/.."

# Change to the directory containing your iOS project
PROJECT_DIR="Example"
cd "$PROJECT_DIR" || { echo "Directory not found: $PROJECT_DIR"; exit 1; }

# Increment the build number
echo "Incrementing build number..."
agvtool next-version -all

# Define variables for the build
SCHEME="Example"
PROJECT="Example.xcodeproj"
ARCHIVE_PATH="$PWD/build/ios/archive/Runner.xcarchive"

# Build the app and create an archive
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -archivePath "$ARCHIVE_PATH" archive || { echo "Build failed"; exit 1; }

# Open the archive in Xcode Organizer
open "$ARCHIVE_PATH"

echo "Build completed and opened in Xcode Organizer"
