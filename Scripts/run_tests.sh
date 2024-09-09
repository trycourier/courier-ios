#!/bin/bash

# Change to the root directory
cd "$(dirname "$0")/.."

# Default simulator
DEFAULT_SIMULATOR="iPhone 15 Pro,OS=17.4"

# Prompt the user for the simulator, with a default value
read -p "Which simulator should start? (press Enter for default: '$DEFAULT_SIMULATOR'): " user_simulator

# Use the default simulator if the user presses Enter without typing anything
simulator="${user_simulator:-$DEFAULT_SIMULATOR}"

# Open the simulator
echo "🔄 Booting Simulator: $simulator..."
open -a Simulator && xcrun simctl boot "$simulator"
echo "✅ Opened Simulator: $simulator.\n"

# Start the tests
xcodebuild -scheme CourierTests -destination "platform=iOS Simulator,name=$simulator" test

# Check the exit code of xcodebuild
if [ $? -eq 0 ]; then
    echo "✅ Tests passed.\n"
else
    echo "❌ Tests failed.\n"
    echo "🐣 You may want to double check to make sure the correct Simulator is open.\n"
    exit 1
fi
