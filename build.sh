#!/bin/bash

# Navigate to the example directory
cd example || { echo "Failed to navigate to the example directory. Please ensure the path is correct."; exit 1; }
echo "Navigated to the example directory."

sh ../dist.sh

# Build Android app bundle
echo "🤖 Building Android app bundle..."
flutter build appbundle

if [ $? -ne 0 ]; then
    echo "❌ Failed to build Android app bundle."
    exit 1
fi

echo "✅ Android app bundle built successfully."

# Open the Android build folder in Finder
open build/app/outputs/bundle/release

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