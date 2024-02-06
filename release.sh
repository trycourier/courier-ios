#!/bin/bash

# Function to display an error message and exit
error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

# 1. Test
echo "ℹ️ Running Tests..."
if ! sh test.sh; then
    error_exit "Tests failed. Aborting further actions."
fi

# 2. Push
echo "ℹ️ Pushing Release..."
sh push.sh

echo "🚀 Release Complete!"
