import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/inbox_feed.dart';

enum InboxMessageEvent {
  added(value: "added"),
  read(value: "read"),
  unread(value: "unread"), 
  opened(value: "opened"),
  archived(value: "archived"),
  clicked(value: "clicked");

  final String value;

  const InboxMessageEvent({
    required this.value,
  });

  static InboxMessageEvent fromString(String value) {
    switch (value) {
      case "added":
        return InboxMessageEvent.added;
      case "read":
        return InboxMessageEvent.read;
      case "unread":
        return InboxMessageEvent.unread;
      case "opened":
        return InboxMessageEvent.opened;
      case "archived":
        return InboxMessageEvent.archived;
      case "clicked":
        return InboxMessageEvent.clicked;
      default:
        throw ArgumentError("Invalid InboxMessageEvent value: $value");
    }
  }
}

class CourierInboxListener {
  String listenerId;
  Function(bool isRefresh)? onLoading;
  Function(String error)? onError;
  Function(int unreadCount)? onUnreadCountChanged;
  Function(InboxFeed feed, int totalCount)? onTotalCountChanged;
  Function(List<InboxMessage> messages, bool canPaginate, InboxFeed feed)? onMessagesChanged;
  Function(List<InboxMessage> messages, bool canPaginate, bool isFirstPage, InboxFeed feed)? onPageAdded;
  Function(InboxMessage message, int index, InboxFeed feed, InboxMessageEvent event)? onMessageEvent;

  CourierInboxListener({
    required this.listenerId,
    this.onLoading,
    this.onError,
    this.onUnreadCountChanged,
    this.onTotalCountChanged,
    this.onMessagesChanged,
    this.onPageAdded,
    this.onMessageEvent,
  });

  Future remove() => Courier.shared.removeInboxListener(listenerId: listenerId);
}