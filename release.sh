# Install Github CLI if needed
brew install gh
gh auth login

# Install yq for parsing yml
brew install python-yq

# Get the package version from the pubspec
PACKAGE_VERSION=$(yq .version pubspec.yaml | tr -d '"')
echo $PACKAGE_VERSION

# Add the tag
git tag $PACKAGE_VERSION
git push --tags

# gh release create
gh release create $PACKAGE_VERSION --generate-notes

# Publish to pub.dev
flutter pub publish