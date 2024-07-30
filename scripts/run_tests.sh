#!/bin/bash

# Change to the root directory
cd "$(dirname "$0")/../example"

# Run tests
flutter test integration_test/client_tests.dart