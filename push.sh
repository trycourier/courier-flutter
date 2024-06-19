#!/bin/bash

# Update the SDK build
sh dist.sh

# Release the SDK
sh release.sh

# Build the demo apps
sh build.sh
