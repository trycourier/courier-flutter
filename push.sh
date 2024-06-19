#!/bin/bash

# Update the SDK build
sh dist.sh

# Build the demo apps
sh build.sh

# Push to give and release the SDK
sh release.sh
