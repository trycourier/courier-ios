#!/bin/bash

# Check if Homebrew is installed
if ! which brew >/dev/null 2>&1; then
    echo "⚠️ Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "✅ Homebrew is installed.\n"
