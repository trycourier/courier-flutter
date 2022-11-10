# Welcome to Courier React Native contributing guide

## Getting Started

1. From root, run: `flutter pub get`
2. Navigate to `example/lib`
3. Create a `env.dart` file and create a class named `Env`
4. Copy content from `env.sample.dart` and paste in `env.dart`
5. Drag and drop your google-services.json file into `example/android/android/app` (Needed for Firebase FCM testing)
6. navigate to `example/ios`, double click on `Runner.xcworkspace`
7. select Runner in xcode click on `add files to "Runner"` and add `GoogleService-Info.plist`

From here, you are all set to start working on the package! 🙌

## Testing & Debugging

While developing, you can run the [example app](/example/) to test your changes. Any changes you make in your library's dart code will be reflected in the example app without a rebuild. If you change any native code, then you'll need to rebuild the example app.

To run the Flutter example app navigate open terminal, navigate to example. use:

```sh
flutter run
```

To debug the Android package:
1. Run `yarn example android` from root
2. Open `example/android` in Android Studio
3. Click Debug

To debug the iOS package:
`TODO`

