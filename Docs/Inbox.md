<img width="1040" alt="banner-flutter-inbox" src="https://github.com/trycourier/courier-flutter/assets/6370613/57eb1876-6cf3-4ecd-a9ff-134c36c45678">

&emsp;

# Courier Inbox

An in-app notification center list you can use to notify your users. Allows you to build high quality, flexible notification feeds very quickly.

## Requirements

<table>
    <thead>
        <tr>
            <th width="250px" align="left">Requirement</th>
            <th width="800px" align="left">Reason</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <tr width="600px">
                <td align="left">
                    <a href="https://app.courier.com/channels/courier">
                        <code>Courier Inbox Provider</code>
                    </a>
                </td>
                <td align="left">
                    Needed to link your Courier Inbox to the SDK
                </td>
            </tr>
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Authentication.md">
                    <code>Authentication</code>
                </a>
            </td>
            <td align="left">
                Needed to view inbox messages that belong to a user.
            </td>
        </tr>
    </tbody>
</table>

&emsp;

## Default Inbox Example

The default `CourierInbox` styles.

<img width="415" alt="item" src="https://github.com/trycourier/courier-flutter/assets/6370613/979c38aa-b2f0-4c56-bc34-516bacdfb823">

```swift
CourierInbox(
  onMessageClick: (message, index) {
    message.isRead ? message.markAsUnread() : message.markAsRead();
  },
  onActionClick: (action, message, index) {
    print(action);
  },
)
```

&emsp;

⚠️ Courier Flutter will automatically use your app's Theme unless you specifically apply a `CourierTheme`. Here are the values that will automatically be used by your Theme.

- Button Style = `Theme.of(context).elevatedButtonTheme.style`
- Loading Indicator Color = `Theme.of(context).primaryColor`
- Unread Indicator Color = `Theme.of(context).primaryColor`
- Title Style = `Theme.of(context).textTheme.titleMedium`
- Body Style = `Theme.of(context).textTheme.bodyMedium`
- Time Style = `Theme.of(context).textTheme.labelMedium`
- Empty / Error State Text Style = `Theme.of(context).textTheme.titleMedium`
- Empty / Error State Button Style = `Theme.of(context).elevatedButtonTheme.style`

&emsp;

## Styled Inbox Example

The styles you can use to quickly customize the `CourierInbox`.

<img width="415" alt="item" src="https://github.com/trycourier/courier-flutter/assets/6370613/11681111-0019-4457-9c74-6db83bdc0810">


```dart
final theme = CourierInboxTheme(
  brandId: 'ASDF...', // Optional
  loadingIndicatorColor: Colors.purple,
  unreadIndicatorStyle: const CourierInboxUnreadIndicatorStyle(
    indicator: CourierInboxUnreadIndicator.dot,
    color: Colors.pink,
  ),
  titleStyle: CourierInboxTextStyle(
    read: GoogleFonts.notoSans().copyWith(
      fontWeight: FontWeight.normal,
      fontSize: 18,
    ),
    unread: GoogleFonts.notoSans().copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  ),
  timeStyle: CourierInboxTextStyle(
    read: GoogleFonts.notoSans().copyWith(
      fontWeight: FontWeight.normal,
      fontSize: 16,
    ),
    unread: GoogleFonts.notoSans().copyWith(
      fontWeight: FontWeight.normal,
      fontSize: 16,
    ),
  ),
  bodyStyle: CourierInboxTextStyle(
    read: GoogleFonts.notoSans().copyWith(
      fontWeight: FontWeight.normal,
      fontSize: 16,
    ),
    unread: GoogleFonts.notoSans().copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),
  buttonStyle: CourierInboxButtonStyle(
    read: FilledButton.styleFrom(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
    ),
    unread: FilledButton.styleFrom(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
    ),
  ),
  separator: null,
);

// Pass the theme to the inbox
// This example will use the same theme for light and dark mode
CourierInbox(
  lightTheme: theme,
  darkTheme: theme,
  scrollController: _customScrollController,
  onMessageClick: (message, index) {
    message.isRead ? message.markAsUnread() : message.markAsRead();
  },
  onActionClick: (action, message, index) {
    print(action);
    _customScrollController.jumpTo(0);
  },
)
...
```

&emsp;

## Custom Inbox Example

The raw data you can use to build whatever UI you'd like.

<img width="415" alt="item" src="https://github.com/trycourier/courier-flutter/assets/6370613/f032c26e-720b-48fb-8818-24eaa52ad867">

```dart
late CourierInboxListener _inboxListener;

bool _isLoading = true;
String? _error;
List<InboxMessage> _messages = [];

_inboxListener = await Courier.shared.addInboxListener(
  onInitialLoad: () {
    setState(() {
      _isLoading = true;
      _error = null;
    });
  },
  onError: (error) {
    setState(() {
      _isLoading = false;
      _error = error;
    });
  },
  onMessagesChanged: (messages, unreadMessageCount, totalMessageCount, canPaginate) {
    setState(() {
      _messages = messages;
      _isLoading = false;
      _error = null;
    });
  },
);

..

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: ListView.separated(
      itemCount: _messages.length,
      itemBuilder: (BuildContext context, int index) {
        final message = _messages[index];
        return Text(message.messageId)
      },
    ),
  );
}

..

@override
void dispose() {
  _inboxListener.remove().catchError((error) {
    print('Failed to remove inbox listener: $error');
  });
  super.dispose();
}
```

&emsp;

## Full Examples

<table>
    <thead>
        <tr>
            <th width="1001px" align="left">Link</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/example/lib/pages/inbox.dart">
                    <code>Examples</code>
                </a>
            </td>
        </tr>
    </tbody>
</table>

&emsp;

## Available Properties and Functions 

```dart
// Pagination
await Courier.shared.setInboxPaginationLimit(limit: 100);
final messages = await Courier.shared.fetchNextInboxPage();

// Currently fetched messages
final messages = await Courier.shared.inboxMessages;

// Pull to refresh
await Courier.shared.refreshInbox();

// Update a message
await Courier.shared.openMessage(messageId: messageId);
await Courier.shared.readMessage(messageId: messageId);
await Courier.shared.unreadMessage(messageId: messageId);
await Courier.shared.clickMessage(messageId: messageId);
await Courier.shared.archiveMessage(messageId: messageId);
await Courier.shared.readAllInboxMessages();

// Update message shortcuts
final message = InboxMessage(...);
await message.markAsOpened();
await message.markAsRead();
await message.markAsUnread();
await message.markAsClicked();
await message.markAsArchived();

// Listener
final inboxListener = await Courier.shared.addInboxListener(
  onInitialLoad: () {
   
  },
  onError: (error) {
    
  },
  onMessagesChanged: (messages, unreadMessageCount, totalMessageCount, canPaginate) {
    
  },
);

await inboxListener.remove();
```

---

👋 `Inbox APIs` can be found <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Client.md#inbox-apis"><code>here</code></a>
