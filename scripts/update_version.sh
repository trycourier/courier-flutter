#!/bin/bash

# Change to the root directory
cd "$(dirname "$0")/.."
ROOT_DIR="$(pwd)"

# Define ANSI color codes
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to read the current version from pubspec.yaml
get_current_version() {
    grep '^version:' pubspec.yaml | awk '{print $2}'
}

# Function to parse the version and suggest the next version
suggest_next_version() {
    local current_version=$1
    local base_version=$(echo $current_version | awk -F '+' '{print $1}')
    local build_metadata=$(echo $current_version | awk -F '+' '{print $2}')

    if [[ -n $build_metadata ]]; then
        local next_build=$((build_metadata + 1))
        echo "${base_version}+${next_build}"
    else
        IFS='.' read -r -a version_parts <<< "$base_version"
        local next_patch=$((version_parts[2] + 1))
        echo "${version_parts[0]}.${version_parts[1]}.$next_patch"
    fi
}

# Function to update the version in pubspec.yaml
update_pubspec_version() {
    local new_version=$1
    sed -i '' "s/^version:.*/version: $new_version/" pubspec.yaml
}

# Function to update the Swift files
update_swift_file() {
    local file=$1
    local version=$2
    sed -i '' "s/Courier\.agent = CourierAgent\.flutterIOS(\"[^\"]*\")/Courier.agent = CourierAgent.flutterIOS(\"$version\")/" "$file"
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo "  ✗ Failed to update $file"
        exit 1
    fi
}

# Function to update the Kotlin files
update_kotlin_file() {
    local file=$1
    local version=$2
    sed -i '' "s/Courier\.agent = CourierAgent\.FlutterAndroid(version = \"[^\"]*\")/Courier.agent = CourierAgent.FlutterAndroid(version = \"$version\")/" "$file"
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo "  ✗ Failed to update $file"
        exit 1
    fi
}

# Update native plugin agent strings to match the given version
update_native_versions() {
    local version=$1
    echo -e "\nUpdating native plugin versions to ${ORANGE}$version${NC}..."

    update_swift_file "$ROOT_DIR/ios/Classes/CourierFlutterDelegate.swift" "$version"
    update_swift_file "$ROOT_DIR/ios/Classes/CourierFlutterMethodHandler.swift" "$version"

    update_kotlin_file "$ROOT_DIR/android/src/main/kotlin/com/courier/courier_flutter/CourierPlugin.kt" "$version"
    update_kotlin_file "$ROOT_DIR/android/src/main/kotlin/com/courier/courier_flutter/CourierFlutterFragmentActivity.kt" "$version"
    update_kotlin_file "$ROOT_DIR/android/src/main/kotlin/com/courier/courier_flutter/CourierFlutterActivity.kt" "$version"

    echo -e "\n${GREEN}All files updated to $version.${NC}"
}

# Get the current version
current_version=$(get_current_version)
echo -e "Current version: ${ORANGE}$current_version${NC}"

# Suggest the next version
suggested_version=$(suggest_next_version "$current_version")
echo -e "Suggested next version: ${ORANGE}$suggested_version${NC}"

# Prompt the user for the new version
read -p "Enter the new version (or press Enter to use suggested version): " user_version
new_version=${user_version:-$suggested_version}

# Ask for confirmation
echo -e "You entered version ${ORANGE}$new_version${NC}"
read -p "Do you want to update the version? (y/n): " confirmation

if [[ $confirmation == "y" || $confirmation == "Y" ]]; then
    update_pubspec_version "$new_version"
    echo -e "pubspec.yaml updated to: ${ORANGE}$new_version${NC}"

    update_native_versions "$new_version"
else
    echo "Version update canceled."
fi
