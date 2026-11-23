<!-- Generated from https://www.courier.com/docs/in-app/build-a-custom-inbox by mintlify-docs. Edit the docs source, not this file. -->

# Build a custom inbox

> Build your own inbox UI from the SDK's messages, unread counts, and actions.

Source: https://www.courier.com/docs/in-app/build-a-custom-inbox

Two levels of custom rendering, in increasing order of control.

**Replace parts** of the built-in inbox, its list item, header, or states, while it keeps managing the list, sync, and pagination. Or **build your own UI** from the message data and actions directly, which every platform supports including mobile.

Reach for the first when the default inbox is nearly right and one element isn't. Reach for the second when your app already has a list component you want to keep. [Customize the inbox](https://www.courier.com/docs/in-app/customize-the-inbox) covers theming, which handles most cases without either.

## Build your own UI

You don't have to render `CourierInbox` at all. Every SDK exposes the message data and actions directly, so you can build the whole UI while the SDK keeps everything synced. The setup is the same everywhere:

1. Start the feed.
2. Render your own UI from the messages.
3. Toggle read (or archive) on interaction.
4. Tear down the listener when the view goes away.

The one difference is how the feed starts:

- **Mobile SDKs**: adding an inbox listener loads the first page for you, if you have [signed the user in](https://www.courier.com/docs/in-app/add-an-inbox) first. (`refreshInbox()` is only for pull-to-refresh.)

```dart
// 1. Start: adding a listener loads the first page (sign in first)
final listener = await Courier.shared.addInboxListener(
  onMessagesChanged: (messages, canPaginate, feed) {
    render(messages); // 2. Build your own UI
  },
);

// 3. Toggle read on tap
message.isRead ? await message.markAsUnread() : await message.markAsRead();

// 4. Tear down
await listener.remove();
```

See [Data and actions](https://www.courier.com/docs/in-app/build-a-custom-inbox#data-and-actions) for the full surface. On the mobile SDKs and Web Components, remove the listener when your view is torn down.

## Data and actions

The pattern above uses a subset of what each SDK exposes. Here is the full surface: the **data** you read (messages, unread count, pagination state) and the **actions** you call (mark read, archive, paginate, refresh). The built-in inbox calls these for you.

On mobile, an inbox listener pushes the data to you and the actions take a `messageId`.

```dart
// Subscribe for live data
final listener = await Courier.shared.addInboxListener(
  onLoading: (isRefresh) { /* spinner */ },
  onError: (error) { /* handle */ },
  onUnreadCountChanged: (count) { /* badge */ },
  onTotalCountChanged: (feed, totalCount) { /* count (note: feed first) */ },
  onMessagesChanged: (messages, canPaginate, feed) { /* render */ },
  onPageAdded: (messages, canPaginate, isFirstPage, feed) { /* append */ },
  onMessageEvent: (message, index, feed, event) { /* InboxMessageEvent.added / .read ... */ },
);

// DATA (Futures you await)

// Messages in the main feed
await Courier.shared.feedMessages;         // List<InboxMessage>
// Messages in the archived feed
await Courier.shared.archivedMessages;     // List<InboxMessage>
// Current page size (default 32)
await Courier.shared.inboxPaginationLimit;
// Each InboxMessage: messageId, title, body, preview, subtitle,
// isRead, isOpened, isArchived, created, actions

// ACTIONS (async; take a messageId)

// Mark read / unread
await Courier.shared.readMessage(messageId: id);
await Courier.shared.unreadMessage(messageId: id);
// Track click / open
await Courier.shared.clickMessage(messageId: id);
await Courier.shared.openMessage(messageId: id);
// Archive (no unarchive on Flutter)
await Courier.shared.archiveMessage(messageId: id);
// Mark every message read
await Courier.shared.readAllInboxMessages();
// Set the page size
await Courier.shared.setInboxPaginationLimit(limit: 50);
// Load the next page (InboxFeed.feed or InboxFeed.archive)
await Courier.shared.fetchNextInboxPage(feed: InboxFeed.feed);
// Refresh from the server
await Courier.shared.refreshInbox();
// Stop listening (cleanup)
await listener.remove();
// Or from a message:
// await message.markAsRead() / markAsUnread() / markAsOpened() / markAsClicked() / markAsArchived()
```
