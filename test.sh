#!/bin/bash

# Open simulator
open -a Simulator && xcrun simctl boot 'iPhone 15,OS=17.0.1'
echo "✅ Opened Simulator.\n"

# Start the tests
xcodebuild -scheme CourierTests -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0.1' test

# Check the exit code of xcodebuild
if [ $? -eq 0 ]; then
    echo "✅ Tests passed.\n"
else
    echo "❌ Tests failed.\n"
    echo "🐣 You may want to double check to make sure the correct Simulator is open.\n"
    exit 1
fi
