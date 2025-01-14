import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/inbox_feed.dart';
import 'package:courier_flutter/models/inbox_message_set.dart';

class CourierInboxListener {
  String listenerId;
  Function(bool isRefresh)? onLoading;
  Function(String error)? onError;
  Function(int unreadCount)? onUnreadCountChanged;
  Function(InboxMessageSet messageSet)? onFeedChanged;
  Function(InboxMessageSet messageSet)? onArchiveChanged;
  Function(InboxFeed feed, InboxMessageSet page)? onPageAdded;
  Function(InboxFeed feed, int index, InboxMessage message)? onMessageChanged;
  Function(InboxFeed feed, int index, InboxMessage message)? onMessageAdded;
  Function(InboxFeed feed, int index, InboxMessage message)? onMessageRemoved;

  CourierInboxListener({
    required this.listenerId,
    this.onLoading,
    this.onError,
    this.onUnreadCountChanged,
    this.onFeedChanged,
    this.onArchiveChanged,
    this.onPageAdded,
    this.onMessageChanged,
    this.onMessageAdded,
    this.onMessageRemoved,
  });

  Future remove() => Courier.shared.removeInboxListener(listenerId: listenerId);
}