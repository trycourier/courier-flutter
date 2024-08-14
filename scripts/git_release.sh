#!/bin/bash

# Change to the root directory
cd "$(dirname "$0")/.."

# Define ANSI color codes
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Function to handle errors and exit
error_exit() {
    echo -e "❌ Error: $1" >&2
    exit 1
}

# Function to get the package version from pubspec.yaml
get_package_version() {
    local version=$(yq .version pubspec.yaml | tr -d '"')
    echo "$version"
}

# Function to get the current Git branch
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Function to run git status
run_git_status() {
    git status
}

# Function to add all changes and commit with message including version
add_commit() {
    local version="$1"
    git add -A
    git commit -m "🚀 $version"
}

# Function to merge the current branch into master
merge_into_master() {
    local branch=$(get_current_branch)
    git checkout master
    git merge --no-ff "$branch"
    git push origin master
    git checkout "$branch"
}

# Function to install GitHub CLI if not already installed
install_gh_cli() {
    if ! which gh >/dev/null 2>&1; then
        echo -e "${ORANGE}⚠️ Installing GitHub CLI...${NC}"
        brew install gh || error_exit "Failed to install GitHub CLI. Please install it manually and retry."
    fi
}

# Function to create GitHub release
create_github_release() {
    local version="$1"
    echo -e "${ORANGE}⚠️ Creating GitHub release for version $version...${NC}\n"
    gh release create "$version" --notes "Release for version $version"
    echo "✅ GitHub release $version created\n"
}

# Main script execution
# Check if GitHub CLI is installed
install_gh_cli

# Get the package version from pubspec.yaml
current_version=$(get_package_version)
echo "Current version is $current_version"

# Ask for confirmation to merge into master with versioned commit
read -p "Merge into master and create release with commit: '🚀 $current_version'? (y/n): " confirmation

if [[ $confirmation == "y" || $confirmation == "Y" ]]; then
    # Perform the Git operations
    run_git_status
    add_commit "$current_version"
    merge_into_master

    # Tag the new version
    git tag "$current_version"
    git push --tags

    # Create the GitHub release
    create_github_release "$current_version"
else
    echo "Merge and release process canceled."
fi