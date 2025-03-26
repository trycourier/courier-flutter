import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/inbox_feed.dart';

enum InboxMessageEvent {
  added(value: "added"),
  changed(value: "changed"), 
  removed(value: "removed");

  final String value;

  const InboxMessageEvent({
    required this.value,
  });

  static InboxMessageEvent fromString(String value) {
    switch (value) {
      case "added":
        return InboxMessageEvent.added;
      case "changed":
        return InboxMessageEvent.changed;
      case "removed":
        return InboxMessageEvent.removed;
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