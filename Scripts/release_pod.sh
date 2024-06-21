#!/bin/bash

# Change to the root directory
cd "$(dirname "$0")/.."

# Function to handle errors and exit
error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

# Function to read the current version from Courier_iOS.swift
get_current_version() {
    local version=$(grep 'internal static let version =' Sources/Courier_iOS/Courier_iOS.swift | awk -F '"' '{print $2}')
    echo "$version"
}

# Install CocoaPods CLI
if ! brew list cocoapods >/dev/null 2>&1; then
    echo "⚠️ CocoaPods not found. Installing via Homebrew...\n"
    brew install cocoapods
fi

echo "✅ CocoaPods version $(pod --version) is installed.\n"

# Get current version from Courier_iOS.swift
VERSION=$(get_current_version)

echo "✅ SDK Version Found: $VERSION\n"

# Push to CocoaPods
pod trunk push --allow-warnings --verbose
echo "✅ Cocoapod $VERSION released\n"
