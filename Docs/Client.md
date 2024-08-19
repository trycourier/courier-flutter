# `CourierClient`

Base layer Courier API wrapper.

## Initialization

Creating a client stores request authentication credentials only for that specific client. You can create as many clients as you'd like. See the "Going to Production" section <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Authentication.md#going-to-production"><code>here</code></a> for more info.

```dart
// Creating a client
final client = CourierClient(
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
await client.tokens.deleteUserToken(
    token: 'token'
);
```

## Inbox APIs

All available APIs for Inbox

```dart
// Get all inbox messages
// Includes the total count in the response
final res = await client.inbox.getMessages(
  paginationLimit: 123, // Optional
  startCursor: null,    // Optional
);

// Returns only archived messages
// Includes the total count of archived message in the response
final res = await client.inbox.getArchivedMessages(
  paginationLimit: 123, // Optional
  startCursor: null,    // Optional
);

// Gets the number of unread messages
final count = await client.inbox.getUnreadMessageCount();

// Tracking messages
await client.inbox.open(messageId: messageId);
await client.inbox.click(messageId: messageId, trackingId: "example_id");
await client.inbox.read(messageId: messageId);
await client.inbox.unread(messageId: messageId);
await client.inbox.archive(messageId: messageId);
await client.inbox.readAll();
```

## Preferences APIs

All available APIs for Preferences

```dart
// Get all the available preference topics
final res = await client.preferences.getUserPreferences(
  paginationCursor: null // Optional
);

// Gets a specific preference topic
final res = await client.preferences.getUserPreferenceTopic(
  topicId: topicId
);

// Updates a user preference topic
await client.preferences.putUserPreferenceTopic(
  topicId: topicId,
  status: CourierUserPreferencesStatus.optedIn,
  hasCustomRouting: true,
  customRouting: [CourierUserPreferencesChannel.push],
);
```

## Branding APIs

All available APIs for Branding

```dart
final res = await client.brands.getBrand(brandId: brandId);
```

## URL Tracking APIs

All available APIs for URL Tracking

```dart
// Pass a trackingUrl, usually found inside of a push notification payload or Inbox message
await client.tracking.postTrackingUrl(
  url: trackingUrl,
  event: CourierTrackingEvent.delivered,
);
```
