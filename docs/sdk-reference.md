<!-- Generated from https://www.courier.com/docs/sdk-libraries/flutter by mintlify-docs. Edit the docs source, not this file. -->

# Courier Flutter SDK

> Prebuilt inbox and preferences widgets, push token sync, and Dart APIs for Flutter. Set up the iOS and Android projects.

Source: https://www.courier.com/docs/sdk-libraries/flutter

The Courier Flutter SDK gives you prebuilt widgets and Dart APIs. It handles authentication, token management, and real-time delivery on iOS and Android.

This page is the Flutter reference: what to install, how to configure both native projects, and the Dart API surface. Each flow is written once and applies to every platform.

| To do this | Read |
| :-- | :-- |
| Render the inbox | [Add an inbox](https://www.courier.com/docs/in-app/add-an-inbox?lang=Flutter) |
| Theme it, handle taps, or build your own UI | [Customize the inbox](https://www.courier.com/docs/in-app/customize-the-inbox?lang=Flutter) |
| Set up push, from provider to device | [Set up push notifications](https://www.courier.com/docs/guides/set-up-mobile-push) |
| Add the preference center | [Add a preference center](https://www.courier.com/docs/in-app/add-a-preference-center?lang=Flutter) |
| Mint the JWT you sign in with | [Authenticate users](https://www.courier.com/docs/in-app/authenticate-users?lang=Flutter) |

Available on
[GitHub](https://github.com/trycourier/courier-flutter)
and [pub.dev](https://pub.dev/packages/courier_flutter).

| Requirement | Value |
|-------------|-------|
| Flutter | 3.29 or later |
| Dart | 3.7 or later |
| Min iOS version | 15.0 |
| Xcode | 16 or later |
| Min Android SDK | 23 |
| Compile SDK | 34 or later. Your app can target API 36. |
| Java | 17 or later |
| Kotlin | 1.8 or later |
| Gradle | 8.4+ |

## Installation

```bash
flutter pub add courier_flutter
```

### iOS setup

In `ios/Runner/AppDelegate.swift`, change `FlutterAppDelegate` to `CourierFlutterDelegate` and keep the rest of the file. `CourierFlutterDelegate` carries the APNs token and the push callbacks into Dart.

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: CourierFlutterDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
```

### Android setup

#### Add the Jitpack repository

In `android/build.gradle.kts` (or `android/build.gradle` in older apps), add JitPack to `allprojects`:

**build.gradle.kts**

```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}
```

**build.gradle**

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

#### Extend CourierFlutterActivity

In `MainActivity`. This is what lets the SDK persist user state across app sessions.

```kotlin
import com.courier.courier_flutter.CourierFlutterActivity

class MainActivity : CourierFlutterActivity() {
    // ...
}
```

## Authentication

Courier authenticates with a **JWT** that your backend mints with your Courier API key, never in client code. [Authenticate users](https://www.courier.com/docs/in-app/authenticate-users?lang=Flutter) covers the token flow, scope strings, reading auth state, signing out, and token refresh. Using the EU datacenter? See [EU setup](https://www.courier.com/docs/in-app/authenticate-users?lang=Flutter#connect-to-the-eu-datacenter).

Credentials persist across app sessions, so you sign in once per user rather than on every launch.

```dart
await Courier.shared.signIn(userId: "your_user_id", accessToken: jwt);
await Courier.shared.signOut();
```

## Inbox

[Add an inbox](https://www.courier.com/docs/in-app/add-an-inbox?lang=Flutter) is the setup flow. These are the types it uses on Flutter.

| Type | What it is |
| :-- | :-- |
| `CourierInbox` | The prebuilt inbox widget |
| `CourierInboxTheme` | Fonts, colors, unread indicators, swipe actions, tab and button styles |
| `addInboxListener` | Raw message data and events, for a UI you render yourself |

Every callback and action these expose is documented per platform in [Data and actions](https://www.courier.com/docs/in-app/build-a-custom-inbox?lang=Flutter#data-and-actions).

### Inbox theme

With no `CourierInboxTheme`, the widget takes its styling from your app's Flutter `Theme`:

- Button style from `Theme.of(context).elevatedButtonTheme.style`
- Loading and unread indicator color from `Theme.of(context).primaryColor`
- Text styles from `Theme.of(context).textTheme`

Pass a theme to override those. Light and dark themes are separate.

```dart
final theme = CourierInboxTheme(
    loadingIndicatorColor: Color(0xFF9747FF),
    tabIndicatorColor: Color(0xFF9747FF),
    unreadIndicatorStyle: CourierInboxUnreadIndicatorStyle(
        indicator: CourierInboxUnreadIndicator.dot,
        color: Color(0xFF9747FF),
    ),
    // ... additional style properties
);

CourierInbox(
  canSwipePages: true,
  lightTheme: theme,
  darkTheme: theme,
)
```

Branding from [Courier Studio](https://app.courier.com/content/brands) also applies. The SDK reads your brand's primary color.

## Push notifications

[Set up push notifications](https://www.courier.com/docs/guides/set-up-mobile-push) is the setup flow, from connecting APNs and FCM to a device that receives push. It covers the native wiring above, `setTokenForProvider`, permission, and reading the payload on tap.

> **Note:** Push notifications require a physical device. Simulators and emulators don't reliably support push token registration or notification delivery.

| Feature | iOS | Android |
|---------|-----|---------|
| Automatic token management | Yes | Yes |
| Notification tracking | Yes | Yes |
| Permission requests | Yes | No |

On iOS, add a [Notification Service Extension](https://www.courier.com/docs/sdk-libraries/ios#notification-service-extension) to track delivery while your app is closed. If Xcode then reports **Cycle inside Runner**, open the Runner target's **Build Phases** and drag **Embed Foundation Extensions** above **Thin Binary**.

## Preferences

[Add a preference center](https://www.courier.com/docs/in-app/add-a-preference-center?lang=Flutter) is the setup flow. These are the types it uses on Flutter.

| Type | What it is |
| :-- | :-- |
| `CourierPreferences` | The prebuilt preference center widget |
| `mode` | `TopicMode()` or `ChannelsMode(channels: [push, sms, email])` |
| `CourierPreferencesTheme` | Fonts, colors, toggle styles, section headers |

> **Info:** Topics and sections are configured in the [Preferences Editor](https://www.courier.com/docs/guides/build-a-preference-center#configure-the-topics). See [Preferences Overview](https://www.courier.com/docs/recipients/preferences/overview) for how preference enforcement works at send time.

### Preferences theme

Light and dark themes are separate, and [Courier Studio branding](https://app.courier.com/content/brands) applies automatically when you supply a `brandId`.

```dart
final theme = CourierPreferencesTheme(
    brandId: "YOUR_BRAND_ID",
    sectionTitleStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    topicTitleStyle: TextStyle(fontSize: 18),
    // ... additional style properties
);

CourierPreferences(
  mode: TopicMode(),
  lightTheme: theme,
  darkTheme: theme,
)
```

## CourierClient

For advanced use cases, `CourierClient` is a low-level wrapper around the Courier API. Each client holds its own credentials, so you can spin up as many as you need.

### Initialization

```dart
final client = CourierClient(
  jwt:          "...",          // Optional. Required for most authenticated calls
  userId:       "your_user_id",
  connectionId: "...",          // Optional. Used for the inbox websocket
  tenantId:     "...",          // Optional. Scopes the client to a tenant
  apiUrls:      CourierApiUrls.eu, // Optional. Use for EU users
  showLogs:     true,           // Optional. Defaults to kDebugMode
);

final options = client.options;
```

### Token management

```dart
final device = CourierDevice(
  appId:        "APP_ID",
  adId:         "AD_ID",
  deviceId:     "DEVICE_ID",
  platform:     "ios",
  manufacturer: "Apple",
  model:        "iPhone 15",
);

await client.tokens.putUserToken(
  token: "...",
  provider: "firebase-fcm",
  device: device, // Optional
);

await client.tokens.deleteUserToken(token: "...");
```

### Inbox

```dart
final feed = await client.inbox.getMessages(
  paginationLimit: 25,
  startCursor: null,
);

final archived = await client.inbox.getArchivedMessages(
  paginationLimit: 25,
  startCursor: null,
);

final unreadCount = await client.inbox.getUnreadMessageCount();

await client.inbox.open(messageId: "...");
await client.inbox.click(messageId: "...", trackingId: "tracking_id");
await client.inbox.read(messageId: "...");
await client.inbox.unread(messageId: "...");
await client.inbox.archive(messageId: "...");
await client.inbox.readAll();
```

### Preferences

```dart
final prefs = await client.preferences.getUserPreferences(
  paginationCursor: null,
);

final topic = await client.preferences.getUserPreferenceTopic(
  topicId: "...",
);

await client.preferences.putUserPreferenceTopic(
  topicId: "...",
  status: CourierUserPreferencesStatus.optedIn,
  hasCustomRouting: true,
  customRouting: [CourierUserPreferencesChannel.push],
);
```

### Branding

```dart
final brand = await client.brands.getBrand(brandId: "...");
```

### URL tracking

Pass any tracking URL found inside a push notification payload or inbox message:

```dart
// Available events: clicked, delivered, opened, read, unread
await client.tracking.postTrackingUrl(
  url: trackingUrl,
  event: CourierTrackingEvent.delivered,
);
```

See the full Courier API reference at [courier.com/docs/reference](https://www.courier.com/docs/reference/api-overview).
