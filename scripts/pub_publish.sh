#!/bin/bash

# Change to the root directory
cd "$(dirname "$0")/.."

# Define ANSI color codes
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to handle errors and exit
error_exit() {
    echo -e "❌ Error: $1" >&2
    exit 1
}

# Function to log in to pub.dev if not already logged in
login_to_pub() {
    if ! dart pub cache repair >/dev/null 2>&1; then
        echo -e "${ORANGE}⚠️ Logging in to pub.dev...${NC}"
        dart pub login || error_exit "Failed to log in to pub.dev. Please log in manually and retry."
    else
        echo -e "${GREEN}✅ Already logged in to pub.dev.${NC}"
    fi
}

# Function to publish the package
publish_package() {
    # Navigate to the package directory
    cd "$(dirname "$0")" || error_exit "Failed to change directory."

    # Run a dry run to preview the publication
    echo -e "${ORANGE}⚠️ Running dry run to preview publication...${NC}"
    dart pub publish --dry-run
    read -p "Proceed with publishing? (y/n): " confirmation

    if [[ $confirmation == "y" || $confirmation == "Y" ]]; then
        # Run the actual publish command
        echo -e "${ORANGE}⚠️ Publishing the package...${NC}"
        dart pub publish --force || error_exit "Failed to publish the package."
        echo -e "${GREEN}✅ Package successfully published to pub.dev.${NC}"
    else
        echo "Publication process canceled."
    fi
}

# Main script execution
echo -e "${ORANGE}⚠️ Starting the Flutter package publish script...${NC}"

# Log in to pub.dev if needed
login_to_pub

# Publish the package
publish_package