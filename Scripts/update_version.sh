#!/bin/bash

# Change to the root directory
cd "$(dirname "$0")/.."

# Define ANSI color codes
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Function to read the current version
get_current_version() {
    grep 'internal static let version =' Sources/Courier_iOS/Courier_iOS.swift | awk -F '"' '{print $2}'
}

# Function to parse the version and suggest the next version
suggest_next_version() {
    local current_version=$1
    local base_version=$(echo $current_version | awk -F '+' '{print $1}')
    local build_metadata=$(echo $current_version | awk -F '+' '{print $2}')

    if [[ -n $build_metadata ]]; then
        local next_build=$((build_metadata + 1))
        echo "${base_version}+${next_build}"
    else
        IFS='.' read -r -a version_parts <<< "$base_version"
        local next_patch=$((version_parts[2] + 1))
        echo "${version_parts[0]}.${version_parts[1]}.$next_patch"
    fi
}

# Function to update the version in Sources/Courier_iOS/Courier_iOS.swift
update_version() {
    local new_version=$1
    
    # Update the Root Swift File
    sed -i '' "s/internal static let version = \".*\"/internal static let version = \"$new_version\"/" Sources/Courier_iOS/Courier_iOS.swift
    
    # Update the podspec version
    sed -i '.bak' "s/s.version = .*/s.version = '$new_version'/" Courier_iOS.podspec
    
    # Clean up backup file
    rm Courier_iOS.podspec.bak
}

# Get the current version
current_version=$(get_current_version)
echo "Current version: ${ORANGE}$current_version${NC}"

# Suggest the next version
suggested_version=$(suggest_next_version "$current_version")
echo "Suggested next version: ${ORANGE}$suggested_version${NC}"

# Prompt the user for the new version
read -p "Enter the new version (or press Enter to use suggested version): " user_version
new_version=${user_version:-$suggested_version}

# Ask for confirmation
echo "You entered version ${ORANGE}$new_version${NC}"
read -p "Do you want to update the version in Courier_iOS.swift? (y/n): " confirmation

if [[ $confirmation == "y" || $confirmation == "Y" ]]; then
    update_version "$new_version"
    echo "Version updated to: ${ORANGE}$new_version${NC}"
else
    echo "Version update canceled."
fi
