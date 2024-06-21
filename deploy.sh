#!/bin/bash

error_exit() {
    echo "❌ Error: $1" >&2
    exit 1
}

# 1. Go to scripts
cd Scripts

# 2. Update the build version
sh update_version.sh

# 3. Run tests
if ! sh run_tests.sh; then
    error_exit "❌ Tests failed"
fi

# 4. Build app
if ! sh build_demo_app.sh; then
    error_exit "❌ Build failed"
fi

# 5. Distribute release
if ! sh distribute_release.sh; then
    error_exit "❌ Distribution failed"
fi
