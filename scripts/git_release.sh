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
    git commit -m "🚀 Bump version to $version"
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

# Fetch the latest changes from master
echo "Fetching the latest changes from master..."
git fetch origin master || error_exit "Failed to fetch master."

# Merge master into the current branch
current_branch=$(get_current_branch)
echo "Merging master into the current branch ($current_branch)..."
git merge origin/master || error_exit "Failed to merge master into $current_branch."

# Run git status
run_git_status

# Add and commit changes with the current version
current_version=$(get_package_version)
echo "Committing changes with version $current_version..."
add_commit "$current_version"

# Merge the current branch into master
echo "Merging $current_branch into master..."
git checkout master || error_exit "Failed to switch to master branch."
git merge --no-ff "$current_branch" || error_exit "Failed to merge $current_branch into master."
git push origin master || error_exit "Failed to push changes to master."
git checkout "$current_branch" || error_exit "Failed to switch back to $current_branch."

# Tag the new version
echo "Tagging the new version $current_version..."
git tag "$current_version" || error_exit "Failed to tag the new version."
git push --tags || error_exit "Failed to push tags."

# Create the GitHub release
create_github_release "$current_version"