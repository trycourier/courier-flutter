# Courier Flutter Overview

```dart
Courier.shared.isDebugging = true;

final userId = await Courier.shared.userId;

await Courier.shared.signIn(
    accessToken: 'asdf...',
    userId: 'example_user_id',
);

await Courier.shared.signOut();

Courier.shared.iOSForegroundNotificationPresentationOptions = [
    iOSNotificationPresentationOption.banner,
    iOSNotificationPresentationOption.sound,
    iOSNotificationPresentationOption.list,
    iOSNotificationPresentationOption.badge,
];

final currentPermissionStatus = await Courier.shared.getNotificationPermissionStatus();
final requestPermissionStatus = await Courier.shared.requestNotificationPermission();

await Courier.shared.setFcmToken(token: 'asdf...');

final fcmToken = await Courier.shared.fcmToken;
final apnsToken = await Courier.shared.apnsToken;

Courier.shared.onPushNotificationDelivered = (push) {
    print(push);
};

Courier.shared.onPushNotificationClicked = (push) {
    print(push);
};

final messageId = await Courier.shared.sendPush(
    authKey: 'asdf...',
    userId: 'example_user_id',
    title: 'Hey! 👋',
    body: 'Courier is awesome!!',
    isProduction: false,
    providers: [CourierProvider.apns, CourierProvider.fcm],
);

```

# Requirements & Support

| Operating System | Min SDK | Compile SDK | Firebase Cloud Messaging | Apple Push Notification Service | Expo | OneSignal | Courier Inbox | Courier Toast |
| :-- |     --: |         --: |                      --: |                             --: |  --: |       --: |           --: |           --: |
| `iOS` |  `13` |           — |                       ✅ |                               ✅ |   ❌ |         ❌ |            ❌ |            ❌ |
| `Android` | `21` |     `33` |                       ✅ |                               ❌ |   ❌ |         ❌ |            ❌ |            ❌ |

