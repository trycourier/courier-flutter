#!/bin/bash

# Change to the root directory
cd ../example || exit

# Function to run the tests with the selected device ID
run_tests() {
    flutter test integration_test/client_tests.dart --device-id="$DEVICE_ID"
    flutter test integration_test/shared_tests.dart --device-id="$DEVICE_ID"
}

# Function to prompt the user to select a device and run the tests
select_device_and_run_tests() {
    # List available devices
    echo "Listing available devices..."
    flutter devices

    # Prompt the user to enter the device ID
    echo "Please enter the device ID to run the tests on:"
    read -r DEVICE_ID

    # Run the tests with the selected device ID
    run_tests

    # Ask the user if they want to rerun the tests
    while true; do
        echo "Do you want to rerun the tests or end the script? (r to rerun, e to exit):"
        read -r REPLY
        case $REPLY in
            [Rr]* ) select_device_and_run_tests; break;;
            [Ee]* ) echo "Exiting."; exit;;
            * ) echo "Please answer 'r' to rerun or 'e' to exit.";;
        esac
    done
}

# Start the process
select_device_and_run_tests