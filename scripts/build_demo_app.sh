#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/../example"

if ! command -v gum &> /dev/null; then
    echo "gum is required but not installed."
    echo "Install it with: brew install gum"
    exit 1
fi

increment_build_number() {
    local pubspec_file="pubspec.yaml"
    if [ ! -f "$pubspec_file" ]; then
        gum style --foreground 196 "❌ $pubspec_file not found."
        exit 1
    fi

    local build_number
    build_number=$(grep -E '^\s*version:' "$pubspec_file" | sed -E 's/.*\+([0-9]+).*/\1/')
    if [ -z "$build_number" ]; then
        gum style --foreground 196 "❌ Build number not found in $pubspec_file."
        exit 1
    fi

    build_number=$((build_number + 1))
    sed -i '' -E "s/(version: .+)\+[0-9]+/\1+$build_number/" "$pubspec_file"
    echo "$build_number"
}

gum style \
    --border rounded \
    --border-foreground 212 \
    --padding "0 2" \
    --margin "1 0" \
    "📱 Courier Flutter — Build Demo App"

PLATFORMS=$(gum choose --no-limit --selected="iOS","Android" "iOS" "Android")

if [[ -z "$PLATFORMS" ]]; then
    gum style --foreground 214 "No platforms selected. Aborting."
    exit 0
fi

gum style \
    --border rounded \
    --border-foreground 214 \
    --padding "0 2" \
    "Building for: $PLATFORMS"

if ! gum confirm "Proceed with build?"; then
    echo "Cancelled."
    exit 0
fi

BUILD_NUMBER=$(increment_build_number)
gum style --foreground 245 "Build number incremented to $BUILD_NUMBER"

build_ios() {
    gum spin --spinner dot --title "Building iOS app bundle..." -- \
        flutter build ipa --release

    gum style --foreground 46 "✅ iOS build complete"
    open build/ios/archive/Runner.xcarchive
}

build_android() {
    gum spin --spinner dot --title "Building Android app bundle..." -- \
        flutter build appbundle --release

    gum style --foreground 46 "✅ Android build complete"
    open build/app/outputs/bundle/release
}

if echo "$PLATFORMS" | grep -q "iOS"; then
    build_ios
fi

if echo "$PLATFORMS" | grep -q "Android"; then
    build_android
fi

gum style \
    --border rounded \
    --border-foreground 46 \
    --padding "0 2" \
    --margin "1 0" \
    "🎉 Demo app build finished" \
    "" \
    "  Build number: $BUILD_NUMBER" \
    "  Platforms:    $PLATFORMS"
