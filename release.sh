#!/bin/bash

## Open simulator
#open -a Simulator && xcrun simctl boot 'iPhone 15,OS=17.0.1'
#echo "✅ Opened Simulator.\n"
#
## Start the tests
#xcodebuild -scheme CourierTests -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0.1' test
#
## Check the exit code of xcodebuild
#if [ $? -eq 0 ]; then
#    echo "✅ Tests passed.\n"
#else
#    echo "❌ Tests failed.\n"
#    echo "🐣 You may want to double check to make sure the correct Simulator is open.\n"
#    exit 1
#fi

# Check if Homebrew is installed
if ! which brew >/dev/null 2>&1; then
    echo "⚠️ Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "✅ Homebrew is installed.\n"

# Install the Github CLI
if ! brew list gh >/dev/null 2>&1; then
    echo "⚠️ GitHub CLI not found. Installing via Homebrew...\n"
    brew install gh
fi

echo "✅ GitHub CLI version $(gh --version) is installed.\n"

# Install Cocoapods CLI
if ! brew list cocoapods >/dev/null 2>&1; then
    echo "⚠️ CocoaPods not found. Installing via Homebrew...\n"
    brew install cocoapods
fi

echo "✅ CocoaPods version $(pod --version) is installed.\n"

# Get the version number of Package from the swift file
cat Sources/Courier_iOS/Courier_iOS.swift | while read LINE; do
  if [[ $LINE == *"internal static let version"* ]]; then

    # Get version from Courier file
    VERSION=$(echo $LINE | sed -e 's/.*"\(.*\)".*/\1/')

    cat Courier_iOS.podspec | while read SPEC_VERSION; do
      if [[ $SPEC_VERSION == *"s.version ="* ]]; then

        # Replace PODSPEC version
        NEW_SPEC_VERSION="s.version = '$VERSION'"
        if [[ $SPEC_VERSION != "" && $NEW_SPEC_VERSION != "" ]]; then
          sed -i '.bak' "s/$SPEC_VERSION/$NEW_SPEC_VERSION/g" "Courier_iOS.podspec"
        fi

      fi
    done
    
    echo "✅ SDK Version Found: $VERSION\n"
    
    # Check if logged in
    if ! gh auth status >/dev/null 2>&1; then
        echo "⚠️ Logging in to GitHub...\n"
        gh auth login
    fi

    # Delete backup file
    rm "Courier_iOS.podspec.bak"
    
    # Get the latest release version of the apple/swift repository
    latest_version=$(gh api -X GET /repos/trycourier/courier-ios/releases/latest | jq -r '.tag_name')

    # Compare the latest version with another value
    if [[ "$latest_version" == $VERSION ]]; then
        echo "❌ The latest version is already $latest_version. Please change the version number in Sources/Courier_iOS/Courier_iOS.swift to push a release.\n"
        exit 1
    fi

    # Bump the version
    git add .
    git commit -m "Release"
    git push

    # Create a new tag with the version and push
    git tag $VERSION
    git push --tags
    echo "✅ $VERSION tag pushed\n"

    # gh release create
    gh release create $VERSION --generate-notes
    echo "✅ $VERSION github release created\n"

    # Push to pods
    pod trunk push --allow-warnings --verbose
    echo "✅ $VERSION Cocoapod released\n"

  fi
done
