#!/bin/bash

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