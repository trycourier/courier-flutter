import 'package:courier_flutter/courier_flutter_v2.dart';
import 'package:courier_flutter/models/inbox_message.dart';

class CourierInboxListener {
  String listenerId;
  Function? onInitialLoad;
  Function(String error)? onError;
  Function(List<InboxMessage> messages, int unreadMessageCount, int totalMessageCount, bool canPaginate)? onMessagesChanged;

  CourierInboxListener({
    required this.listenerId,
    this.onInitialLoad,
    this.onError,
    this.onMessagesChanged,
  });

  Future remove() => CourierRC.shared.removeInboxListener(listenerId: listenerId);
}