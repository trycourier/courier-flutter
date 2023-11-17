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

## Custom Inbox Example

The raw data you can use to build whatever UI you'd like.

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
```

&emsp;

## Full Examples

<table>
    <thead>
        <tr>
            <th width="850px" align="left">Link</th>
            <th width="200px" align="center">Style</th>
        </tr>
    </thead>
    <tbody>
        <tr width="600px">
            <td align="left">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/example/lib/pages/inbox.dart">
                    <code>Custom Example</code>
                </a>
            </td>
            <td align="center">
                <a href="https://github.com/trycourier/courier-flutter/blob/master/Docs/Inbox.md#custom-inbox-example">
                    <code>Custom</code>
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
final newMessages = await Courier.shared.fetchNextPageOfMessages();

// Pull to refresh
await Courier.shared.refreshInbox();

// Read / Unread
await inboxMessage.markAsUnread();
await inboxMessage.markAsRead();
await Courier.shared.unreadMessage(id: 'messageId');
await Courier.shared.readMessage(id: 'messageId');
await Courier.shared.readAllInboxMessages();

// Listener
final inboxListener = await Courier.shared.addInboxListener(
  onInitialLoad: () {
   
  },
  onError: (error) {
    
  },
  onMessagesChanged: (messages, unreadMessageCount, totalMessageCount, canPaginate) {
    
  },
);

inboxListener.remove();
```
