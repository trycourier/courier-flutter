import 'package:courier_flutter/courier_flutter.dart';
import 'package:intl/intl.dart';

class InboxMessage {
  final String messageId;
  final String? title;
  final String? body;
  final String? preview;
  final String? created;
  final List<InboxAction>? actions;
  final dynamic data;
  bool? archived;
  String? read;
  String? opened;

  InboxMessage({
    required this.messageId,
    this.title,
    this.body,
    this.preview,
    this.created,
    this.actions,
    this.data,
    this.archived,
    this.read,
    this.opened,
  });

  factory InboxMessage.fromJson(dynamic data) {
    List<dynamic>? actions = data['actions'];
    return InboxMessage(
      messageId: data['messageId'],
      title: data['title'],
      body: data['body'],
      preview: data['preview'],
      created: data['created'],
      actions: actions?.map((action) => InboxAction(content: action['content'], href: action['href'], data: action['data'])).toList(),
      data: data['data'],
      archived: data['archived'],
      read: data['read'],
      opened: data['opened'],
    );
  }

  String? get subtitle => body ?? preview;

  bool get isRead => read != null;

  bool get isOpened => opened != null;

  bool get isArchived => archived ?? false;

  void setRead() {
    read = DateTime.now().toIso8601String();
  }

  void setUnread() {
    read = null;
  }

  void setOpened() {
    opened = DateTime.now().toIso8601String();
  }

  String get time {
    final dateFormatter = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZZZZZ');

    if (created != null) {
      final date = dateFormatter.parse(created!);
      final timeDifference = DateTime.now().difference(date);

      final timeSince = timeDifference.inSeconds;

      if (timeSince < 60) {
        return 'now';
      } else if (timeSince < 3600) {
        return '${timeSince ~/ 60} minutes ago';
      } else if (timeSince < 86400) {
        return '${timeSince ~/ 3600} hours ago';
      } else {
        return '${timeSince ~/ 86400} days ago';
      }
    }

    return 'now';
  }
}

extension InboxMessageExtensions on InboxMessage {
  Future markAsClicked() => Courier.shared.clickMessage(id: messageId);
  Future markAsRead() => Courier.shared.readMessage(id: messageId);
  Future markAsUnread() => Courier.shared.unreadMessage(id: messageId);
}
