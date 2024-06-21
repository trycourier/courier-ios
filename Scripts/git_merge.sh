#!/bin/bash

# Function to get the current Git branch
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Function to check if the current branch is master
is_current_branch_master() {
    local branch=$(get_current_branch)
    [[ "$branch" == "master" ]]
}

# Function to run git status
run_git_status() {
    git status
}

# Function to add all changes and commit with message "MERGE"
add_commit_merge() {
    git add -A
    git commit -m "MERGE"
}

# Function to merge the current branch into master
merge_into_master() {
    local branch=$(get_current_branch)
    git checkout master
    git merge --no-ff "$branch"
    git push origin master
}

# Get current branch and run git status
current_branch=$(get_current_branch)
run_git_status

# Prompt user based on current branch
if is_current_branch_master; then
    echo "Current branch is 'master'. Adding, committing, and pushing changes."
    add_commit_merge
    git push origin master
else
    read -p "Current branch is '$current_branch'. Do you want to add all and commit with message 'MERGE' and merge into 'master'? (y/n): " confirmation
    if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]; then
        add_commit_merge
        merge_into_master
    else
        echo "Merge process canceled."
    fi
fi
