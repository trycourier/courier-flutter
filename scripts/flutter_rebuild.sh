#!/bin/bash

# Change to the root directory
cd .. || exit

# Clean and get packages
flutter clean
flutter pub get

# Change to the example directory
cd example || exit

# Clean and get packages
flutter clean
flutter pub get

# Change to the ios directory
cd ios || exit

# Reinstall pods
pod install
