import 'package:courier_flutter/courier_flutter.dart';

class CourierInboxListener {

  String listenerId;
  Function? onInitialLoad;
  Function(dynamic error)? onError;
  Function(List<InboxMessage> messages, int unreadMessageCount, int totalMessageCount, bool canPaginate)? onMessagesChanged;

  CourierInboxListener({ required this.listenerId });

  Future remove() => Courier.shared.removeInboxListener(id: listenerId);

}