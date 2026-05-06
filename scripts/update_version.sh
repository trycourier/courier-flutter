#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT_DIR="$(pwd)"

if ! command -v gum &> /dev/null; then
    echo "gum is required but not installed."
    echo "Install it with: brew install gum"
    exit 1
fi

get_current_version() {
    grep '^version:' pubspec.yaml | awk '{print $2}'
}

CURRENT=$(get_current_version)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

gum style \
    --border rounded \
    --border-foreground 212 \
    --padding "0 2" \
    --margin "1 0" \
    "📦 Courier Flutter — Package Version" \
    "" \
    "Current version: $CURRENT"

BUMP_TYPE=$(gum choose "patch → $MAJOR.$MINOR.$((PATCH + 1))" "minor → $MAJOR.$((MINOR + 1)).0" "major → $((MAJOR + 1)).0.0" "custom")

case "$BUMP_TYPE" in
    patch*)  NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))" ;;
    minor*)  NEW_VERSION="$MAJOR.$((MINOR + 1)).0" ;;
    major*)  NEW_VERSION="$((MAJOR + 1)).0.0" ;;
    custom)  NEW_VERSION=$(gum input --placeholder "x.y.z" --prompt "Version: ") ;;
esac

if [[ -z "$NEW_VERSION" ]]; then
    echo "No version entered. Aborting."
    exit 1
fi

if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    gum style --foreground 196 "Invalid version format: $NEW_VERSION (expected x.y.z)"
    exit 1
fi

gum style \
    --border rounded \
    --border-foreground 214 \
    --padding "0 2" \
    "$CURRENT → $NEW_VERSION"

if ! gum confirm "Apply this version update?"; then
    echo "Cancelled."
    exit 0
fi

# Update pubspec.yaml
sed -i '' "s/^version:.*/version: $NEW_VERSION/" pubspec.yaml

# Update native Swift agent strings
update_swift_file() {
    local file=$1
    sed -i '' "s/Courier\.agent = CourierAgent\.flutterIOS(\"[^\"]*\")/Courier.agent = CourierAgent.flutterIOS(\"$NEW_VERSION\")/" "$file"
}

# Update native Kotlin agent strings
update_kotlin_file() {
    local file=$1
    sed -i '' "s/Courier\.agent = CourierAgent\.FlutterAndroid(version = \"[^\"]*\")/Courier.agent = CourierAgent.FlutterAndroid(version = \"$NEW_VERSION\")/" "$file"
}

update_swift_file "$ROOT_DIR/ios/Classes/CourierFlutterDelegate.swift"
update_swift_file "$ROOT_DIR/ios/Classes/CourierFlutterMethodHandler.swift"

update_kotlin_file "$ROOT_DIR/android/src/main/kotlin/com/courier/courier_flutter/CourierPlugin.kt"
update_kotlin_file "$ROOT_DIR/android/src/main/kotlin/com/courier/courier_flutter/CourierFlutterFragmentActivity.kt"
update_kotlin_file "$ROOT_DIR/android/src/main/kotlin/com/courier/courier_flutter/CourierFlutterActivity.kt"

# Bump example app build number
EXAMPLE_PUBSPEC="example/pubspec.yaml"
CURRENT_BUILD=$(grep -E '^\s*version:' "$EXAMPLE_PUBSPEC" | sed -E 's/.*\+([0-9]+).*/\1/')
if [[ "$CURRENT_BUILD" =~ ^[0-9]+$ ]]; then
    NEW_BUILD=$((CURRENT_BUILD + 1))
    sed -i '' -E "s/(version: .+)\+[0-9]+/\1+$NEW_BUILD/" "$EXAMPLE_PUBSPEC"
fi

gum style \
    --border rounded \
    --border-foreground 46 \
    --padding "0 2" \
    --margin "1 0" \
    "✅ Version updated to $NEW_VERSION" \
    "" \
    "  pubspec.yaml              → $NEW_VERSION" \
    "  iOS Swift agents          → $NEW_VERSION" \
    "  Android Kotlin agents     → $NEW_VERSION" \
    "  Example build number      → ${NEW_BUILD:-$CURRENT_BUILD}"
