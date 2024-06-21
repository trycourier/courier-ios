#!/bin/bash

# Change to the root directory
cd "$(dirname "$0")/.."

# Define ANSI color codes
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Function to handle errors and exit
error_exit() {
    echo -e "❌ Error: $1" >&2
    exit 1
}

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

# Function to install GitHub CLI if not already installed
install_gh_cli() {
    if ! which gh >/dev/null 2>&1; then
        echo -e "${ORANGE}⚠️ Installing GitHub CLI...${NC}"
        brew install gh || error_exit "Failed to install GitHub CLI. Please install it manually and retry."
    fi
}

# Function to create GitHub release
create_github_release() {
    local version=$(get_current_version)
    echo -e "${ORANGE}⚠️ Creating GitHub release for version $version...${NC}\n"
    gh release create "$version" --notes "Release for version $version"
    echo "✅ GitHub release $version created\n"
}

# Main script execution
# Get the current version and prepare for merge
current_version=$(get_current_version)

# Check if GitHub CLI is installed
install_gh_cli

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