> Most of this SDK depends on a Courier account: [`Create a Courier account here`](https://app.courier.com/signup)

> Testing push notifications requires a physical device. Simulators will not work.

# **Installation**

>
> Link to [`Example App`](https://github.com/trycourier/courier-flutter/tree/master/example)
>

1. [`Install the package`](#1-install-the-package)
2. [`iOS Setup`](#2-ios-setup)
3. [`Android Setup`](#3-android-setup)
5. [`Configure Push Provider`](#4-configure-push-provider)
6. [`Managing User State`](#5-managing-user-state)
7. [`Testing Push Notifications`](#6-testing-push-notifications)

&emsp;

## **1. Install the package**

Run the following command at your project's root directory:

```
flutter pub add courier_flutter
```

&emsp;

## **2. iOS Setup**

> If you don't need push notification support on iOS, you can skip this step.

https://user-images.githubusercontent.com/6370613/198094477-40f22b1e-b3ad-4029-9120-0eee22de02e0.mov

1. Open your iOS project and increase the min SDK target to iOS 13.0+
2. From your Flutter project's root directory, run: `cd ios && pod update`
3. Change your `AppDelegate` to extend the `CourierFlutterDelegate` and add `import courier_flutter` to the top of your `AppDelegate` file
    - This automatically syncs APNS tokens to Courier
    - Allows the Flutter SDK to handle when push notifications are delivered and clicked
4. Enable the "Push Notifications" capability

### **Add the Notification Service Extension (Recommended)**

To make sure Courier can track when a notification is delivered to the device, you need to add a Notification Service Extension. Here is how to add one.


https://user-images.githubusercontent.com/29832989/214159327-01ef662f-094b-455c-9ae8-019c94121ba8.mov


1. Download and Unzip the Courier Notification Service Extension: [`CourierNotificationServiceTemplate.zip`](https://github.com/trycourier/courier-notification-service-extension-template/archive/refs/heads/main.zip)
2. Open the folder in terminal and run `sh make_template.sh`
    - This will create the Notification Service Extension on your mac to save you time
3. Open your iOS app in Xcode and go to File > New > Target
4. Select "Courier Service" and click "Next"
5. Give the Notification Service Extension a name (i.e. "CourierService"), select `Courier_iOS` as the Package, and click "Finish"
6. Click "Cancel" on the next popup
    - You do NOT need to click "Activate" here. Your Notification Service Extension will still work just fine.
7. Select Service Extension (i.e. "CourierService"), select general, change deployment sdk to min SDK target to iOS 13.0+
7. Open your `Podfile` and add the following snippet to the end of your Podfile
    - This will link the `Courier-iOS` pod to your Notification Service Extension

```
target 'CourierService' do
  use_frameworks!
  pod 'Courier-iOS'
end
```

8. From the root of your Flutter app, run: `cd ios && pod install`

&emsp;

## **3. Android Setup**

> If you don't need push notification support on Android, you can skip this step.

https://user-images.githubusercontent.com/6370613/198111372-09a29aba-6507-4cf7-a59d-87e8df2ba492.mov

1. Open Android project
2. Add support for Jitpack to `android/build.gradle`
    - This is needed because the Courier Android SDK is hosted using Jitpack
    - Maven Central support will be coming later

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' } // Add this line
    }
}
```

3. Update your `app/build.gradle` to support the min and compile SDKs
    - `minSdkVersion 21`
    - `compileSdkVersion 33`
4. Run Gradle sync
5. Change your `MainActivity` to extend the `CourierFlutterActivity`
    - This allows Courier to handle when push notifications are delivered and clicked
6. Setup a new Notification Service by creating a new file and pasting the code below in it
    - This allows you to present a notification to your user when a new notification arrives

```kotlin
import android.annotation.SuppressLint
import com.courier.android.notifications.presentNotification
import com.courier.android.service.CourierService
import com.google.firebase.messaging.RemoteMessage

// This is safe. `CourierService` will automatically handle token refreshes.
@SuppressLint("MissingFirebaseInstanceTokenRefresh")
class YourNotificationService: CourierService() {

    override fun showNotification(message: RemoteMessage) {
        super.showNotification(message)

        // TODO: This is where you will customize the notification that is shown to your users
        // The function below is used to get started quickly.
        // You likely do not want to use `message.presentNotification(...)`
        // For Flutter, you likely do not want to change the handlingClass
        // More information on how to customize an Android notification here:
        // https://developer.android.com/develop/ui/views/notifications/build-notification

        message.presentNotification(
            context = this,
            handlingClass = MainActivity::class.java,
            icon = android.R.drawable.ic_dialog_info
        )

    }

}
```



7. Add the Notification Service entry in your `AndroidManifest.xml` file

```xml
<manifest>
    <application>

        <activity>
            ..
        </activity>

        // Add this 👇
        <service
            android:name=".YourNotificationService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>
        // Add this 👆

        ..

    </application>
</manifest>
```

&emsp;

## **4. Configure Push Provider**

> If you don't need push notification support, you can skip this step.

To get push notification to appear in your app, add support for the provider you would like to use:
- [`APNS (Apple Push Notification Service)`](https://www.courier.com/docs/guides/providers/push/apple-push-notification)
- [`FCM (Firebase Cloud Messaging)`](https://www.courier.com/docs/guides/providers/push/firebase-fcm/)

&emsp;

## **5. Managing User State**

Best user experience practice is to synchronize the current user's push notification tokens and the user's state. Courier does most of this for you automatically!

> You can use a Courier Auth Key [`found here`](https://app.courier.com/settings/api-keys) when developing.

> When you are ready for production release, you should be using a JWT as the `accessToken`.
> Here is more info about [`Going to Production`](#going-to-production)

Place these functions where you normally manage your user's state:
```dart
// Saves accessToken and userId to native level local storage
// This will persist between app sessions
await Courier.shared.signIn(
    accessToken: accessToken,
    userId: userId,
);

await Courier.shared.signOut();
```

If you followed the steps above:
- APNS tokens on iOS will automatically be synced to Courier
- FCM tokens on Android will automatically be synced to Courier

If you want FCM tokens to sync to Courier on iOS:

1. Add the following Flutter packages to your project
    - [`firebase_core`](https://pub.dev/packages/firebase_core)
    - [`firebase_messaging`](https://pub.dev/packages/firebase_messaging)

2. Add code to manually sync FCM tokens
```dart
final fcmToken = await FirebaseMessaging.instance.getToken();
if (fcmToken != null) {
    await Courier.shared.setFcmToken(token: fcmToken);
}

// Handle FCM token refreshes
FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    Courier.shared.setFcmToken(token: fcmToken);
});
```

&emsp;

## **6. Testing Push Notifications**

> If you don't need push notification support, you can skip this step.

Courier allows you to send a push notification directly from the SDK to a user id. No tokens juggling or backend needed!

```dart
final notificationPermission = await Courier.shared.getNotificationPermissionStatus();
print(notificationPermission);

// Notification permissions must be `authorized` on iOS to receive pushes
final requestedNotificationPermission = await Courier.shared.requestNotificationPermission();
print(requestedNotificationPermission);

// This is how iOS will show the notification when the app is in the foreground
// Passing [] will not present anything
// `Courier.shared.onPushNotificationDelivered` will still get called
Courier.shared.iOSForegroundNotificationPresentationOptions = [
    iOSNotificationPresentationOption.banner,
    iOSNotificationPresentationOption.sound,
    iOSNotificationPresentationOption.list,
    iOSNotificationPresentationOption.badge,
];

// Will be called if the app is in the foreground and a push notification arrives
Courier.shared.onPushNotificationDelivered = (push) {
    ...
};

// Will be called when a user clicks a push notification
Courier.shared.onPushNotificationClicked = (push) {
    ...
};

// Sends a test push
final messageId = await Courier.shared.sendPush(
    authKey: 'a_courier_auth_key_that_should_only_be_used_for_testing',
    userId: 'example_user',
    title: 'Chirp Chrip!',
    body: 'Hello from Courier 🐣',
    isProduction: false, // This only affects APNS pushes. false == sandbox / true == production
    providers: [CourierProvider.apns, CourierProvider.fcm],
);
```

&emsp;

## **Going to Production**

For security reasons, you should not keep your `authKey` (which looks like: `pk_prod_ABCD...`) in your production app. The `authKey` is safe to test with, but you will want to use an `accessToken` in production.

To create an `accessToken`, call this: 

```curl
curl --request POST \
     --url https://api.courier.com/auth/issue-token \
     --header 'Accept: application/json' \
     --header 'Authorization: Bearer $YOUR_AUTH_KEY' \
     --header 'Content-Type: application/json' \
     --data
 '{
    "scope": "user_id:$YOUR_USER_ID write:user-tokens",
    "expires_in": "$YOUR_NUMBER days"
  }'
```

Or generate one here:
[`Issue Courier Access Token`](https://www.courier.com/docs/reference/auth/issue-token/)

> This request to issue a token should likely exist in a separate endpoint served on your backend.

&emsp;

## **Share feedback with Courier**

We want to make this the best SDK for managing notifications! Have an idea or feedback about our SDKs? Here are some links to contact us:

- [Courier Feedback](https://feedback.courier.com/)
- [Courier Flutter Issues](https://github.com/trycourier/courier-flutter/issues)

==============================================================================================================================

<img width="1000" alt="banner" src="https://user-images.githubusercontent.com/6370613/232106835-cf4e584c-9453-40bf-88be-7bf8dfe59886.png">

&emsp;

# Requirements & Support

&emsp;

<table>
    <thead>
        <tr>
            <th width="940px" align="left">Requirements</th>
            <th width="120px" align="center"></th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">Courier Account</td>
            <td align="center">
                <a href="https://app.courier.com/channels/courier">
                    <code>Sign Up</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">Minimum iOS SDK Version</td>
            <td align="center">
                <code>13.0</code>
            </td>
        </tr>
    </tbody>
</table>

&emsp;

<table>
    <thead>
        <tr>
            <th width="940px" align="left">Languages</th>
            <th width="120px" align="center"></th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">Swift</td>
            <td align="center">✅</td>
        </tr>
        <tr width="600px">
            <td align="left">Objective-C</td>
            <td align="center">✅</td>
        </tr>
    </tbody>
</table>

&emsp;

<table>
    <thead>
        <tr>
            <th width="940px" align="left">Package Manager</th>
            <th width="120px" align="center"></th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios#using-swift-package-manager">
                    <code>Swift Package Manager</code>
                </a>
            </td>
            <td align="center">✅</td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios#using-cocoapods">
                    <code>Cocoapods</code>
                </a>
            </td>
            <td align="center">✅</td>
        </tr>
    </tbody>
</table>

&emsp;

# Installation

## Using Swift Package Manager

https://user-images.githubusercontent.com/29832989/202578202-32c0ebf7-c11f-46c0-905a-daa8fc3ba8bd.mov

1. Open your iOS project and increase the min SDK target to iOS 13.0+
2. In your Xcode project, go to File > Add Packages
3. Paste the following url in "Search or Enter Package URL"

```
https://github.com/trycourier/courier-ios
```

## Using Cocoapods

1. Open your iOS project and increase the min SDK target to iOS 13.0+
2. Update Podfile

```ruby
platform :ios, '13.0'
..
target 'YOUR_TARGET_NAME' do
    ..
    pod 'Courier_iOS'
    ..
end
```

3. Open terminal in root directory and run

```sh
pod install
```

&emsp;

# Getting Started

These are all the available features of the SDK.

<table>
    <thead>
        <tr>
            <th width="25px"></th>
            <th width="250px" align="left">Feature</th>
            <th width="750px" align="left">Description</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="center">
                1
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Manages user credentials between app sessions. Required if you would like to use <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md"><code>Courier Inbox</code></a> and <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md"><code>Push Notifications</code></a>.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                2
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Inbox.md">
                    <code>Courier Inbox</code>
                </a>
            </td>
            <td align="left">
                An in-app notification center you can use to notify your users. Comes with a prebuilt UI and also supports fully custom UIs.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                3
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/PushNotifications.md">
                    <code>Push Notifications</code>
                </a>
            </td>
            <td align="left">
                Automatically manages push notification device tokens and gives convenient functions for handling push notification receiving and clicking.
            </td>
        </tr>
        <tr width="600px">
            <td align="center">
                4
            </td>
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Preferences.md">
                    <code>Preferences</code>
                </a>
            </td>
            <td align="left">
                Allow users to update which types of notifications they would like to receive.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Example Projects

Several common starter projects using the SDK.

<table>
    <thead>
        <tr>
            <th width="450px" align="left">Project Link</th>
            <th width="200px" align="center">UI Framework</th>
            <th width="200px" align="center">Package Manager</th>
            <th width="200px" align="center">Language</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/tree/master/Example">
                    <code>Example</code>
                </a>
            </td>
            <td align="center"><code>UIKit</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center"><code>Swift</code></td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/tree/master/Pod-Example">
                    <code>Example</code>
                </a>
            </td>
            <td align="center"><code>UIKit</code></td>
            <td align="center"><code>Cocoapods</code></td>
            <td align="center"><code>Swift</code></td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-ios/tree/master/SwiftUI-Example">
                    <code>Example</code>
                </a>
            </td>
            <td align="center"><code>SwiftUI</code></td>
            <td align="center"><code>Swift</code></td>
            <td align="center"><code>Swift</code></td>
        </tr>
    </tbody>
</table>

&emsp;

# **Share feedback with Courier**

We are building the best SDKs for handling notifications! Have an idea or feedback about our SDKs? Here are some links to contact us:

- [Courier Feedback](https://feedback.courier.com/)
- [Courier iOS Issues](https://github.com/trycourier/courier-ios/issues)

