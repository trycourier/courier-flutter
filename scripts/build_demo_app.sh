#!/bin/bash

# Function to increment build number
increment_build_number() {
    local pubspec_file="pubspec.yaml"
    if [ ! -f "$pubspec_file" ]; then
        echo "❌ $pubspec_file not found."
        exit 1
    fi

    local build_number=$(grep -E '^\s*version:' "$pubspec_file" | sed -E 's/.*\+([0-9]+).*/\1/')
    if [ -z "$build_number" ]; then
        echo "❌ Build number not found in $pubspec_file."
        exit 1
    fi

    build_number=$((build_number + 1))
    echo "Incrementing build number to $build_number."

    sed -i '' -E "s/(version: .+)\+[0-9]+/\1+$build_number/" "$pubspec_file"
}

# Navigate to the example directory
cd ../example || { echo "Failed to navigate to the example directory. Please ensure the path is correct."; exit 1; }
echo "Navigated to the example directory."

# Increment Flutter build number
increment_build_number

# # Build Android app bundle
# echo "🤖 Building Android app bundle..."
# flutter build appbundle

# if [ $? -ne 0 ]; then
#     echo "❌ Failed to build Android app bundle."
#     exit 1
# fi

# echo "✅ Android app bundle built successfully."

# # Open the Android build folder in Finder
# open build/app/outputs/bundle/release

# Build iOS app bundle
echo "🍎 Building iOS app bundle..."
flutter build ipa --release

if [ $? -ne 0 ]; then
    echo "❌ Failed to build iOS app bundle."
    exit 1
fi

echo "✅ iOS app bundle built successfully."

# Open the iOS build in Xcode Organizer
open build/ios/archive/Runner.xcarchive

echo "Both Android and iOS app bundles have been generated successfully."
