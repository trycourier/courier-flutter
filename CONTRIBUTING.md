# Courier Flutter Contribution Guide

## Getting Started

1. Clone the repo and open `courier-flutter` in your IDE
2. Make sure you have your `example/lib/env.dart` configured with your proper values
3. Run `pub get` from root to install all dependencies
4. Run `example/lib/main.dart` to run the example app

From here, you are all set to start working on the package! 🙌

## Testing, Debugging & Release

To make package changes there are 3 areas to keep in mind:
1. The plugin code itself lives in `lib`. This code is used to interface with the native sides of the SDK
2. `android` contains all flutter specific android code
3. `ios` contains all flutter specific ios code

The Flutter SDK, for the most part, simply depends on changes made to the base level iOS and Android SDKs.

If you make a change to a base level SDK and want it to be reflected in the Flutter SDK.
1. Update the `ios/courier_flutter.podspec` `Courier-iOS` dependency to reflect the latest base SDK version
2. Update the `android/build.gradle` `com.github.trycourier:courier-android:xxx` dependency to reflect the latest base SDK version
3. If ready for release, be sure to test the app on a device and then run `sh release.sh` from root

To run automated tests:
1. Run `test/courier_flutter_test.dart`

To release a new build of the SDK:
1. Change the pubspec.yaml version to the version you want to release
2. Run `sh release.sh` from root
	- Required access to create builds in Github with Github CLI
	- Will push new release to pub.dev
