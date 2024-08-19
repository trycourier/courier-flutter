# `CourierClient`

Base layer Courier API wrapper.

## Initialization

Creating a client stores request authentication credentials only for that specific client. You can create as many clients as you'd like. See the "Going to Production" section <a href="https://github.com/trycourier/courier-ios/blob/master/Docs/Authentication.md#going-to-production"><code>here</code></a> for more info.

```dart
// Creating a client
final client = final client = CourierClient(
  jwt: 'jwt',                    // Optional. Likely needed for your use case. See above for more authentication details
  clientKey: 'client_key',       // Optional. Used only for Inbox
  userId: 'user_id',
  connectionId: 'connection_id', // Optional. Used for inbox websocket
  tenantId: 'tenant_id',         // Optional. Used for scoping a client to a specific tenant
  showLogs: true,                // Optional. Defaults to your current kDebugMode
);

// Details about the client
final options = client.options
```

## Token Management APIs

All available APIs for Token Management

```dart
// Saves a token into Courier Token Management
final device = CourierDevice(
  appId: 'example',        // Optional
  adId: 'example',         // Optional
  deviceId: 'example',     // Optional
  platform: 'example',     // Optional
  manufacturer: 'example', // Optional
  model: 'example',        // Optional
);

await client.tokens.putUserToken(
  token: 'example_token',
  provider: 'firebase-fcm',
  device: device,  // Optional
);

// Deletes the token from Courier Token Management
try await client.tokens.deleteUserToken(
    token: "..."
)
```

## Inbox APIs

All available APIs for Inbox

```swift
// Get all inbox messages
// Includes the total count in the response
let messages = try await client.inbox.getMessages(
    paginationLimit: 123, // Optional
    startCursor: nil      // Optional
)

// Returns only archived messages
// Includes the total count of archived message in the response
let archivedMessages = try await client.inbox.getArchivedMessages(
    paginationLimit: 123, // Optional
    startCursor: null     // Optional
)

// Gets the number of unread messages
let unreadCount = client.inbox.getUnreadMessageCount()

// Tracking messages
try await client.inbox.open(messageId = "...")
try await client.inbox.read(messageId = "...")
try await client.inbox.unread(messageId = "...")
try await client.inbox.archive(messageId = "...")
try await client.inbox.readAll()

// Inbox Websocket
let socket = client.inbox.socket

socket.onOpen = {
    print("Socket Opened")
}

socket.onClose = { code, reason in
    print("Socket closed: \(code), \(String(describing: reason))")
}

socket.onError = { error in
    print(error)
}

// Returns the event received
// Note: This will not fire unless you provide a connectionId to the client and the event comes from another app using a different connectionId
// Available events: .read, .unread, .markAllRead, .opened,.archive
socket.receivedMessageEvent = { event in
    print(event)
}

socket.receivedMessage = { message in
    print(message)
}

try await socket.connect() // Connects the socket
try await socket.sendSubscribe() // Subscribes to socket events for the user id in the client

socket.disconnect() // Disconnects the socket
```

## Preferences APIs

All available APIs for Preferences

```swift
// Get all the available preference topics
let preferences = try await client.preferences.getUserPreferences(
    paginationCursor: nil // Optional
)

// Gets a specific preference topic
let topic = try await client.preferences.getUserPreferenceTopic(
    topicId: "..."
)

// Updates a user preference topic
try await client.preferences.putUserPreferenceTopic(
    topicId: "...",
    status: .optedIn,
    hasCustomRouting: true,
    customRouting: [.push]
)
```

## Branding APIs

All available APIs for Branding

```dart
final res = await client.brands.getBrand(brandId: 'your_brand_id');
```

## URL Tracking APIs

All available APIs for URL Tracking

```swift
// Pass a trackingUrl, usually found inside of a push notification payload or Inbox message
// Tell which event happened. 
// All available events: .clicked, .delivered, .opened, .read, .unread
try await client.tracking.postTrackingUrl(
    url: "courier_tracking_url",
    event: .delivered
)
```