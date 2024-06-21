#!/bin/bash

# Change to the root directory
cd "$(dirname "$0")/.."

# Define ANSI color codes
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Function to read the current version from Courier_iOS.swift
get_current_version() {
    local version=$(grep 'internal static let version =' Sources/Courier_iOS/Courier_iOS.swift | awk -F '"' '{print $2}')
    echo "$version"
}

# Function to get the current Git branch
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Function to run git status
run_git_status() {
    git status
}

# Function to add all changes and commit with message including version
add_commit_merge() {
    local version=$(get_current_version)
    git add -A
    git commit -m "🚀 $version"
}

# Function to merge the current branch into master
merge_into_master() {
    local branch=$(get_current_branch)
    git checkout master
    git merge --no-ff "$branch"
    git push origin master
    git checkout "$branch"
}

# Function to create GitHub release
create_github_release() {
    local version=$(get_current_version)
    echo "⚠️ Creating GitHub release for version $version...\n"
    gh release create $version --generate-notes
    echo "✅ GitHub release $version created\n"
}

# Main script execution
# Get the current version and prepare for merge
current_version=$(get_current_version)

# Ask for confirmation to merge into master with versioned commit
read -p "Merge into master and create release with commit: '🚀 $current_version'? (y/n): " confirmation

if [[ $confirmation == "y" || $confirmation == "Y" ]]; then
    # Perform the Git operations
    run_git_status
    add_commit_merge
    merge_into_master

    # Optionally, perform release steps
    create_github_release
else
    echo "Merge and release process canceled."
fi
