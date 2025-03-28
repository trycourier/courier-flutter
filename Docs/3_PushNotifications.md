<img width="1040" alt="banner-flutter-push" src="https://github.com/trycourier/courier-flutter/assets/6370613/45e4a58b-2bad-49fb-850d-244be3ffd0d7">

&emsp;

# Push Notifications

The easiest way to support push notifications in your app.

## Features

<table>
    <thead>
        <tr>
            <th width="350px" align="left">Feature</th>
            <th width="600px" align="left">Description</th>
            <th width="100px" align="center">iOS</th>
            <th width="100px" align="center">Android</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <code>Automatic Token Management</code>
            </td>
            <td align="left">
                Push notification tokens automatically sync to the Courier studio.
            </td>
            <td align="center">
              ✅
            </td>
            <td align="center">
              ✅
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <code>Notification Tracking</code>
            </td>
            <td align="left">
                Track if your users received or clicked your notifications even if your app is not runnning or open.
            </td>
            <td align="center">
              ✅
            </td>
            <td align="center">
              ✅
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <code>Permission Requests & Checking</code>
            </td>
            <td align="left">
                Simple functions to request and check push notification permission settings.
            </td>
            <td align="center">
              ✅
            </td>
            <td align="center">
              ❌
            </td>
        </tr>
    </tbody>
</table>

&emsp;

## Requirements

<table>
    <thead>
        <tr>
            <th width="300px" align="left">Requirement</th>
            <th width="750px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-react-native/blob/master/Docs/1_Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Needs Authentication to sync push notification device tokens to the current user and Courier.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/integrations/catalog">
                    <code>A Configured Provider</code>
                </a>
            </td>
            <td align="left">
                Courier needs to know who to route the push notifications to so your users can receive them.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

<table>
    <thead>
        <tr>
            <th width="700px" align="left">Provider</th>
            <th width="200px" align="center">iOS Token Sync</th>
            <th width="200px" align="center">Android Token Sync</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/apn">
                    <code>(APNS) - Apple Push Notification Service</code>
                </a>
            </td>
            <td align="center">
                <code>Automatic</code>
            </td>
            <td align="center">
                <code>Not Supported</code>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/firebase-fcm">
                    <code>(FCM) - Firebase Cloud Messaging</code>
                </a>
            </td>
            <td align="center">
                <code>Manual</code>
            </td>
            <td align="center">
                <code>Automatic</code>
            </td>
        </tr>
    </tbody>
</table>

&emsp;

# Manual Token Syncing

If you want to manually sync tokens, you can do this here and skip the remaining parts of the setup guide. You will need this step if you want to use Firebase Cloud Messaging for iOS.

```dart
// Supported Courier providers
await Courier.shared.setTokenForProvider(token: 'fcmToken', provider: CourierPushProvider.firebaseFcm);
final fcmToken = await Courier.shared.getTokenForProvider(provider: CourierPushProvider.firebaseFcm);

// Unsupported Courier providers
await Courier.shared.setToken(token: 'token_value', provider: 'YOUR_PROVIDER');
final token = await Courier.shared.getToken(provider: 'YOUR_PROVIDER');
```

&emsp;

# iOS Setup

<table>
    <thead>
        <tr>
            <th width="300px" align="left">Requirement</th>
            <th width="750px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://developer.apple.com/account/">
                    <code>Apple Developer Membership</code>
                </a>
            </td>
            <td align="left">
                Apple requires all iOS developers to have a membership so you can manage your push notification certificates.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                A phyical iOS device
            </td>
            <td align="left">
                Although you can setup the Courier SDK without a device, a physical device is the only way to fully ensure push notification tokens and notification delivery is working correctly. Simulators are not reliable.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

## **Automatically Sync Tokens (iOS)**

https://user-images.githubusercontent.com/6370613/198094477-40f22b1e-b3ad-4029-9120-0eee22de02e0.mov

1. Open your iOS project and increase the min SDK target to iOS 13.0+
2. From your Flutter project's root directory, run: `cd ios && pod update`
3. Change your `AppDelegate` to extend the `CourierFlutterDelegate` and add `import courier_flutter` to the top of your `AppDelegate` file
    - This automatically syncs APNS tokens to Courier
    - Allows the Flutter SDK to handle when push notifications are delivered and clicked
4. Enable the "Push Notifications" capability

### **2. Add the Notification Service Extension (Recommended)**

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

# Android Setup 

<table>
    <thead>
        <tr>
            <th width="300px" align="left">Requirement</th>
            <th width="750px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://firebase.google.com/">
                    <code>Firebase Account</code>
                </a>
            </td>
            <td align="left">
                Needed to send push notifications out to your Android devices. Courier recommends you do this for the most ideal developer experience.
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                A phyical Android device
            </td>
            <td align="left">
                Although you can setup the Courier SDK without a physical device, a physical device is the best way to fully ensure push notification tokens and notification delivery is working correctly. Simulators are not reliable.
            </td>
        </tr>
    </tbody>
</table>

## **Automatically Sync Tokens (Android)**

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
5. Change your `MainActivity` to extend the `CourierFlutterActivity` (or `CourierFlutterFragmentActivity` if you're using a `FragmentActivity`)
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

## **Support Notifications**

```dart
// Support the type of notifications you want to show on iOS
Courier.setIOSForegroundPresentationOptions(options: [
    iOSNotificationPresentationOption.banner,
    iOSNotificationPresentationOption.sound,
    iOSNotificationPresentationOption.list,
    iOSNotificationPresentationOption.badge,
]);

// Request / Get Notification Permissions
final currentPermissionStatus = await Courier.getNotificationPermissionStatus();
final requestPermissionStatus = await Courier.requestNotificationPermission();

// Handle push events
final pushListener = await Courier.shared.addPushListener(
  onPushClicked: (push) {
    print(push);
  },
  onPushDelivered: (push) {
    print(push);
  },
);

// Remove the listener where makes sense to you
// i.e. inside of dispose();
pushListener.remove();
```

## **Send a Message**

<table>
    <thead>
        <tr>
            <th width="600px" align="left">Provider</th>
            <th width="200px" align="center">Link</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/apn">
                    <code>(APNS) - Apple Push Notification Service</code>
                </a>
            </td>
            <td align="center">
                <a href="https://www.courier.com/docs/platform/channels/push/apple-push-notification/#sending-messages">
                    <code>Testing Docs</code>
                </a>
            </td>
        </tr>
        <tr width="600px">
            <td align="left">
                <a href="https://app.courier.com/channels/firebase-fcm">
                    <code>(FCM) - Firebase Cloud Messaging</code>
                </a>
            </td>
            <td align="center">
                <a href="https://www.courier.com/docs/platform/channels/push/firebase-fcm/#sending-messages">
                    <code>Testing Docs</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

---

👋 `TokenManagement APIs` can be found <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/5_Client.md#token-management-apis"><code>here</code></a>
