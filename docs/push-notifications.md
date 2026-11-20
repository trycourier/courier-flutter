<!-- Generated from https://www.courier.com/docs/guides/set-up-mobile-push by mintlify-docs. Edit the docs source, not this file. -->

# Set up mobile push

> Connect FCM and APNs, sync device tokens with the mobile SDK on iOS, Android, React Native, or Flutter, send a test push, and track delivery and clicks.

Source: https://www.courier.com/docs/guides/set-up-mobile-push

A push needs three things: a provider connected in Courier, a device token on the user, and a send.

The Courier mobile SDK handles the token.

## Prerequisites

- [A Courier account](https://app.courier.com/) and an [API key](https://app.courier.com/settings/api-keys)
- Provider credentials: a Firebase service account JSON for Android, an APNs `.p8` key for iOS, or both
- A physical device to test on. On a Mac with Apple silicon, the iOS Simulator also receives push.

## Set up your app

### Connect your push providers

Open [Integrations](https://app.courier.com/integrations) and switch to the environment you send from. Providers are per environment, so one connected in test doesn't exist in production.

- Android needs [Firebase Cloud Messaging](https://www.courier.com/docs/integrations/push/firebase-fcm). Generate a private key under **Service Accounts** in Firebase, paste it into **Service Account JSON**, and click **Install Provider**.
- iOS needs [APNs](https://www.courier.com/docs/integrations/push/apple-push-notification). Enter your **Key Id**, `.p8` **Key**, **Team Id**, and **Topic (App Bundle Id)**, then click **Install Provider**.

### Install the SDK

```bash
flutter pub add courier_flutter
```

### Set up the iOS project

Set your deployment target to iOS 15.0 or later, then run `cd ios && pod update`.

In Xcode, select your target, open **Signing & Capabilities**, and add **Push Notifications**. Optionally add a [Notification Service Extension](https://www.courier.com/docs/sdk-libraries/ios#notification-service-extension) to track delivery while the app is closed.

In `ios/Runner/AppDelegate.swift`, inherit from `CourierFlutterDelegate`. This is what syncs the APNs token.

```swift
import Flutter
import courier_flutter

@main
@objc class AppDelegate: CourierFlutterDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Set up the Android project

Add the Jitpack repository to `android/build.gradle`, and set `minSdkVersion 23` in `android/app/build.gradle`. Declare the Google Services plugin version in `android/settings.gradle` (`id "com.google.gms.google-services" version "4.4.2" apply false`), apply it alongside Firebase, and place `google-services.json` in `android/app/`.

```gradle
plugins {
    id "com.google.gms.google-services"
}

dependencies {
    implementation platform("com.google.firebase:firebase-bom:34.13.0")
    implementation "com.google.firebase:firebase-messaging"
}
```

Extend `CourierFlutterActivity` in `MainActivity`.

```kotlin
import com.courier.courier_flutter.CourierFlutterActivity

class MainActivity : CourierFlutterActivity() {
    // ...
}
```

Then subclass `FirebaseMessagingService` to sync the FCM token and present notifications.

```kotlin
import com.courier.android.Courier
import com.courier.android.notifications.CourierPushNotificationIntent
import com.courier.android.notifications.presentNotification
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class YourNotificationService : FirebaseMessagingService() {

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)

        val notificationIntent = CourierPushNotificationIntent(
            context = this,
            target = MainActivity::class.java,
            payload = message
        )

        notificationIntent.presentNotification(
            title = message.data["title"] ?: message.notification?.title,
            body = message.data["body"] ?: message.notification?.body
        )

        Courier.onMessageReceived(message.data)
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Courier.onNewToken(token)
    }
}
```

Register the service in `android/app/src/main/AndroidManifest.xml`.

```xml
<service
    android:name=".YourNotificationService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### Sign in the user

Courier ties every token to a signed-in user, so no push reaches the device until you call `signIn`. Pass the `user_id` you send to, plus a JWT your backend mints (see [Authenticate users](https://www.courier.com/docs/in-app/authenticate-users)).

> **Note:** **The `user_id` is yours, not Courier's.**
> Use whatever your app already calls this user, such as a database id or your auth provider's `sub`. Nothing has to exist in Courier first, since signing in registers the user and their device tokens. With no auth yet, any stable string works, as long as you reuse it on every launch and send to that same id.

```dart
await Courier.shared.signIn(userId: "user_123", accessToken: jwt);
```

Call it once, right after your own login resolves. Credentials persist on the device, so app launches don't need it. Call `signOut` on logout to delete that device's tokens from Courier.

### Request notification permission

iOS shows the system dialog once. Android 13 and later needs the permission declared in `android/app/src/main/AndroidManifest.xml`, and the request is a no-op below API 33.

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

```dart
final status = await Courier.requestNotificationPermission();
```

Reading the status, and getting the user back after they deny: [Notification permissions](https://www.courier.com/docs/send/push/overview#notification-permissions).

Next: [send a test push](https://www.courier.com/docs/guides/set-up-mobile-push#send-a-test-push) to the `user_id` you signed in.

> **Info:** The SDK holds a token it receives before anyone signs in and uploads it at sign-in, so you never race the callback. Signing in a different user signs the previous one out first.

> **Tip:** To register tokens from a server or outside the SDK, use the [Device Tokens API](https://www.courier.com/docs/api-reference/device-tokens/add-a-token-to-a-user) directly. The [push notifications overview](https://www.courier.com/docs/integrations/push/overview) covers the token model.

## Send a test push

First [design a template](https://www.courier.com/docs/design/templates/overview) with a **Push** channel and publish it. Then send it to the `user_id` you signed in, routing to your push providers by their provider keys, `apn` and `firebase-fcm`. Courier resolves the user's tokens for each provider.

**Node.js**

```javascript
import Courier from '@trycourier/courier';

const client = new Courier({
  apiKey: process.env['COURIER_API_KEY'],
});

const { requestId } = await client.send.message({
  message: {
    to: { user_id: 'user_123' },
    template: 'nt_01kx4h2jdafq8bk9aftxak4b40',
    routing: { method: 'single', channels: ['apn', 'firebase-fcm'] },
  },
});

console.log(requestId);
```

**Python**

```python
import os
from courier import Courier

client = Courier(
    api_key=os.environ.get("COURIER_API_KEY"),
)
response = client.send.message(
    message={
        "to": {"user_id": "user_123"},
        "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
        "routing": {"method": "single", "channels": ["apn", "firebase-fcm"]},
    },
)
print(response.request_id)
```

**cURL**

```bash
curl -X POST https://api.courier.com/send \
  -H "Authorization: Bearer $COURIER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "to": { "user_id": "user_123" },
      "template": "nt_01kx4h2jdafq8bk9aftxak4b40",
      "routing": { "method": "single", "channels": ["apn", "firebase-fcm"] }
    }
  }'
```

**Ruby**

```ruby
require "courier"

courier = Courier::Client.new(api_key: ENV["COURIER_API_KEY"])

response = courier.send_.message(
  message: {
    to: { user_id: "user_123" },
    template: "nt_01kx4h2jdafq8bk9aftxak4b40",
    routing: { method: "single", channels: ["apn", "firebase-fcm"] }
  }
)

puts(response)
```

**Go**

```go
response, err := client.Send.Message(context.TODO(), courier.SendMessageParams{
	Message: courier.SendMessageParamsMessage{
		To: courier.SendMessageParamsMessageToUnion{
			OfUserRecipient: &shared.UserRecipientParam{UserID: courier.String("user_123")},
		},
		Template: courier.String("nt_01kx4h2jdafq8bk9aftxak4b40"),
		Routing: courier.SendMessageParamsMessageRouting{
			Method:   string(shared.MessageRoutingMethodSingle),
			Channels: []shared.MessageRoutingChannelUnionParam{
				{OfString: courier.String("apn")},
				{OfString: courier.String("firebase-fcm")},
			},
		},
	},
})
```

**Java**

```java
SendMessageParams params = SendMessageParams.builder()
    .message(SendMessageParams.Message.builder()
        .to(JsonValue.from(java.util.Map.of("user_id", "user_123")))
        .template("nt_01kx4h2jdafq8bk9aftxak4b40")
        .routing(JsonValue.from(java.util.Map.of(
            "method", "single",
            "channels", java.util.List.of("apn", "firebase-fcm"))))
        .build())
    .build();
client.send().message(params);
```

**PHP**

```php
$response = $client->send->message(
  message: [
    'to' => ['userID' => 'user_123'],
    'template' => 'nt_01kx4h2jdafq8bk9aftxak4b40',
    'routing' => ['method' => 'single', 'channels' => ['apn', 'firebase-fcm']],
  ],
);
```

**C#**

```csharp
SendMessageParams parameters = new()
{
    Message = new()
    {
        To = new UserRecipient { UserID = "user_123" },
        Template = "nt_01kx4h2jdafq8bk9aftxak4b40",
        Routing = new Routing { Method = Method.Single, Channels = ["apn", "firebase-fcm"] },
    },
};

await client.Send.Message(parameters);
```

**CLI**

```bash
courier send message \
  --api-key "$COURIER_API_KEY" \
  --message '{"to":{"user_id":"user_123"},"template":"nt_01kx4h2jdafq8bk9aftxak4b40","routing":{"method":"single","channels":["apn","firebase-fcm"]}}'
```

**MCP**

```text
With Courier MCP, send my nt_01kx4h2jdafq8bk9aftxak4b40 template to user_123 through APNs, falling back to FCM.
```

## Verify

The notification appears on the device you registered. For a silent payload, confirm your app handled it in the background instead. Open the message in [Logs](https://app.courier.com/logs). A delivered push shows the provider it went through and the token it targeted. If it didn't deliver, the log names the reason: no token, expired token, or provider not configured.

> **Note:** `channels: ["apn", "firebase-fcm"]` tries APNs, then FCM, and stops at the first success. To reach both iOS and Android on one send, route to `push` and set `channels.push` to `{ "routing_method": "all", "providers": ["apn", "firebase-fcm"] }`. Naming the providers keeps Courier Inbox, which is also a push provider, out of the send. See [reach every device on push](https://www.courier.com/docs/send/routing#reach-every-device-on-push).

## Delivery and click tracking

Courier tracks push delivery and clicks for you. Every push carries a `trackingUrl`, and the SDK posts back to it as the notification arrives and again when the user taps it. Both events land in [Logs](https://app.courier.com/logs) with no code of your own.

The wiring from [Set up your app](https://www.courier.com/docs/guides/set-up-mobile-push#set-up-your-app) is what reports them:

| Event | Reported by | Works when |
| :-- | :-- | :-- |
| Delivered (iOS) | `CourierDelegate` | your app is in the foreground |
| Delivered (iOS) | the Notification Service Extension | your app is backgrounded or closed |
| Delivered (Android) | `FirebaseMessagingService` | any state, including killed |
| Clicked | `CourierDelegate`, `CourierActivity` | any state |

Two provider defaults keep that accurate, and a new workspace has both on. **Attach Mutable Content** on [APNs](https://www.courier.com/docs/integrations/push/apple-push-notification) is what lets the extension run at all. **Apply Recommended Courier Mobile SDK Formatting** on [FCM](https://www.courier.com/docs/integrations/push/firebase-fcm) ships the push as `data`, so Android wakes for it. [How the data arrives per provider](https://www.courier.com/docs/send/push/custom-data#how-the-data-arrives-per-provider) shows both payloads.

> **Note:** If you handle notifications outside the Courier hooks, post delivery and click events yourself with `client.tracking.postTrackingUrl`. Each SDK page carries the call: [iOS](https://www.courier.com/docs/sdk-libraries/ios#url-tracking), [Android](https://www.courier.com/docs/sdk-libraries/android#url-tracking), [Flutter](https://www.courier.com/docs/sdk-libraries/flutter#url-tracking), and [React Native](https://www.courier.com/docs/sdk-libraries/react-native#url-tracking).
