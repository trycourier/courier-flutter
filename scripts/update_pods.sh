#!/bin/bash

# Ask the user for the new pod version
read -p "What pod version are you updating to? " new_version

# Path to the podspec file
podspec_file="../ios/courier_flutter.podspec"

# Function to update the podspec file with the new version
update_podspec() {
    echo "Updating podspec file with version ${new_version}..."

    # Use `perl` to update the version number in the podspec file
    perl -pi -e "s/(s.dependency 'Courier_iOS', ).*/\1'${new_version}'/" "$podspec_file"

    if [ $? -eq 0 ]; then
        echo "Podspec file updated successfully."
    else
        echo "Failed to update podspec file."
        exit 1
    fi
}

# Update the podspec file
update_podspec

# Change to the desired directory
cd ../example/ios || exit

# Function to run `pod update` and check if it succeeds
update_pods() {
    echo "Running pod update..."
    pod update
    return $?
}

# Loop until `pod update` succeeds
while true; do
    update_pods
    if [ $? -eq 0 ]; then
        echo "Pod update succeeded."
        exit 0
    else
        echo "Pod update failed. Retrying in 10 seconds..."
        sleep 10
    fi
done
