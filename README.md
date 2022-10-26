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

| Operating System   | Minimum SDK      | Compile Target SDK   |
| :---               |    ----:         |               ---:   |
| `iOS`              | `13`             | —                    |
| `Android`          | `21`             | `33`                 |

| Push Provider                            | Supported Platforms     |
| :---                                     |               ----:     |
| `APNS (Apple Push Notification Service)` | `iOS`                   |
| `FCM (Firebase Cloud Messaging)`         | `iOS`, `Android`        |

- Most of this SDK depends on a Courier account: [`Create a Courier account here`](https://app.courier.com/signup)
- Testing push notifications requires a physical device. Simulators will not work.

## **Installation**

1. [`Install the package`](#1-install-the-package)
2. [`iOS Setup`](#2-ios-setup)
3. [`Android Setup`](#3-android-setup)
4. Linking APNS or FCM to your Courier workspace
4. Managing user state
5. Handling notification permissions
6. Sending a test push notification

Here is a link to the [example app](https://github.com/trycourier/courier-flutter/tree/master/example)

&emsp;

### **1. Install the package**

Run the following command at your project's root directory:

```
flutter pub add courier_flutter
```

&emsp;

### **2. iOS Setup**

⚠️ If you don't need push notification support on iOS, you can skip this step.

https://user-images.githubusercontent.com/6370613/198094477-40f22b1e-b3ad-4029-9120-0eee22de02e0.mov

1. From your projects root directory, run: `cd ios && pod update`
2. Open your iOS project and increase the min SDK target to iOS 13.0+
3. Change your `AppDelegate` to extend the `CourierFlutterDelegate`
    - This automatically syncs APNS tokens to Courier
    - Allows the Flutter SDK to handle when push notifications are delivered and clicked
4. Enable the "Push Notifications" capability

// Recommended Service

### **3. Android Setup**

⚠️ If you don't need push notification support on Android, you can skip this step.

https://user-images.githubusercontent.com/6370613/198107975-dbfc618c-85de-4938-8073-a670abb99486.mov

1. Open Android project
2. Add support for Jitpack to `android/build.gradle`
    - This is needed because the Courier Android SDK is hosted using Jitpack
    - Maven support will be coming later

```gradle
..
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

@SuppressLint("MissingFirebaseInstanceTokenRefresh")
class ExampleService: CourierService() {

    override fun showNotification(message: RemoteMessage) {
        super.showNotification(message)

        // TODO: This is where you will customize the notification that is shown to your users
        // The function below is used to get started quickly.
        // You likely do not want to use `message.presentNotification(...)`
        // Make sure you point the handling class back to MainActivity
        // For details on how to customize an Android notification, check here:
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
    ..
    <application>
        ..

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

### **3. Enable Push Notifications**

![Entitlement setup](https://github.com/trycourier/courier-ios/blob/master/push-notification-entitlement.gif)

1. Select your Xcode project file
2. Click your project Target
3. Click "Signing & Capabilities"
4. Click the small "+" to add a capability
5. Type "Push Notifications"
6. Press Enter

&emsp;

### **(Recommended) Setup the Courier Notification Service**

Without adding the Courier Notification Service your Courier workspace will not know when Courier delivers a push notification to the device.

Follow this tutorial to setup the service! (No Code Required 😄)

![Entitlement setup](https://github.com/trycourier/courier-ios/blob/master/service-extension-tutorial.gif)

1. Run the script located at Xcode > Package Dependencies > Courier > TemplateBuilder > make_template.sh (`sh make_template.sh`)
2. Go back to Xcode and click File > New > Target
3. Under iOS, filter for "Courier"
4. Click Next
5. Give the service extension a name (i.e. "CourierService")
6. Click Finish
7. Click on your project file
8. Under Targets, click on your new Target
9. Under the General tab > Frameworks and Libraries, click the "+" icon
10. Select the Courier package from the list under Courier Package > Courier

&emsp;

### **4. Manage Push Notification Tokens**

There are few different ways to manage user tokens. Here are 3 examples:

&emsp;

### 1. `CourierDelegate` Example (Automatically manage APNS tokens)

`CourierDelegate` automatically synchronizes APNS tokens and simplifies receiving and opening push notifications.

```swift
...
import Courier

class AppDelegate: CourierDelegate {

    ...

    override func pushNotificationDeliveredInForeground(message: [AnyHashable : Any], presentAs showForegroundNotificationAs: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // TODO: Remove this print
        print("Push Delivered")
        print(message)
        
        // ⚠️ Customize this to be what you would like
        // Pass an empty array to this if you do not want to use it
        showForegroundNotificationAs([.list, .badge, .banner, .sound])
        
    }
    
    override func pushNotificationClicked(message: [AnyHashable : Any]) {

        // TODO: Remove this print
        print("Push Clicked")
        print(message)

    }

}
```

&emsp;

### 2. Traditional APNS Example (Manually manage APNS tokens)

⚠️ Be sure to call both `Courier.shared.setCredentials(...)` and `Courier.shared.setPushToken(...)` in your implementation. Details can be found here: [Manage User Credentials](#2-manage-user-credentials)

```swift
import Courier

class AppDelegate: UIResponder, UIApplicationDelegate {

    ...

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        Task.init {
            do {
                try await Courier.shared.setAPNSToken(deviceToken)
            } catch {
                print(error)
            }
        }

    }

}
```

&emsp;

### 3. Traditional FCM Example (Manually manage FCM tokens)

⚠️ Be sure to call both `Courier.shared.setCredentials(...)` and `Courier.shared.setPushToken(...)` in your implementation. Details can be found here: [Manage User Credentials](#2-manage-user-credentials)

```swift
import Courier

extension AppDelegate: MessagingDelegate {
  
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {

        if let token = fcmToken {

            Task.init {
                do {
                    try await Courier.shared.setFCMToken(token)
                } catch {
                    print(error)
                }
            }

        }

    }

}
```

_Other examples can be found here: [More Examples](https://github.com/trycourier/courier-ios/tree/master/Examples)_

&emsp;

### **5. Configure a Provider**

To get pushes to appear, add support for the provider you would like to use. Checkout the following tutorials to get a push provider setup.

- [Apple Push Notification Service](https://www.courier.com/docs/guides/providers/push/apple-push-notification)
- [Firebase Cloud Messaging](https://www.courier.com/docs/guides/providers/push/firebase-fcm/)

&emsp;

### **6. Signing Users Out**

Best user experience practice is to synchronize the current user's push notification tokens and the user's state.

This should be called where you normally manage your user's state.

```swift
import Courier

func signOut() {
    
    Task.init {

        try await Courier.shared.signOut()

    }
    
}
```

&emsp;

### **Bonus! Sending a Test Push Notification**

⚠️ This is only for testing purposes and should not be in your production app.

```swift
import Courier

func sendTestMessage() {
    
    Task.init {

        let userId = "example_user_id"
        
        try await Courier.shared.sendPush(
            authKey: "your_api_key_that_should_not_stay_in_your_production_app",
            userId: userId,
            title: "Test message!",
            message: "Chrip Chirp!",
            providers: [.apns, .fcm]
        )

    }
    
}
```

&emsp;

### **Share feedback with Courier**

We want to make this the best SDK for managing notifications! Have an idea or feedback about our SDKs? Here are some links to contact us:

- [Courier Feedback](https://feedback.courier.com/)
- [Courier iOS Issues](https://github.com/trycourier/courier-ios/issues)


