#!/bin/bash

# Move to Scripts
cd Scripts

# Function to handle errors and exit
error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

# Define steps as an indexed array with title and script
declare -a steps=(
    "Run Tests:sh run_tests.sh"
    "Build Demo App:sh build_demo_app.sh"
    "Update Build Version:sh update_version.sh"
    "Create Git Release:sh git_release.sh"
    "Distribute Release:sh distribute_release.sh"
)

# Display available steps with indices
echo "Available steps:"
index=0
for step in "${steps[@]}"; do
    echo "$index: ${step%%:*}"  # Display only the title part before ":"
    ((index++))
done

# Prompt user to select a step
read -p "Select step to start from (default 0): " start_step_index

# Default to starting from the first step if input is empty or invalid
if [[ ! $start_step_index =~ ^[0-9]+$ ]]; then
    start_step_index=0
fi

# Execute steps from selected index onwards
for (( i=start_step_index; i<${#steps[@]}; i++ )); do
    step="${steps[$i]}"
    title="${step%%:*}"  # Extract title part before ":"
    script="${step#*:}"  # Extract script part after ":"
    echo "Executing Step $i: $title"
    if ! eval "$script"; then
        error_exit "❌ Step $i ($title) failed"
    fi
done

echo "All steps completed successfully."
