#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

get_current_version() {
    grep 'internal static let version =' Sources/Courier_iOS/Courier_iOS.swift | awk -F '"' '{print $2}'
}

if ! brew list cocoapods >/dev/null 2>&1; then
    echo "⚠️ CocoaPods not found. Installing via Homebrew..."
    brew install cocoapods
fi

echo "✅ CocoaPods version $(pod --version) is installed."

VERSION=$(get_current_version)
echo "✅ SDK Version Found: $VERSION"

pod trunk push --allow-warnings --verbose
echo "✅ Cocoapod $VERSION released"
