#!/bin/bash

# Get the version from the root pubspec.yaml
version=$(grep '^version:' ../pubspec.yaml | sed 's/version: //')

# Remove any leading/trailing whitespace
version=$(echo $version | xargs)

echo "Detected version: $version"

# Function to update the Swift files
update_swift_file() {
    local file=$1
    echo "Updating $file..."
    sed -i '' "s/Courier\.agent = CourierAgent\.flutterIOS(\"[^\"]*\")/Courier.agent = CourierAgent.flutterIOS(\"$version\")/" "$file"
    if [ $? -eq 0 ]; then
        echo "$file updated successfully."
    else
        echo "Failed to update $file."
        exit 1
    fi
}

# Function to update the Kotlin file
update_kotlin_file() {
    local file=$1
    echo "Updating $file..."
    sed -i '' "s/Courier\.agent = CourierAgent\.FlutterAndroid(version = \"[^\"]*\")/Courier.agent = CourierAgent.FlutterAndroid(version = \"$version\")/" "$file"
    if [ $? -eq 0 ]; then
        echo "$file updated successfully."
    else
        echo "Failed to update $file."
        exit 1
    fi
}

# Update the Swift files
update_swift_file "../ios/Classes/CourierFlutterDelegate.swift"
update_swift_file "../ios/Classes/CourierFlutterMethodHandler.swift"

# Update the Kotlin file
update_kotlin_file "../android/src/main/kotlin/com/courier/courier_flutter/CourierPlugin.kt"
update_kotlin_file "../android/src/main/kotlin/com/courier/courier_flutter/CourierFlutterFragmentActivity.kt"
update_kotlin_file "../android/src/main/kotlin/com/courier/courier_flutter/CourierFlutterActivity.kt"

echo "All files updated successfully with version $version."
