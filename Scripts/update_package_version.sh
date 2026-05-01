#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v gum &> /dev/null; then
    echo "gum is required but not installed."
    echo "Install it with: brew install gum"
    exit 1
fi

get_current_version() {
    grep 'internal static let version =' Sources/Courier_iOS/Courier_iOS.swift | awk -F '"' '{print $2}'
}

CURRENT=$(get_current_version)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

gum style \
    --border rounded \
    --border-foreground 212 \
    --padding "0 2" \
    --margin "1 0" \
    "📦 Courier iOS — Package Version" \
    "" \
    "Current version: $CURRENT"

BUMP_TYPE=$(gum choose "patch → $MAJOR.$MINOR.$((PATCH + 1))" "minor → $MAJOR.$((MINOR + 1)).0" "major → $((MAJOR + 1)).0.0" "custom")

case "$BUMP_TYPE" in
    patch*)  NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))" ;;
    minor*)  NEW_VERSION="$MAJOR.$((MINOR + 1)).0" ;;
    major*)  NEW_VERSION="$((MAJOR + 1)).0.0" ;;
    custom)  NEW_VERSION=$(gum input --placeholder "x.y.z" --prompt "Version: ") ;;
esac

if [[ -z "$NEW_VERSION" ]]; then
    echo "No version entered. Aborting."
    exit 1
fi

if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    gum style --foreground 196 "Invalid version format: $NEW_VERSION (expected x.y.z)"
    exit 1
fi

gum style \
    --border rounded \
    --border-foreground 214 \
    --padding "0 2" \
    "$CURRENT → $NEW_VERSION"

if ! gum confirm "Apply this version update?"; then
    echo "Cancelled."
    exit 0
fi

sed -i '' "s/internal static let version = \".*\"/internal static let version = \"$NEW_VERSION\"/" Sources/Courier_iOS/Courier_iOS.swift
sed -i '' "s/s.version = .*/s.version = '$NEW_VERSION'/" Courier_iOS.podspec

cd Example
CURRENT_BUILD=$(agvtool what-version -terse 2>/dev/null | tail -1)
if [[ "$CURRENT_BUILD" =~ ^[0-9]+$ ]]; then
    NEW_BUILD=$((CURRENT_BUILD + 1))
    agvtool new-version -all "$NEW_BUILD" > /dev/null 2>&1
fi
cd ..

gum style \
    --border rounded \
    --border-foreground 46 \
    --padding "0 2" \
    --margin "1 0" \
    "✅ Version updated to $NEW_VERSION" \
    "" \
    "  Courier_iOS.swift   → $NEW_VERSION" \
    "  Courier_iOS.podspec → $NEW_VERSION" \
    "  Example app build   → $((CURRENT_BUILD + 1))"
