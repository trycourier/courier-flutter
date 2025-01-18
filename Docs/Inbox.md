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

# JWT Authentication

If you are using JWT authentication, be sure to enable JWT support on the Courier Inbox Provider [`here`](https://app.courier.com/integrations/catalog/courier).

<img width="385" alt="Screenshot 2024-12-09 at 11 19 31 AM" src="https://github.com/user-attachments/assets/71c945f3-9fa0-4736-ae0d-a4760cb49220">

&emsp;

## Default Inbox Example

The default `CourierInbox` styles.

<img width="390" alt="default-inbox-styles" src="https://github.com/user-attachments/assets/f889cc24-b50a-4e3a-be4a-29a6c3d02921">
<img width="410" alt="android-default-inbox-styles" src="https://github.com/user-attachments/assets/b7eb7c74-fc37-4d71-b351-bb5e584a7a63">

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

<img width="390" alt="default-inbox-styles" src="https://github.com/user-attachments/assets/b2a48933-0299-4a9f-8ad9-753b81ab39e4">
<img width="410" alt="android-default-inbox-styles" src="https://github.com/user-attachments/assets/f5edd497-43cd-45cd-bdca-c6a2c77d4958">


```dart
final theme = CourierInboxTheme(
    unreadIndicatorStyle: const CourierInboxUnreadIndicatorStyle(
      indicator: CourierInboxUnreadIndicator.dot,
      color: Color(0xFF9747FF),
    ),
    loadingIndicatorColor: Color(0xFF9747FF),
    tabIndicatorColor: Color(0xFF9747FF),
    tabStyle: CourierInboxTabStyle(
      selected: CourierInboxTabItemStyle(
        font: GoogleFonts.sen().copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF9747FF),
        ),
        indicator: CourierInboxTabIndicatorStyle(
          color: Color(0xFF9747FF),
          font: GoogleFonts.sen().copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      unselected: CourierInboxTabItemStyle(
        font: GoogleFonts.sen().copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 18,
          color: Colors.black45,
        ),
        indicator: CourierInboxTabIndicatorStyle(
          color: Colors.black45,
          font: GoogleFonts.sen().copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    ),
    readingSwipeActionStyle: CourierInboxReadingSwipeActionStyle(
      read: const CourierInboxSwipeActionStyle(
        icon: Icons.drafts,
        color: Color(0xFF9747FF),
      ),
      unread: CourierInboxSwipeActionStyle(
        icon: Icons.mark_email_read,
        color: Color(0xFF9747FF).withOpacity(0.5),
      ),
    ),
    archivingSwipeActionStyle: const CourierInboxArchivingSwipeActionStyle(
      archive: CourierInboxSwipeActionStyle(
        icon: Icons.inbox,
        color: Colors.red,
      ),
    ),
    titleStyle: CourierInboxTextStyle(
      read: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 18,
      ),
      unread: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    timeStyle: CourierInboxTextStyle(
      read: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      unread: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    bodyStyle: CourierInboxTextStyle(
      read: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      unread: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    buttonStyle: CourierInboxButtonStyle(
      read: FilledButton.styleFrom(
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.sen().copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
      ),
      unread: FilledButton.styleFrom(
        backgroundColor: Color(0xFF9747FF),
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.sen().copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
      ),
    ),
    separator: null,
);

// Pass the theme to the inbox
// This example will use the same theme for light and dark mode
CourierInbox(
  canSwipePages: true,
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
  onMessageLongPress: (message, index) {
    ...
  }
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
bool _canLoadMore = false;

_inboxListener = await Courier.shared.addInboxListener(
  onLoading: (isRefresh) {
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
  onUnreadCountChanged: (unreadCount) {
    print('unreadCount: $unreadCount');
  },
  onFeedChanged: (messageSet) {
    setState(() {
      _messages = messageSet.messages;
      _isLoading = false;
      _error = null;
      _canLoadMore = messageSet.canPaginate;
    });
  },
  onMessageChanged: (feed, index, message) {
    if (feed == InboxFeed.feed) {
      setState(() {
        _messages[index] = message;
      });
    }
  },
  onMessageAdded: (feed, index, message) {
    if (feed == InboxFeed.feed) {
      setState(() {
        _messages.insert(index, message);
      });
    }
  },
  onMessageRemoved: (feed, index, message) {
    if (feed == InboxFeed.feed) {
      setState(() {
        _messages.removeAt(index);
      });
    }
  },
  onPageAdded: (feed, page) {
    if (feed == InboxFeed.feed) {
      setState(() {
        _messages += page.messages;
        _canLoadMore = page.canPaginate;
      });
    }
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
  onLoading: (isRefresh) {
    
  },
  onError: (error) {
    
  },
  onUnreadCountChanged: (unreadCount) {
    
  },
  onFeedChanged: (messageSet) {
    
  },
  onMessageChanged: (feed, index, message) {
    
  },
  onMessageAdded: (feed, index, message) {
    
  },
  onMessageRemoved: (feed, index, message) {
    
  },
  onPageAdded: (feed, page) {
    
  },
);

await inboxListener.remove();
```

---

👋 `Inbox APIs` can be found <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Client.md#inbox-apis"><code>here</code></a>
